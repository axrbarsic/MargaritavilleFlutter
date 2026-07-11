import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/app/margaritaville_theme.dart';
import 'package:margaritaville_flutter/features/interaction/domain/margaritaville_sound_routing.dart';
import 'package:margaritaville_flutter/features/interaction/domain/repositories/interaction_sound_settings_repository.dart';
import 'package:margaritaville_flutter/features/interaction/presentation/controllers/interaction_sound_settings_controller.dart';
import 'package:margaritaville_flutter/features/settings/domain/models/appearance_settings.dart';
import 'package:margaritaville_flutter/features/settings/domain/models/summary_grid_preference.dart';
import 'package:margaritaville_flutter/features/settings/domain/repositories/appearance_settings_repository.dart';
import 'package:margaritaville_flutter/features/settings/presentation/appearance_settings_screen.dart';
import 'package:margaritaville_flutter/features/settings/presentation/controllers/appearance_settings_controller.dart';

void main() {
  testWidgets('shows the working donor experimental visual controls', (
    tester,
  ) async {
    final repository = _MemoryAppearanceSettingsRepository();
    final soundRepository = _MemoryInteractionSoundSettingsRepository();
    await tester.pumpWidget(_app(repository, soundRepository: soundRepository));
    await tester.pumpAndSettle();

    expect(find.text('Настройки'), findsOneWidget);
    expect(find.text('Уборщицы'), findsOneWidget);
    expect(find.text('Изменить имена и цвета'), findsOneWidget);
    expect(find.text('Экспериментальное'), findsOneWidget);
    expect(find.text('Живые ячейки'), findsOneWidget);
    expect(find.text('VIP-желе'), findsOneWidget);
    expect(find.text('Сила пружины'), findsNothing);
    expect(find.text('Скорость желе'), findsNothing);
    expect(find.text('VIP HDR-свет'), findsOneWidget);
    expect(find.text('HDR-всплеск статуса'), findsOneWidget);
    expect(find.text('Сочная палитра'), findsOneWidget);
    expect(find.text('Скорость пружины'), findsNothing);
    expect(find.text('Фон приложения'), findsOneWidget);
    expect(find.text('Matrix'), findsOneWidget);
    expect(find.text('Выкл'), findsWidgets);
    expect(find.text('Звуки'), findsOneWidget);
    expect(find.text('Все остальные действия'), findsOneWidget);
    expect(find.text('Ячейка'), findsOneWidget);
    expect(find.text('Зелёная ячейка'), findsOneWidget);
    expect(find.text('Тестирование'), findsOneWidget);
    expect(
      find.text('Задействовать все номера отеля для теста'),
      findsOneWidget,
    );

    final statusPulse = find.byKey(const Key('setting-status-hdr-pulse'));
    await tester.ensureVisible(statusPulse);
    await tester.pumpAndSettle();
    await tester.tap(statusPulse);
    await tester.pumpAndSettle();

    expect(repository.value.statusHdrPulseEnabled, isTrue);

    final vividPalette = find.byKey(const Key('setting-vivid-status-palette'));
    await tester.ensureVisible(vividPalette);
    await tester.pumpAndSettle();
    await tester.tap(vividPalette);
    await tester.pumpAndSettle();

    expect(repository.value.vividStatusPaletteEnabled, isFalse);

    final roomSound = find.byKey(const Key('sound-picker-room'));
    await tester.ensureVisible(roomSound);
    await tester.pumpAndSettle();
    await tester.tap(roomSound);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Резкий сигнал').last);
    await tester.pumpAndSettle();

    expect(soundRepository.value.room, MargaritavilleSoundAsset.uiAlertSnap);
  });

  testWidgets('settings stay intact at physical Pixel width and font scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(346, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = _MemoryAppearanceSettingsRepository();

    await tester.pumpWidget(
      _app(repository, textScaler: const TextScaler.linear(1.15)),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('appearance-settings-header')), findsOneWidget);
    expect(find.byKey(const Key('setting-vip-jelly')), findsOneWidget);
    final allRoomsAction = find.byKey(
      const Key('settings-use-all-hotel-rooms'),
    );
    await tester.ensureVisible(allRoomsAction);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('summary grid selector persists three columns', (tester) async {
    final repository = _MemoryAppearanceSettingsRepository();
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    final selector = find.byKey(const Key('setting-summary-grid-columns'));
    await tester.ensureVisible(selector);
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(of: selector, matching: find.text('3')).first,
    );
    await tester.pumpAndSettle();

    expect(repository.value.summaryGridPreference, SummaryGridPreference.three);
  });
}

Widget _app(
  AppearanceSettingsRepository repository, {
  InteractionSoundSettingsRepository? soundRepository,
  TextScaler textScaler = TextScaler.noScaling,
}) {
  return ProviderScope(
    overrides: [
      appearanceSettingsRepositoryProvider.overrideWithValue(repository),
      interactionSoundSettingsRepositoryProvider.overrideWithValue(
        soundRepository ?? _MemoryInteractionSoundSettingsRepository(),
      ),
    ],
    child: MaterialApp(
      theme: MargaritavilleTheme.dark,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
        child: child!,
      ),
      home: const AppearanceSettingsScreen(),
    ),
  );
}

final class _MemoryInteractionSoundSettingsRepository
    implements InteractionSoundSettingsRepository {
  MargaritavilleSoundAssignments value =
      MargaritavilleSoundAssignments.defaults;

  @override
  Future<MargaritavilleSoundAssignments> load() async => value;

  @override
  Future<void> save(MargaritavilleSoundAssignments assignments) async {
    value = assignments;
  }
}

final class _MemoryAppearanceSettingsRepository
    implements AppearanceSettingsRepository {
  AppearanceSettings value = AppearanceSettings.defaults;

  @override
  Future<AppearanceSettings> load() async => value;

  @override
  Future<void> save(AppearanceSettings settings) async {
    value = settings;
  }
}
