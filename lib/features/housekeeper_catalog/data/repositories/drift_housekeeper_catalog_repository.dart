import 'package:drift/drift.dart';

import '../../../../shared/persistence/app_database.dart';
import '../../../../shared/persistence/drift_command_ledger.dart';
import '../../domain/catalogs/margaritaville_housekeeper_catalog.dart';
import '../../domain/models/housekeeper.dart';
import '../../domain/models/housekeeper_catalog_command_descriptor.dart';
import '../../domain/models/housekeeper_catalog_mutation.dart';
import '../../domain/repositories/housekeeper_catalog_repository.dart';

final class DriftHousekeeperCatalogRepository
    implements HousekeeperCatalogRepository {
  const DriftHousekeeperCatalogRepository(this._database);

  final AppDatabase _database;

  @override
  Future<void> ensureDefaults(DateTime seededAt) {
    return _database.transaction(() async {
      for (
        var index = 0;
        index < MargaritavilleHousekeeperCatalog.entries.length;
        index++
      ) {
        final entry = MargaritavilleHousekeeperCatalog.entries[index];
        await _database
            .into(_database.housekeeperCatalogRecords)
            .insert(
              HousekeeperCatalogRecordsCompanion.insert(
                id: entry.id,
                displayName: entry.displayName,
                paletteKey: entry.paletteKey,
                sortOrder: index,
                updatedAt: seededAt,
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
    });
  }

  @override
  Future<List<Housekeeper>> loadActive() => _activeQuery().get().then(_mapRows);

  @override
  Stream<List<Housekeeper>> watchActive() {
    return _activeQuery().watch().map(_mapRows);
  }

  @override
  Future<HousekeeperCatalogMutation> commitCommand({
    required HousekeeperCatalogCommandDescriptor descriptor,
    required HousekeeperCatalogMutation Function(
      HousekeeperCatalogSnapshot snapshot,
    )
    mutate,
  }) async {
    HousekeeperCatalogMutation? evaluated;
    final status = await DriftCommandLedger(_database).commit(
      envelope: CommandLedgerEnvelope.forAggregate(
        aggregateType: 'housekeeper-catalog',
        aggregateId: 'margaritaville',
        commandId: descriptor.commandId,
        commandVersion: descriptor.version,
        commandType: descriptor.commandType,
        commandFingerprint: CommandLedgerEnvelope.fingerprint(
          descriptor.canonicalPayload,
        ),
        issuedAt: descriptor.issuedAt,
        eventId: 'housekeeper-catalog:margaritaville:${descriptor.commandId}',
        eventType: descriptor.eventType,
        eventPayload: const {},
      ),
      mutate: () async {
        final rows = await (_database.select(
          _database.housekeeperCatalogRecords,
        )..orderBy([(row) => OrderingTerm.asc(row.sortOrder)])).get();
        final activeRows = rows
            .where((row) => row.deletedAt == null)
            .toList(growable: false);
        final result = mutate(
          HousekeeperCatalogSnapshot(
            active: _mapRows(activeRows),
            reservedIds: rows.map((row) => row.id).toSet(),
            nextSortOrder: rows.isEmpty
                ? 0
                : rows
                          .map((row) => row.sortOrder)
                          .reduce((a, b) => a > b ? a : b) +
                      1,
          ),
        );
        evaluated = result;
        if (result.status != HousekeeperCatalogMutationStatus.changed) {
          return false;
        }
        await _apply(result);
        return true;
      },
      eventPayloadAfterMutation: () => _eventPayload(evaluated!),
    );
    if (status == CommandLedgerStatus.duplicate) {
      return const HousekeeperCatalogMutation.ignored();
    }
    return evaluated ?? const HousekeeperCatalogMutation.ignored();
  }

  SimpleSelectStatement<$HousekeeperCatalogRecordsTable, HousekeeperCatalogRow>
  _activeQuery() {
    return _database.select(_database.housekeeperCatalogRecords)
      ..where((row) => row.deletedAt.isNull())
      ..orderBy([(row) => OrderingTerm.asc(row.sortOrder)]);
  }

  List<Housekeeper> _mapRows(List<HousekeeperCatalogRow> rows) {
    return rows
        .map(
          (row) => Housekeeper(
            id: row.id,
            displayName: row.displayName,
            paletteKey: row.paletteKey,
            updatedAt: row.updatedAt,
            deletedAt: row.deletedAt,
          ),
        )
        .toList(growable: false);
  }

  Future<void> _apply(HousekeeperCatalogMutation mutation) async {
    final housekeeper = mutation.housekeeper!;
    final sortOrder = mutation.sortOrder;
    if (sortOrder != null) {
      await _database
          .into(_database.housekeeperCatalogRecords)
          .insert(
            HousekeeperCatalogRecordsCompanion.insert(
              id: housekeeper.id,
              displayName: housekeeper.displayName,
              paletteKey: housekeeper.paletteKey,
              sortOrder: sortOrder,
              updatedAt: housekeeper.updatedAt,
            ),
          );
      return;
    }
    final update = _database.update(_database.housekeeperCatalogRecords)
      ..where((row) => row.id.equals(housekeeper.id) & row.deletedAt.isNull());
    final changedFields = mutation.changedFields;
    final written = await update.write(
      HousekeeperCatalogRecordsCompanion(
        displayName:
            changedFields.contains(HousekeeperCatalogChangedField.displayName)
            ? Value(housekeeper.displayName)
            : const Value.absent(),
        paletteKey:
            changedFields.contains(HousekeeperCatalogChangedField.paletteKey)
            ? Value(housekeeper.paletteKey)
            : const Value.absent(),
        updatedAt: Value(housekeeper.updatedAt),
      ),
    );
    if (written != 1) {
      throw StateError('Housekeeper ${housekeeper.id} changed concurrently.');
    }
  }

  Map<String, Object?> _eventPayload(HousekeeperCatalogMutation mutation) => {
    'housekeeperId': mutation.housekeeper!.id,
    'changedFields': [for (final field in mutation.changedFields) field.name]
      ..sort(),
  };
}
