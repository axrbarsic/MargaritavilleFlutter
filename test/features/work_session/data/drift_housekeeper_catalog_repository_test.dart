import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/work_session/data/repositories/drift_housekeeper_catalog_repository.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/housekeeper.dart';
import 'package:margaritaville_flutter/shared/persistence/app_database.dart';

void main() {
  late AppDatabase database;
  late DriftHousekeeperCatalogRepository repository;
  final now = DateTime.utc(2027, 2, 10, 12);

  setUp(() {
    database = AppDatabase.inMemory();
    repository = DriftHousekeeperCatalogRepository(database);
  });

  tearDown(() => database.close());

  test('seeds the exact donor catalog once and preserves its order', () async {
    await repository.ensureDefaults(now);
    await repository.ensureDefaults(now.add(const Duration(days: 1)));

    final housekeepers = await repository.loadActive();
    expect(housekeepers, hasLength(20));
    expect(housekeepers.first.displayName, 'Kerlange');
    expect(housekeepers[1].displayName, 'Ana');
    expect(housekeepers[14].displayName, 'Omelene PM');
    expect(housekeepers.last.displayName, 'Wonderline');
    expect(housekeepers.map((value) => value.id).toSet(), hasLength(20));
  });

  test(
    'rename survives reload and default seeding does not overwrite it',
    () async {
      await repository.ensureDefaults(now);
      await repository.save(
        Housekeeper(
          id: 'ketty',
          displayName: 'Ketty Updated',
          paletteKey: 'ruby',
          updatedAt: now.add(const Duration(minutes: 1)),
        ),
        sortOrder: 7,
      );
      await repository.ensureDefaults(now.add(const Duration(days: 1)));

      final housekeepers = await repository.loadActive();
      expect(
        housekeepers.singleWhere((value) => value.id == 'ketty').displayName,
        'Ketty Updated',
      );
    },
  );

  test('removed catalog entry stays removed after default seeding', () async {
    await repository.ensureDefaults(now);
    await repository.remove(
      'ketty',
      changedAt: now.add(const Duration(minutes: 1)),
    );
    await repository.ensureDefaults(now.add(const Duration(days: 1)));

    final housekeepers = await repository.loadActive();
    expect(housekeepers.any((value) => value.id == 'ketty'), isFalse);
  });
}
