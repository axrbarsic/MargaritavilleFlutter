import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/housekeeper_catalog/domain/models/housekeeper.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/hotel_profile.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/room_state.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/room_timestamps.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_assignment.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_session.dart';
import 'package:margaritaville_flutter/features/work_setup/presentation/widgets/setup_room_grid.dart';

void main() {
  testWidgets('blocked room resolves owner label from live catalog by ID', (
    tester,
  ) async {
    final now = DateTime.utc(2027, 2, 10, 12);
    final owner = _assignment(
      'owner',
      'Owner Snapshot',
      1,
      now,
      ownsRoom: true,
    );
    final selected = _assignment('selected', 'Selected Snapshot', 2, now);
    final session = WorkSession.create(
      id: 'session',
      hotel: HotelProfile.margaritaville,
      startedAt: now,
      assignments: [owner, selected],
    );

    await tester.pumpWidget(_app(session, selected, const {}));
    expect(find.text('Owner Snapshot'), findsOneWidget);

    final liveOwner = Housekeeper(
      id: 'owner',
      displayName: 'Owner Live',
      paletteKey: 'ruby',
      updatedAt: now.add(const Duration(minutes: 1)),
    );
    await tester.pumpWidget(_app(session, selected, {'owner': liveOwner}));
    await tester.pump();

    expect(find.text('Owner Snapshot'), findsNothing);
    expect(find.text('Owner Live'), findsOneWidget);
    final semantics = tester.getSemantics(
      find.byKey(const Key('setup-room-101')),
    );
    expect(semantics.value, 'занят Owner Live');
  });
}

Widget _app(
  WorkSession session,
  WorkAssignment selected,
  Map<String, Housekeeper> catalogById,
) {
  return MaterialApp(
    home: Scaffold(
      body: SetupRoomGrid(
        roomNumbers: const ['101'],
        session: session,
        selectedAssignment: selected,
        catalogById: catalogById,
        onRoomTap: (_) {},
      ),
    ),
  );
}

WorkAssignment _assignment(
  String id,
  String name,
  int cart,
  DateTime now, {
  bool ownsRoom = false,
}) {
  return WorkAssignment(
    id: 'assignment-$id',
    cartNumber: cart,
    housekeeper: Housekeeper(
      id: id,
      displayName: name,
      paletteKey: 'aqua',
      updatedAt: now,
    ),
    assignedAt: now,
    updatedAt: now,
    rooms: [
      if (ownsRoom)
        RoomState(
          roomNumber: '101',
          phase: RoomPhase.pending,
          isVip: false,
          timestamps: RoomTimestamps(selectedAt: now, phaseUpdatedAt: now),
        ),
    ],
  );
}
