import 'package:margaritaville_flutter/features/work_session/application/all_rooms_test_data_generator.dart';
import 'package:margaritaville_flutter/features/work_session/domain/catalogs/margaritaville_room_catalog.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/hotel_profile.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/housekeeper.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/room_state.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/room_timestamps.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_assignment.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_session.dart';

final int summaryPerformanceRoomCount =
    AllRoomsTestDataGenerator.orderedRoomNumbers.length;

WorkSession summaryPerformanceSession({
  required int vipRoomCount,
  int? roomCount,
}) {
  final startedAt = DateTime(2027, 2, 10, 8, 17);
  const names = ['Ketty', 'Omelene PM', 'Simone', 'Bebita', 'Nadia', 'Marlene'];
  const paletteKeys = ['ruby', 'violet', 'amber', 'aqua', 'mint', 'coral'];
  final targetRoomCount = (roomCount ?? summaryPerformanceRoomCount).clamp(
    1,
    summaryPerformanceRoomCount,
  );
  var globalRoomIndex = 0;
  var remainingRooms = targetRoomCount;
  final assignments = <WorkAssignment>[];

  for (
    var assignmentIndex = 0;
    assignmentIndex < MargaritavilleRoomCatalog.territories.length &&
        remainingRooms > 0;
    assignmentIndex++
  ) {
    final territoryRooms = AllRoomsTestDataGenerator.orderedRoomNumbers
        .skip(globalRoomIndex)
        .take(
          MargaritavilleRoomCatalog.territories[assignmentIndex].rooms.length,
        )
        .take(remainingRooms)
        .toList(growable: false);
    remainingRooms -= territoryRooms.length;
    assignments.add(
      WorkAssignment(
        id: 'performance-assignment-$assignmentIndex',
        cartNumber: assignmentIndex + 1,
        housekeeper: Housekeeper(
          id: 'performance-housekeeper-$assignmentIndex',
          displayName: names[assignmentIndex],
          paletteKey: paletteKeys[assignmentIndex],
          updatedAt: startedAt,
        ),
        assignedAt: startedAt,
        updatedAt: startedAt,
        rooms: [
          for (final roomNumber in territoryRooms)
            _room(
              roomNumber,
              index: globalRoomIndex,
              startedAt: startedAt,
              isVip: globalRoomIndex++ < vipRoomCount,
            ),
        ],
      ),
    );
  }

  return WorkSession.create(
    id: 'summary-performance-v1',
    hotel: HotelProfile.margaritaville,
    startedAt: startedAt,
    assignments: assignments,
  ).lockWorkday(changedAt: startedAt.add(const Duration(minutes: 1)));
}

RoomState _room(
  String roomNumber, {
  required int index,
  required DateTime startedAt,
  required bool isVip,
}) {
  final phase = RoomPhase.values[index % RoomPhase.values.length];
  final phaseAt = startedAt.add(Duration(minutes: index));
  return RoomState(
    roomNumber: roomNumber,
    phase: phase,
    isVip: isVip,
    timestamps: RoomTimestamps(
      selectedAt: startedAt,
      phaseUpdatedAt: phaseAt,
      openedAt: phase == RoomPhase.pending ? null : phaseAt,
      completedAt: phase == RoomPhase.ready ? phaseAt : null,
      vipUpdatedAt: isVip ? phaseAt : null,
    ),
  );
}
