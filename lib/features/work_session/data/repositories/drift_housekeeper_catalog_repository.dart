import 'package:drift/drift.dart';

import '../../../../shared/persistence/app_database.dart';
import '../../domain/catalogs/margaritaville_housekeeper_catalog.dart';
import '../../domain/models/housekeeper.dart';
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
  Future<void> save(Housekeeper housekeeper, {required int sortOrder}) {
    _validate(housekeeper, sortOrder);
    return _database
        .into(_database.housekeeperCatalogRecords)
        .insertOnConflictUpdate(
          HousekeeperCatalogRecordsCompanion.insert(
            id: housekeeper.id.trim(),
            displayName: housekeeper.displayName.trim(),
            paletteKey: housekeeper.paletteKey.trim(),
            sortOrder: sortOrder,
            updatedAt: housekeeper.updatedAt,
            deletedAt: Value(housekeeper.deletedAt),
          ),
        );
  }

  @override
  Future<void> remove(String housekeeperId, {required DateTime changedAt}) {
    final normalizedId = housekeeperId.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError.value(housekeeperId, 'housekeeperId');
    }
    return (_database.update(
      _database.housekeeperCatalogRecords,
    )..where((row) => row.id.equals(normalizedId))).write(
      HousekeeperCatalogRecordsCompanion(
        updatedAt: Value(changedAt),
        deletedAt: Value(changedAt),
      ),
    );
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

  void _validate(Housekeeper housekeeper, int sortOrder) {
    if (housekeeper.id.trim().isEmpty ||
        housekeeper.displayName.trim().isEmpty ||
        housekeeper.paletteKey.trim().isEmpty ||
        sortOrder < 0) {
      throw ArgumentError('Invalid housekeeper catalog entry.');
    }
  }
}
