import 'package:margaritaville_flutter/features/work_session/domain/models/hotel_profile.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/housekeeper.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/room_state.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/room_timestamps.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_assignment.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_session.dart';

WorkSession donorSession() {
  final startedAt = DateTime(2027, 2, 10, 20, 47);
  return WorkSession.create(
    id: 'donor-summary-fixture',
    hotel: HotelProfile.margaritaville,
    startedAt: startedAt,
    assignments: [donorAssignment()],
  ).lockWorkday(changedAt: startedAt.add(const Duration(minutes: 1)));
}

WorkAssignment donorAssignment({String housekeeperName = 'Ketty'}) {
  final selectedAt = DateTime(2027, 2, 10, 20, 47);
  return WorkAssignment(
    id: 'work-block-1',
    cartNumber: 1,
    housekeeper: Housekeeper(
      id: 'ketty',
      displayName: housekeeperName,
      paletteKey: 'ruby',
      updatedAt: selectedAt,
    ),
    assignedAt: selectedAt,
    updatedAt: selectedAt,
    rooms: [
      for (final number in ['101', '102', '103', '104', '105', '106', '107'])
        donorRoom(number, selectedAt: selectedAt),
      donorRoom('143', selectedAt: selectedAt),
    ],
  );
}

RoomState donorRoom(String roomNumber, {required DateTime selectedAt}) {
  return RoomState(
    roomNumber: roomNumber,
    phase: RoomPhase.pending,
    isVip: false,
    timestamps: RoomTimestamps(
      selectedAt: selectedAt,
      phaseUpdatedAt: selectedAt,
    ),
  );
}
