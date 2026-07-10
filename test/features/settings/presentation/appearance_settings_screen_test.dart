import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/app/margaritaville_theme.dart';
import 'package:margaritaville_flutter/features/settings/domain/models/appearance_settings.dart';
import 'package:margaritaville_flutter/features/settings/domain/repositories/appearance_settings_repository.dart';
import 'package:margaritaville_flutter/features/settings/presentation/appearance_settings_screen.dart';
import 'package:margaritaville_flutter/features/settings/presentation/controllers/appearance_settings_controller.dart';

void main() {
  testWidgets('shows the working donor experimental visual controls', (
    tester,
  ) async {
    final repository = _MemoryAppearanceSettingsRepository();
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    expect(find.text('Настройки'), findsOneWidget);
    expect(find.text('Экспериментальное'), findsOneWidget);
    expect(find.text('Живые ячейки'), findsOneWidget);
    expect(find.text('VIP-желе'), findsOneWidget);
    expect(find.text('Скорость желе'), findsOneWidget);
    expect(find.text('VIP HDR-свет'), findsOneWidget);
    expect(find.text('HDR-всплеск статуса'), findsOneWidget);
    expect(find.text('Скорость пружины'), findsNothing);

    final statusPulse = find.byKey(const Key('setting-status-hdr-pulse'));
    await tester.ensureVisible(statusPulse);
    await tester.pumpAndSettle();
    await tester.tap(statusPulse);
    await tester.pumpAndSettle();

    expect(repository.value.statusHdrPulseEnabled, isTrue);
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
  });
}

Widget _app(
  AppearanceSettingsRepository repository, {
  TextScaler textScaler = TextScaler.noScaling,
}) {
  return ProviderScope(
    overrides: [
      appearanceSettingsRepositoryProvider.overrideWithValue(repository),
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
