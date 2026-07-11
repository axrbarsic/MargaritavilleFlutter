import 'package:drift/drift.dart';

import '../../../../shared/persistence/app_database.dart';
import '../../../../shared/persistence/drift_command_ledger.dart';
import '../../application/commands/cart_details_command.dart';
import '../../domain/catalogs/cart_consumable_catalog.dart';
import '../../domain/models/cart_consumable.dart';
import '../../domain/models/cart_details_snapshot.dart';
import '../../domain/repositories/cart_details_repository.dart';

final class DriftCartDetailsRepository implements CartDetailsRepository {
  const DriftCartDetailsRepository(this._database);

  final AppDatabase _database;

  @override
  Future<CartDetailsSnapshot> load({
    required String sessionId,
    required String assignmentId,
  }) async {
    final noteQuery = _database.select(_database.assignmentNoteRecords)
      ..where(
        (row) =>
            row.sessionId.equals(sessionId) &
            row.assignmentId.equals(assignmentId),
      );
    final itemsQuery = _database.select(_database.cartConsumableRecords)
      ..where(
        (row) =>
            row.sessionId.equals(sessionId) &
            row.assignmentId.equals(assignmentId) &
            row.deletedAtMicros.isNull(),
      );
    final note = await noteQuery.getSingleOrNull();
    final storedItems = (await itemsQuery.get()).map(_mapConsumable);
    return CartDetailsSnapshot(
      sessionId: sessionId,
      assignmentId: assignmentId,
      note: note?.deletedAtMicros == null ? note?.textValue : null,
      noteUpdatedAt: _dateTime(note?.updatedAtMicros),
      consumables: CartConsumableCatalog.merge(storedItems),
    );
  }

  @override
  Future<CartDetailsCommitStatus> commit(CartDetailsCommand command) async {
    _validate(command);
    final status = await DriftCommandLedger(_database).commit(
      envelope: _envelope(command),
      mutate: () async {
        if (!await _assignmentExists(command)) return false;
        return switch (command) {
          final SaveCartNoteCommand value => _saveNote(value),
          final SetCartConsumableQuantityCommand value => _setQuantity(value),
          final SetCartConsumableCompletionCommand value => _setCompletion(
            value,
          ),
        };
      },
    );
    return CartDetailsCommitStatus.values.byName(status.name);
  }

  Future<bool> _assignmentExists(CartDetailsCommand command) async {
    final query = _database.select(_database.workAssignmentRecords)
      ..where(
        (row) =>
            row.sessionId.equals(command.sessionId) &
            row.id.equals(command.assignmentId) &
            row.deletedAt.isNull(),
      )
      ..limit(1);
    return await query.getSingleOrNull() != null;
  }

  Future<bool> _saveNote(SaveCartNoteCommand command) async {
    final existing = await _note(command).getSingleOrNull();
    if (!_wins(command, existing?.updatedAtMicros, existing?.lastCommandId)) {
      return false;
    }
    final normalized = command.text.trim();
    await _database
        .into(_database.assignmentNoteRecords)
        .insertOnConflictUpdate(
          AssignmentNoteRecordsCompanion.insert(
            sessionId: command.sessionId,
            assignmentId: command.assignmentId,
            textValue: normalized,
            updatedAtMicros: command.issuedAt.microsecondsSinceEpoch,
            lastCommandId: Value(command.commandId),
            deletedAtMicros: Value(
              normalized.isEmpty
                  ? command.issuedAt.microsecondsSinceEpoch
                  : null,
            ),
          ),
        );
    return true;
  }

  Future<bool> _setQuantity(SetCartConsumableQuantityCommand command) async {
    final existing = await _consumable(
      command,
      command.itemId,
    ).getSingleOrNull();
    if (!_wins(command, existing?.updatedAtMicros, existing?.lastCommandId)) {
      return false;
    }
    await _database
        .into(_database.cartConsumableRecords)
        .insertOnConflictUpdate(
          CartConsumableRecordsCompanion.insert(
            sessionId: command.sessionId,
            assignmentId: command.assignmentId,
            itemId: command.itemId,
            title: command.title.trim(),
            quantity: command.quantity,
            updatedAtMicros: command.issuedAt.microsecondsSinceEpoch,
            lastCommandId: command.commandId,
            completedAtMicros: Value(
              command.quantity == 0 ? null : existing?.completedAtMicros,
            ),
          ),
        );
    return true;
  }

  Future<bool> _setCompletion(
    SetCartConsumableCompletionCommand command,
  ) async {
    final existing = await _consumable(
      command,
      command.itemId,
    ).getSingleOrNull();
    if (!_wins(command, existing?.updatedAtMicros, existing?.lastCommandId)) {
      return false;
    }
    await _database
        .into(_database.cartConsumableRecords)
        .insertOnConflictUpdate(
          CartConsumableRecordsCompanion.insert(
            sessionId: command.sessionId,
            assignmentId: command.assignmentId,
            itemId: command.itemId,
            title: command.title.trim(),
            quantity: existing?.quantity ?? 0,
            updatedAtMicros: command.issuedAt.microsecondsSinceEpoch,
            lastCommandId: command.commandId,
            completedAtMicros: Value(
              command.isCompleted
                  ? command.issuedAt.microsecondsSinceEpoch
                  : null,
            ),
          ),
        );
    return true;
  }

  SimpleSelectStatement<$AssignmentNoteRecordsTable, AssignmentNoteRow> _note(
    CartDetailsCommand command,
  ) {
    return _database.select(_database.assignmentNoteRecords)..where(
      (row) =>
          row.sessionId.equals(command.sessionId) &
          row.assignmentId.equals(command.assignmentId),
    );
  }

  SimpleSelectStatement<$CartConsumableRecordsTable, CartConsumableRow>
  _consumable(CartDetailsCommand command, String itemId) {
    return _database.select(_database.cartConsumableRecords)..where(
      (row) =>
          row.sessionId.equals(command.sessionId) &
          row.assignmentId.equals(command.assignmentId) &
          row.itemId.equals(itemId),
    );
  }
}

CartConsumable _mapConsumable(CartConsumableRow row) => CartConsumable(
  id: row.itemId,
  title: row.title,
  quantity: row.quantity,
  updatedAt: _dateTime(row.updatedAtMicros),
  completedAt: _dateTime(row.completedAtMicros),
);

DateTime? _dateTime(int? micros) => micros == null
    ? null
    : DateTime.fromMicrosecondsSinceEpoch(micros, isUtc: true);

bool _wins(
  CartDetailsCommand command,
  int? storedMicros,
  String? storedCommandId,
) {
  if (storedMicros == null) return true;
  final incoming = command.issuedAt.microsecondsSinceEpoch;
  return incoming > storedMicros ||
      (incoming == storedMicros &&
          command.commandId.compareTo(storedCommandId ?? '') > 0);
}

void _validate(CartDetailsCommand command) {
  if (command.sessionId.trim().isEmpty || command.assignmentId.trim().isEmpty) {
    throw ArgumentError('Cart command owner must not be blank.');
  }
  if (command case SetCartConsumableQuantityCommand(
    :final quantity,
  ) when quantity < 0 || quantity > 10) {
    throw RangeError.range(quantity, 0, 10, 'quantity');
  }
  if (command
      case SetCartConsumableQuantityCommand(:final itemId, :final title) ||
          SetCartConsumableCompletionCommand(:final itemId, :final title)
      when itemId.trim().isEmpty || title.trim().isEmpty) {
    throw ArgumentError('Consumable identity must not be blank.');
  }
}

CommandLedgerEnvelope _envelope(CartDetailsCommand command) {
  final eventType = switch (command) {
    SaveCartNoteCommand() => 'assignment.note.updated',
    SetCartConsumableQuantityCommand() => 'assignment.consumable.quantity',
    SetCartConsumableCompletionCommand() => 'assignment.consumable.completed',
  };
  return CommandLedgerEnvelope(
    sessionId: command.sessionId,
    commandId: command.commandId,
    commandVersion: command.commandVersion,
    commandType: eventType,
    commandFingerprint: CommandLedgerEnvelope.fingerprint(
      _fingerprintPayload(command),
    ),
    issuedAt: command.issuedAt,
    eventId: 'assignment:${command.sessionId}:${command.commandId}',
    eventType: eventType,
    eventPayload: _eventPayload(command),
  );
}

Map<String, Object?> _eventPayload(CartDetailsCommand command) => {
  'assignmentId': command.assignmentId,
  if (command case SetCartConsumableQuantityCommand(
    :final itemId,
    :final quantity,
  )) ...{
    'itemId': itemId,
    'quantity': quantity,
  },
  if (command case SetCartConsumableCompletionCommand(
    :final itemId,
    :final isCompleted,
  )) ...{
    'itemId': itemId,
    'isCompleted': isCompleted,
  },
};

Map<String, Object?> _fingerprintPayload(CartDetailsCommand command) => {
  ..._eventPayload(command),
  if (command case SaveCartNoteCommand(:final text)) 'text': text,
  if (command case SetCartConsumableQuantityCommand(:final title))
    'title': title,
  if (command case SetCartConsumableCompletionCommand(:final title))
    'title': title,
};
