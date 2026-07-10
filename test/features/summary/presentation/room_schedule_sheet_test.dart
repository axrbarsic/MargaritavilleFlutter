import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/app/margaritaville_theme.dart';
import 'package:margaritaville_flutter/features/summary/presentation/widgets/room_schedule_sheet.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/room_state.dart';

void main() {
  testWidgets('schedule sheet exposes donor wheels, set and clear actions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(440, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime(2027, 2, 10, 10, 7);
    final room = RoomState.pending(roomNumber: '101', selectedAt: now);
    DateTime? scheduledFor;
    var clears = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: MargaritavilleTheme.dark,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                key: const Key('open-schedule'),
                onPressed: () {
                  showRoomScheduleSheet(
                    context: context,
                    room: room,
                    now: now,
                    onSet: (date) => scheduledFor = date,
                    onClear: () => clears++,
                  );
                },
                child: const Text('Открыть'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('open-schedule')));
    await tester.pumpAndSettle();
    expect(find.text('Время открытия'), findsOneWidget);
    expect(find.text('Комната 101'), findsOneWidget);
    expect(find.text('10:15 AM'), findsOneWidget);
    expect(find.text('Очистить'), findsOneWidget);
    expect(find.text('Установить'), findsOneWidget);

    await tester.tap(find.byKey(const Key('schedule-set')));
    await tester.pumpAndSettle();
    expect(scheduledFor, DateTime(2027, 2, 10, 10, 15));

    await tester.tap(find.byKey(const Key('open-schedule')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('schedule-clear')));
    await tester.pumpAndSettle();
    expect(clears, 1);
  });
}
