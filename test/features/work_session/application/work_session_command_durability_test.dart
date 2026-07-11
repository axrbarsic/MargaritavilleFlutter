import 'package:drift/drift.dart' show Variable;
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/cart_details/application/commands/cart_details_command.dart';
import 'package:margaritaville_flutter/features/cart_details/data/repositories/drift_cart_details_repository.dart';
import 'package:margaritaville_flutter/features/work_session/application/commands/work_session_command.dart';
import 'package:margaritaville_flutter/features/work_session/application/work_session_command_handler.dart';
import 'package:margaritaville_flutter/features/work_session/data/repositories/drift_work_session_repository.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/hotel_profile.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/housekeeper.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_assignment.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_session.dart';
import 'package:margaritaville_flutter/shared/persistence/app_database.dart';

void main() {
  late AppDatabase database;
  late DriftWorkSessionRepository repository;
  late WorkSessionCommandHandler handler;
  late WorkSession initial;

  setUp(() async {
    database = AppDatabase.inMemory();
    repository = DriftWorkSessionRepository(database);
    handler = WorkSessionCommandHandler(repository);
    initial = _session('session-1');
    await repository.replaceSession(initial);
  });

  tearDown(() => database.close());

  test(
    'changed command is durable, idempotent, and preserves content',
    () async {
      final cart = DriftCartDetailsRepository(database);
      final assignment = initial.activeAssignments.single;
      final changedAt = DateTime.utc(2027, 2, 10, 13);
      await cart.commit(
        SaveCartNoteCommand(
          commandId: 'note-1',
          sessionId: initial.id,
          assignmentId: assignment.id,
          issuedAt: changedAt.subtract(const Duration(microseconds: 2)),
          text: 'Не стирать',
        ),
      );
      await cart.commit(
        SetCartConsumableQuantityCommand(
          commandId: 'quantity-1',
          sessionId: initial.id,
          assignmentId: assignment.id,
          issuedAt: changedAt.subtract(const Duration(microseconds: 1)),
          itemId: 'bath_towel',
          title: 'Полотенца банные',
          quantity: 4,
        ),
      );
      final rowIdsBefore = await _graphRowIds(database, initial.id);
      final command = SetAssignmentTerritoryCommand(
        commandId: 'territory-1',
        issuedAt: changedAt,
        assignmentId: assignment.id,
        territoryId: 'B1',
      );

      final applied = await handler.execute(initial, command);
      final duplicate = await handler.execute(initial, command);

      expect(applied.session.assignment(assignment.id)?.territoryId, 'B1');
      expect(duplicate.session.assignment(assignment.id)?.territoryId, 'B1');
      expect(await _graphRowIds(database, initial.id), rowIdsBefore);
      final snapshot = await cart.load(
        sessionId: initial.id,
        assignmentId: assignment.id,
      );
      expect(snapshot.note, 'Не стирать');
      expect(snapshot.consumables.first.quantity, 4);
      expect(await _receiptCount(database, 'territory-1'), 1);
      expect(await _historyCount(database, 'territory-1'), 1);
      expect(
        await _outboxCount(database, 'work-session:${initial.id}:territory-1'),
        1,
      );
    },
  );

  test(
    'same ID with different semantics rejects without a second mutation',
    () async {
      final assignment = initial.activeAssignments.single;
      final changedAt = DateTime.utc(2027, 2, 10, 13);
      await handler.execute(
        initial,
        SetAssignmentTerritoryCommand(
          commandId: 'territory-conflict',
          issuedAt: changedAt,
          assignmentId: assignment.id,
          territoryId: 'B1',
        ),
      );

      await expectLater(
        handler.execute(
          initial,
          SetAssignmentTerritoryCommand(
            commandId: 'territory-conflict',
            issuedAt: changedAt,
            assignmentId: assignment.id,
            territoryId: 'A2',
          ),
        ),
        throwsStateError,
      );
      expect(
        (await repository.loadSession(
          initial.id,
        ))?.assignment(assignment.id)?.territoryId,
        'B1',
      );
      expect(await _receiptCount(database, 'territory-conflict'), 1);
      expect(await _historyCount(database, 'territory-conflict'), 1);
    },
  );

  test('ignored command stores only its durable receipt', () async {
    final assignment = initial.activeAssignments.single;
    await handler.execute(
      initial,
      SetAssignmentTerritoryCommand(
        commandId: 'territory-ignored',
        issuedAt: DateTime.utc(2027, 2, 10, 13),
        assignmentId: assignment.id,
        territoryId: assignment.territoryId,
      ),
    );

    final receipt = (database.select(
      database.commandReceiptRecords,
    )..where((row) => row.commandId.equals('territory-ignored'))).getSingle();
    expect((await receipt).outcome, 'ignored');
    expect(await _historyCount(database, 'territory-ignored'), 0);
    expect(
      await _outboxCount(
        database,
        'work-session:${initial.id}:territory-ignored',
      ),
      0,
    );
  });

  test(
    'authoritative Drift state prevents stale clients from losing updates',
    () async {
      final assignment = initial.activeAssignments.single;
      final first = await handler.execute(
        initial,
        SetAssignmentTerritoryCommand(
          commandId: 'stale-territory',
          issuedAt: DateTime.utc(2027, 2, 10, 13),
          assignmentId: assignment.id,
          territoryId: 'B1',
        ),
      );
      expect(first.status, WorkSessionMutationStatus.changed);

      await handler.execute(
        initial,
        AssignRoomCommand(
          commandId: 'stale-room',
          issuedAt: DateTime.utc(2027, 2, 10, 13, 0, 1),
          assignmentId: assignment.id,
          roomNumber: '102',
        ),
      );

      final reloaded = await repository.loadSession(initial.id);
      expect(reloaded?.assignment(assignment.id)?.territoryId, 'B1');
      expect(reloaded?.room('102'), isNotNull);
    },
  );
}

WorkSession _session(String id) {
  final now = DateTime.utc(2027, 2, 10, 12);
  final assignment = WorkAssignment.create(
    id: '$id-cart-1',
    cartNumber: 1,
    housekeeper: Housekeeper(
      id: '$id-ketty',
      displayName: 'Ketty',
      paletteKey: 'ruby',
      updatedAt: now,
    ),
    assignedAt: now,
  );
  return WorkSession.create(
        id: id,
        hotel: HotelProfile.margaritaville,
        startedAt: now,
        assignments: [assignment],
      )
      .assignRoom(
        assignmentId: assignment.id,
        roomNumber: '101',
        changedAt: now.add(const Duration(microseconds: 1)),
      )
      .session;
}

Future<Map<String, int>> _graphRowIds(
  AppDatabase database,
  String sessionId,
) async {
  final result = <String, int>{};
  for (final table in [
    'housekeeper_records',
    'work_assignment_records',
    'room_state_records',
  ]) {
    final rows = await database
        .customSelect(
          'SELECT rowid FROM $table WHERE session_id = ? ORDER BY rowid',
          variables: [Variable<String>(sessionId)],
        )
        .get();
    result[table] = rows.single.read<int>('rowid');
  }
  return result;
}

Future<int> _receiptCount(AppDatabase database, String commandId) async {
  final rows = await (database.select(
    database.commandReceiptRecords,
  )..where((row) => row.commandId.equals(commandId))).get();
  return rows.length;
}

Future<int> _historyCount(AppDatabase database, String commandId) async {
  final rows = await (database.select(
    database.historyEventRecords,
  )..where((row) => row.commandId.equals(commandId))).get();
  return rows.length;
}

Future<int> _outboxCount(AppDatabase database, String eventId) async {
  final rows = await (database.select(
    database.syncOutboxRecords,
  )..where((row) => row.eventId.equals(eventId))).get();
  return rows.length;
}
