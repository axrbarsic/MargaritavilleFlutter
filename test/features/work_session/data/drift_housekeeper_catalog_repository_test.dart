import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/housekeeper_catalog/application/housekeeper_catalog_command_handler.dart';
import 'package:margaritaville_flutter/features/housekeeper_catalog/domain/commands/housekeeper_catalog_command.dart';
import 'package:margaritaville_flutter/features/housekeeper_catalog/domain/models/housekeeper_catalog_mutation.dart';
import 'package:margaritaville_flutter/features/work_session/data/repositories/drift_housekeeper_catalog_repository.dart';
import 'package:margaritaville_flutter/shared/persistence/app_database.dart';

void main() {
  late AppDatabase database;
  late DriftHousekeeperCatalogRepository repository;
  late HousekeeperCatalogCommandHandler handler;
  final now = DateTime.utc(2027, 2, 10, 12);

  setUp(() {
    database = AppDatabase.inMemory();
    repository = DriftHousekeeperCatalogRepository(database);
    handler = HousekeeperCatalogCommandHandler(repository);
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
      final result = await handler.execute(
        RenameHousekeeperCommand(
          commandId: 'rename-ketty',
          issuedAt: now.add(const Duration(minutes: 1)),
          housekeeperId: 'ketty',
          displayName: 'Ketty Updated',
        ),
      );
      expect(result.status, HousekeeperCatalogMutationStatus.changed);
      await repository.ensureDefaults(now.add(const Duration(days: 1)));

      final housekeepers = await repository.loadActive();
      expect(
        housekeepers.singleWhere((value) => value.id == 'ketty').displayName,
        'Ketty Updated',
      );
    },
  );

  test('add rename and palette are durable and field-specific', () async {
    await repository.ensureDefaults(now);
    final added = await handler.execute(
      AddHousekeeperCommand(
        commandId: 'add-zoe',
        issuedAt: now.add(const Duration(minutes: 1)),
        displayName: '  Zoë  ',
      ),
    );
    expect(added.housekeeper?.id, 'zoe');
    final renamed = await handler.execute(
      RenameHousekeeperCommand(
        commandId: 'rename-zoe',
        issuedAt: now.add(const Duration(minutes: 2)),
        housekeeperId: 'zoe',
        displayName: 'Zoë Updated',
      ),
    );
    final recolored = await handler.execute(
      SetHousekeeperPaletteCommand(
        commandId: 'palette-zoe',
        issuedAt: now.add(const Duration(minutes: 3)),
        housekeeperId: 'zoe',
        paletteKey: 'ruby',
      ),
    );

    expect(renamed.status, HousekeeperCatalogMutationStatus.changed);
    expect(recolored.status, HousekeeperCatalogMutationStatus.changed);
    final zoe = (await repository.loadActive()).singleWhere(
      (value) => value.id == 'zoe',
    );
    expect(zoe.displayName, 'Zoë Updated');
    expect(zoe.paletteKey, 'ruby');
  });

  test(
    'duplicate commands and duplicate names cannot duplicate rows',
    () async {
      await repository.ensureDefaults(now);
      final command = AddHousekeeperCommand(
        commandId: 'add-unique',
        issuedAt: now.add(const Duration(minutes: 1)),
        displayName: 'Unique Name',
      );

      expect(
        (await handler.execute(command)).status,
        HousekeeperCatalogMutationStatus.changed,
      );
      expect(
        (await handler.execute(command)).status,
        HousekeeperCatalogMutationStatus.ignored,
      );
      expect(
        (await handler.execute(
          AddHousekeeperCommand(
            commandId: 'add-same-name',
            issuedAt: now.add(const Duration(minutes: 2)),
            displayName: ' unique name ',
          ),
        )).status,
        HousekeeperCatalogMutationStatus.ignored,
      );
      expect(
        (await repository.loadActive()).where(
          (value) => value.displayName == 'Unique Name',
        ),
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
      expect(
        await database.select(database.commandReceiptRecords).get(),
        hasLength(2),
      );
    },
  );

  test(
    'authoritative event excludes names and contains final generated ID',
    () async {
      await repository.ensureDefaults(now);
      await handler.execute(
        AddHousekeeperCommand(
          commandId: 'private-name',
          issuedAt: now.add(const Duration(minutes: 1)),
          displayName: 'Private Person',
        ),
      );

      final event = await database
          .select(database.historyEventRecords)
          .getSingle();
      final payload = jsonDecode(event.payloadJson) as Map<String, Object?>;
      expect(payload['housekeeperId'], 'private-person');
      expect(payload.toString(), isNot(contains('Private Person')));
    },
  );

  test('tombstoned IDs remain reserved when a name is added again', () async {
    await repository.ensureDefaults(now);
    await (database.update(
      database.housekeeperCatalogRecords,
    )..where((row) => row.id.equals('ketty'))).write(
      HousekeeperCatalogRecordsCompanion(
        deletedAt: Value(now.add(const Duration(minutes: 1))),
      ),
    );

    final result = await handler.execute(
      AddHousekeeperCommand(
        commandId: 'add-ketty-again',
        issuedAt: now.add(const Duration(minutes: 2)),
        displayName: 'Ketty',
      ),
    );

    expect(result.housekeeper?.id, 'ketty-2');
    expect(
      (await repository.loadActive()).any((value) => value.id == 'ketty-2'),
      isTrue,
    );
  });

  test('concurrent add of the same name commits exactly one row', () async {
    await repository.ensureDefaults(now);
    final results = await Future.wait([
      handler.execute(
        AddHousekeeperCommand(
          commandId: 'concurrent-a',
          issuedAt: now.add(const Duration(minutes: 1)),
          displayName: 'Concurrent Person',
        ),
      ),
      handler.execute(
        AddHousekeeperCommand(
          commandId: 'concurrent-b',
          issuedAt: now.add(const Duration(minutes: 2)),
          displayName: ' concurrent person ',
        ),
      ),
    ]);

    expect(
      results.map((value) => value.status),
      unorderedEquals([
        HousekeeperCatalogMutationStatus.changed,
        HousekeeperCatalogMutationStatus.ignored,
      ]),
    );
    expect(
      (await repository.loadActive()).where(
        (value) => value.displayName == 'Concurrent Person',
      ),
      hasLength(1),
    );
    expect(
      await database.select(database.historyEventRecords).get(),
      hasLength(1),
    );
  });

  test(
    'invalid palette fails before receipt and duplicate rename is ignored',
    () async {
      await repository.ensureDefaults(now);
      expect(
        () => handler.execute(
          SetHousekeeperPaletteCommand(
            commandId: 'invalid-palette',
            issuedAt: now.add(const Duration(minutes: 1)),
            housekeeperId: 'ketty',
            paletteKey: 'not-a-palette',
          ),
        ),
        throwsArgumentError,
      );
      final result = await handler.execute(
        RenameHousekeeperCommand(
          commandId: 'duplicate-rename',
          issuedAt: now.add(const Duration(minutes: 2)),
          housekeeperId: 'ketty',
          displayName: 'Ana',
        ),
      );

      expect(result.status, HousekeeperCatalogMutationStatus.ignored);
      expect(
        await database.select(database.commandReceiptRecords).get(),
        hasLength(1),
      );
      expect(
        await database.select(database.historyEventRecords).get(),
        isEmpty,
      );
      expect(await database.select(database.syncOutboxRecords).get(), isEmpty);
    },
  );
}
