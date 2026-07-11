import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/app/margaritaville_app.dart';
import 'package:margaritaville_flutter/core/time/clock.dart';
import 'package:margaritaville_flutter/features/settings/domain/models/app_background_mode.dart';
import 'package:margaritaville_flutter/features/settings/domain/models/appearance_settings.dart';
import 'package:margaritaville_flutter/features/settings/domain/repositories/appearance_settings_repository.dart';
import 'package:margaritaville_flutter/features/settings/presentation/controllers/appearance_settings_controller.dart';
import 'package:margaritaville_flutter/features/summary/presentation/summary_screen.dart';
import 'package:margaritaville_flutter/features/work_session/data/repositories/drift_work_session_repository.dart';
import 'package:margaritaville_flutter/features/work_session/presentation/controllers/work_session_controller.dart';
import 'package:margaritaville_flutter/shared/edr/edr_overlay_controller.dart';
import 'package:margaritaville_flutter/shared/persistence/app_database_provider.dart';

void main() {
  testWidgets('setup persists a room and opens the real summary shell', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final database = AppDatabase.inMemory();
    addTearDown(database.close);
    final repository = DriftWorkSessionRepository(database);
    final appearanceRepository = _MemoryAppearanceSettingsRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clockProvider.overrideWithValue(
            FixedClock(DateTime.utc(2027, 2, 10, 12)),
          ),
          workSessionRepositoryProvider.overrideWithValue(repository),
          appDatabaseProvider.overrideWithValue(database),
          appearanceSettingsRepositoryProvider.overrideWithValue(
            appearanceRepository,
          ),
        ],
        child: const MargaritavilleApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Рабочий список'), findsOneWidget);
    expect(find.text('Kerlange'), findsOneWidget);
    await tester.tap(find.byKey(const Key('setup-housekeeper-kerlange')));
    await tester.pumpAndSettle();
    expect(find.text('A1'), findsOneWidget);
    await tester.tap(find.byKey(const Key('setup-room-101')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('lock-workday')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('summary-header')), findsOneWidget);
    expect(find.byKey(const Key('summary-room-101')), findsOneWidget);
    expect(find.byKey(const Key('summary-total-count')), findsOneWidget);

    await tester.longPress(find.byKey(const Key('summary-open-settings')));
    await tester.pumpAndSettle(
      EdrOverlayController.presentationSuspendDeadline,
    );
    expect(find.text('Экспериментальное'), findsOneWidget);
    final statusPulse = find.byKey(const Key('setting-status-hdr-pulse'));
    await tester.ensureVisible(statusPulse);
    await tester.pumpAndSettle();
    await tester.tap(statusPulse);
    await tester.pumpAndSettle();
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<SummaryScreen>(find.byType(SummaryScreen))
          .visualPolicy
          .statusPulseEnabled,
      isTrue,
    );

    await tester.longPress(find.byKey(const Key('summary-room-101')));
    await tester.pumpAndSettle();

    final saved = await repository.loadLatestSession();
    expect(saved?.room('101')?.phase.name, 'open');
  });
}

final class _MemoryAppearanceSettingsRepository
    implements AppearanceSettingsRepository {
  AppearanceSettings value = AppearanceSettings.defaults.copyWith(
    backgroundMode: AppBackgroundMode.off,
  );

  @override
  Future<AppearanceSettings> load() async => value;

  @override
  Future<void> save(AppearanceSettings settings) async {
    value = settings;
  }
}
