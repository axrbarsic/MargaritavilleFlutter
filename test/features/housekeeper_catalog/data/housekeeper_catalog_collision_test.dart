import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/housekeeper_catalog/application/housekeeper_catalog_command_handler.dart';
import 'package:margaritaville_flutter/features/housekeeper_catalog/data/repositories/drift_housekeeper_catalog_repository.dart';
import 'package:margaritaville_flutter/features/housekeeper_catalog/domain/commands/housekeeper_catalog_command.dart';
import 'package:margaritaville_flutter/shared/persistence/app_database.dart';

void main() {
  test(
    'same command ID with different catalog input rolls back completely',
    () async {
      final database = AppDatabase.inMemory();
      addTearDown(database.close);
      final repository = DriftHousekeeperCatalogRepository(database);
      final handler = HousekeeperCatalogCommandHandler(repository);
      final now = DateTime.utc(2027, 2, 10, 12);
      await repository.ensureDefaults(now);
      await handler.execute(
        AddHousekeeperCommand(
          commandId: 'catalog-collision',
          issuedAt: now.add(const Duration(minutes: 1)),
          displayName: 'First Person',
        ),
      );

      await expectLater(
        handler.execute(
          AddHousekeeperCommand(
            commandId: 'catalog-collision',
            issuedAt: now.add(const Duration(minutes: 2)),
            displayName: 'Second Person',
          ),
        ),
        throwsStateError,
      );

      final active = await repository.loadActive();
      expect(active.where((value) => value.id == 'first-person'), hasLength(1));
      expect(active.where((value) => value.id == 'second-person'), isEmpty);
      expect(
        await database.select(database.commandReceiptRecords).get(),
        hasLength(1),
      );
      expect(
        await database.select(database.historyEventRecords).get(),
        hasLength(1),
      );
      expect(
        await database.select(database.syncOutboxRecords).get(),
        hasLength(1),
      );
    },
  );
}
