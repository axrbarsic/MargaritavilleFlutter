import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/app/margaritaville_app.dart';
import 'package:margaritaville_flutter/core/time/clock.dart';
import 'package:margaritaville_flutter/features/work_session/data/local/app_database.dart';
import 'package:margaritaville_flutter/features/work_session/data/repositories/drift_work_session_repository.dart';
import 'package:margaritaville_flutter/features/work_session/presentation/controllers/work_session_controller.dart';

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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clockProvider.overrideWithValue(
            FixedClock(DateTime.utc(2027, 2, 10, 12)),
          ),
          workSessionRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MargaritavilleApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Настройка смены'), findsOneWidget);
    expect(find.text('Ketty'), findsOneWidget);
    expect(find.text('A1'), findsOneWidget);

    await tester.longPress(find.byKey(const Key('setup-room-101')));
    await tester.pumpAndSettle();
    await tester.longPress(find.byKey(const Key('lock-workday')));
    await tester.pumpAndSettle();

    expect(find.text('Текущая смена'), findsOneWidget);
    expect(find.byKey(const Key('summary-room-101')), findsOneWidget);
    expect(find.text('Всего 1'), findsOneWidget);

    await tester.longPress(find.byKey(const Key('summary-room-101')));
    await tester.pumpAndSettle();

    final saved = await repository.loadLatestSession();
    expect(saved?.room('101')?.phase.name, 'open');
  });
}
