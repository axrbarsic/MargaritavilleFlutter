import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/app/margaritaville_theme.dart';
import 'package:margaritaville_flutter/features/summary/presentation/summary_screen.dart';
import 'package:margaritaville_flutter/features/summary/presentation/widgets/room_status_tile.dart';
import 'package:margaritaville_flutter/features/summary/presentation/widgets/summary_selection_puzzle_handle.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/hotel_profile.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/housekeeper.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/room_state.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_assignment.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_session.dart';
import 'package:margaritaville_flutter/shared/edr/edr_overlay_controller.dart';
import 'package:margaritaville_flutter/shared/persistence/app_database_provider.dart';

void main() {
  testWidgets('status chip filters rooms and toggles back to all', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(440, 956);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: MargaritavilleTheme.dark,
          home: SummaryScreen(session: _mixedSession()),
        ),
      ),
    );

    expect(find.byKey(const Key('summary-room-101')), findsOneWidget);
    expect(find.byKey(const Key('summary-room-102')), findsOneWidget);

    await tester.tap(find.byKey(const Key('summary-filter-open')));
    await tester.pump();

    expect(find.byKey(const Key('summary-room-101')), findsOneWidget);
    expect(find.byKey(const Key('summary-room-102')), findsNothing);

    await tester.tap(find.byKey(const Key('summary-filter-open')));
    await tester.pump();

    expect(find.byKey(const Key('summary-room-102')), findsOneWidget);
  });

  testWidgets('puzzle unlock requires a complete right-to-left drag', (
    tester,
  ) async {
    var completions = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 440,
              height: 48,
              child: SummarySelectionPuzzleHandle(
                onComplete: () => completions++,
              ),
            ),
          ),
        ),
      ),
    );

    final topLeft = tester.getTopLeft(
      find.byType(SummarySelectionPuzzleHandle),
    );
    await tester.dragFrom(
      topLeft + const Offset(400, 24),
      const Offset(-90, 0),
    );
    await tester.pump();
    expect(completions, 0);

    await tester.dragFrom(
      topLeft + const Offset(400, 24),
      const Offset(-380, 0),
    );
    await tester.pump();
    expect(completions, 1);
  });

  testWidgets('pending room right swipe opens the complete typed action menu', (
    tester,
  ) async {
    var vipToggles = 0;
    final room = RoomState.pending(
      roomNumber: '101',
      selectedAt: DateTime(2027, 2, 10, 20, 47),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: MargaritavilleTheme.dark,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 96,
              height: 98,
              child: RoomStatusTile(
                room: room,
                onAdvance: () {},
                onReset: () {},
                onToggleVip: () => vipToggles++,
                onSchedule: () {},
                onOpenMedia: () {},
              ),
            ),
          ),
        ),
      ),
    );

    final tile = find.byKey(const Key('summary-room-101'));
    await tester.timedDrag(
      tile,
      const Offset(55, 0),
      const Duration(milliseconds: 500),
    );
    await tester.pumpAndSettle();
    expect(find.text('Голос/медиа'), findsNothing);

    await tester.timedDrag(
      tile,
      const Offset(72, 0),
      const Duration(milliseconds: 500),
    );
    await tester.pumpAndSettle();
    expect(find.text('Комната 101'), findsOneWidget);
    expect(find.text('Голос/медиа'), findsOneWidget);
    expect(find.text('VIP включить'), findsOneWidget);
    expect(find.text('Назначить время'), findsOneWidget);
    expect(find.text('Вернуть в жёлтый'), findsNothing);

    await tester.tap(find.byKey(const Key('room-action-vip')));
    await tester.pumpAndSettle();
    expect(vipToggles, 1);
  });

  testWidgets('media action opens real Room Details route and returns', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(440, 956);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final database = AppDatabase.inMemory();
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          theme: MargaritavilleTheme.dark,
          home: SummaryScreen(session: _mixedSession()),
        ),
      ),
    );

    final tile = find.byKey(const Key('summary-room-101'));
    await tester.timedDrag(
      tile,
      const Offset(72, 0),
      const Duration(milliseconds: 500),
    );
    await tester.pumpAndSettle(
      EdrOverlayController.presentationSuspendDeadline,
    );
    await tester.tap(find.byKey(const Key('room-action-media')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('room-details-screen')), findsOneWidget);
    expect(find.byKey(const Key('room-details-room-number')), findsOneWidget);
    expect(find.text('101'), findsWidgets);
    expect(find.text('Голос/медиа'), findsOneWidget);
    expect(
      find.textContaining('следующий platform-services блок'),
      findsNothing,
    );

    await tester.tap(find.byKey(const Key('room-details-back')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('room-details-screen')), findsNothing);
    expect(find.byKey(const Key('summary-room-101')), findsOneWidget);
  });
}

WorkSession _mixedSession() {
  final startedAt = DateTime(2027, 2, 10, 20, 47);
  final assignment = WorkAssignment(
    id: 'work-block-1',
    cartNumber: 1,
    housekeeper: Housekeeper(
      id: 'ketty',
      displayName: 'Ketty',
      paletteKey: 'ruby',
      updatedAt: startedAt,
    ),
    assignedAt: startedAt,
    updatedAt: startedAt,
    rooms: [
      RoomState.pending(roomNumber: '101', selectedAt: startedAt),
      RoomState.pending(roomNumber: '102', selectedAt: startedAt),
    ],
  );
  final created = WorkSession.create(
    id: 'mixed-summary-fixture',
    hotel: HotelProfile.margaritaville,
    startedAt: startedAt,
    assignments: [assignment],
  );
  final opened = created.advanceRoom(
    roomNumber: '101',
    changedAt: startedAt.add(const Duration(minutes: 1)),
  );
  return opened.session.lockWorkday(
    changedAt: startedAt.add(const Duration(minutes: 2)),
  );
}
