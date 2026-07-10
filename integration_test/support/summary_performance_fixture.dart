import 'package:margaritaville_flutter/features/work_session/domain/models/hotel_profile.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/housekeeper.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/room_state.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/room_timestamps.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_assignment.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_session.dart';

WorkSession summaryPerformanceSession({Set<int> vipRoomIndexes = const {0}}) {
  final startedAt = DateTime(2027, 2, 10, 8, 17);
  const roomGroups = [
    [
      '101',
      '102',
      '103',
      '104',
      '105',
      '106',
      '107',
      '108',
      '109',
      '110',
      '111',
      '112',
    ],
    [
      '143',
      '144',
      '145',
      '146',
      '147',
      '148',
      '149',
      '150',
      '151',
      '152',
      '153',
      '154',
    ],
    [
      '201',
      '202',
      '203',
      '204',
      '205',
      '206',
      '207',
      '208',
      '209',
      '210',
      '211',
      '212',
    ],
  ];
  const names = ['Ketty', 'Omelene PM', 'Simone'];
  const paletteKeys = ['ruby', 'violet', 'amber'];

  final assignments = [
    for (
      var assignmentIndex = 0;
      assignmentIndex < roomGroups.length;
      assignmentIndex++
    )
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
          for (
            var roomIndex = 0;
            roomIndex < roomGroups[assignmentIndex].length;
            roomIndex++
          )
            _room(
              roomGroups[assignmentIndex][roomIndex],
              index: assignmentIndex * 12 + roomIndex,
              startedAt: startedAt,
              isVip: vipRoomIndexes.contains(assignmentIndex * 12 + roomIndex),
            ),
        ],
      ),
  ];

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
