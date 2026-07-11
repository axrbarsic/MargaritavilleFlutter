import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/app/margaritaville_theme.dart';
import 'package:margaritaville_flutter/core/time/clock.dart';
import 'package:margaritaville_flutter/core/time/clock_provider.dart';
import 'package:margaritaville_flutter/features/housekeeper_catalog/domain/models/housekeeper.dart';
import 'package:margaritaville_flutter/features/housekeeper_catalog/domain/models/housekeeper_catalog_command_descriptor.dart';
import 'package:margaritaville_flutter/features/housekeeper_catalog/domain/models/housekeeper_catalog_mutation.dart';
import 'package:margaritaville_flutter/features/housekeeper_catalog/domain/repositories/housekeeper_catalog_repository.dart';
import 'package:margaritaville_flutter/features/housekeeper_catalog/presentation/controllers/housekeeper_catalog_controller.dart';
import 'package:margaritaville_flutter/features/housekeeper_catalog/presentation/housekeeper_catalog_editor_screen.dart';
import 'package:margaritaville_flutter/shared/persistence/app_database_provider.dart';

void main() {
  late AppDatabase database;
  final now = DateTime.utc(2027, 2, 10, 12);

  setUp(() => database = AppDatabase.inMemory());
  tearDown(() => database.close());

  testWidgets('add rename and palette flow stays reactive and durable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_app(database, now));
    await tester.pumpAndSettle();

    expect(find.text('Уборщицы'), findsOneWidget);
    expect(find.byKey(const Key('housekeeper-row-ketty')), findsOneWidget);
    expect(
      find.text('Имена идут из свежих листов; список можно менять под смену.'),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byKey(const Key('housekeeper-add-submit'))),
      const Size(48, 48),
    );
    expect(
      tester.getSize(find.byKey(const Key('housekeeper-add-name'))).height,
      48,
    );
    expect(
      tester.getSize(find.byKey(const Key('housekeeper-name-kerlange'))).height,
      46,
    );
    expect(
      tester.getSize(find.byKey(const Key('housekeeper-palette-kerlange'))),
      const Size(38, 38),
    );

    await tester.enterText(
      find.byKey(const Key('housekeeper-add-name')),
      '  Zoë  ',
    );
    await tester.tap(find.byKey(const Key('housekeeper-add-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Zoë добавлена.'), findsOneWidget);
    final addedRow = find.byKey(const Key('housekeeper-row-zoe'));
    await tester.ensureVisible(addedRow);
    await tester.pumpAndSettle();
    expect(addedRow, findsOneWidget);

    final nameField = find.byKey(const Key('housekeeper-name-zoe'));
    await tester.enterText(nameField, 'Zoë Updated');
    tester.widget<TextField>(nameField).onSubmitted?.call('Zoë Updated');
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(tester.element(nameField));
    expect(
      container.read(housekeeperCatalogControllerProvider).message,
      'Zoë Updated сохранена.',
    );

    final palette = find.byKey(const Key('housekeeper-palette-zoe'));
    await tester.tap(palette);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ruby').last);
    await tester.pumpAndSettle();

    final row =
        (await database.select(database.housekeeperCatalogRecords).get())
            .singleWhere((value) => value.id == 'zoe');
    expect(row.displayName, 'Zoë Updated');
    expect(row.paletteKey, 'ruby');
    expect(
      container.read(housekeeperCatalogControllerProvider).message,
      'Цвет сохранён.',
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets(
    'blank add is ignored and narrow physical width does not overflow',
    (tester) async {
      tester.view.physicalSize = const Size(346, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _app(database, now, textScaler: const TextScaler.linear(1.15)),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('housekeeper-add-name')),
        '   ',
      );
      await tester.tap(find.byKey(const Key('housekeeper-add-submit')));
      await tester.pumpAndSettle();

      expect(find.text('Напиши имя перед добавлением.'), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(
        await database.select(database.housekeeperCatalogRecords).get(),
        hasLength(20),
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );

  testWidgets('write failure stays handled and preserves both drafts', (
    tester,
  ) async {
    final failing = _FailingCatalogRepository(now);
    await tester.pumpWidget(_app(database, now, repository: failing));
    await tester.pumpAndSettle();

    final addField = find.byKey(const Key('housekeeper-add-name'));
    await tester.enterText(addField, 'Retry Add');
    await tester.tap(find.byKey(const Key('housekeeper-add-submit')));
    await tester.pumpAndSettle();
    expect(find.text('Не удалось сохранить изменение.'), findsOneWidget);
    expect(tester.widget<TextField>(addField).controller?.text, 'Retry Add');

    final renameField = find.byKey(const Key('housekeeper-name-kerlange'));
    await tester.enterText(renameField, 'Retry Rename');
    tester.widget<TextField>(renameField).onSubmitted?.call('Retry Rename');
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(renameField).controller?.text,
      'Retry Rename',
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}

Widget _app(
  AppDatabase database,
  DateTime now, {
  TextScaler textScaler = TextScaler.noScaling,
  HousekeeperCatalogRepository? repository,
}) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(database),
      clockProvider.overrideWithValue(FixedClock(now)),
      if (repository != null)
        housekeeperCatalogRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp(
      theme: MargaritavilleTheme.dark,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
        child: child!,
      ),
      home: const HousekeeperCatalogEditorScreen(),
    ),
  );
}

final class _FailingCatalogRepository implements HousekeeperCatalogRepository {
  _FailingCatalogRepository(DateTime now)
    : value = Housekeeper(
        id: 'kerlange',
        displayName: 'Kerlange',
        paletteKey: 'aqua',
        updatedAt: now,
      );

  final Housekeeper value;

  @override
  Future<void> ensureDefaults(DateTime seededAt) async {}

  @override
  Future<List<Housekeeper>> loadActive() async => [value];

  @override
  Stream<List<Housekeeper>> watchActive() => Stream.value([value]);

  @override
  Future<HousekeeperCatalogMutation> commitCommand({
    required HousekeeperCatalogCommandDescriptor descriptor,
    required HousekeeperCatalogMutation Function(
      HousekeeperCatalogSnapshot snapshot,
    )
    mutate,
  }) async {
    throw StateError('disk failure');
  }
}
