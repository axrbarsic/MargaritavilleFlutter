import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/app/margaritaville_theme.dart';
import 'package:margaritaville_flutter/features/summary/presentation/summary_screen.dart';
import 'package:margaritaville_flutter/features/summary/presentation/widgets/summary_selection_puzzle_handle.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/hotel_profile.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/housekeeper.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/room_state.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_assignment.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_session.dart';

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
