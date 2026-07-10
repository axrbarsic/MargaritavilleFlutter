part of 'work_session.dart';

extension WorkSessionRoomActions on WorkSession {
  WorkSessionMutation setRoomVip({
    required String roomNumber,
    required bool isVip,
    required DateTime changedAt,
  }) {
    return _replaceRoomValue(
      roomNumber: roomNumber,
      changedAt: changedAt,
      transform: (room) => room.setVip(isVip: isVip, changedAt: changedAt),
    );
  }

  WorkSessionMutation setRoomSchedule({
    required String roomNumber,
    required DateTime? scheduledFor,
    required DateTime changedAt,
  }) {
    return _replaceRoomValue(
      roomNumber: roomNumber,
      changedAt: changedAt,
      transform: (room) =>
          room.schedule(scheduledFor: scheduledFor, changedAt: changedAt),
    );
  }

  WorkSessionMutation advanceScheduledRooms({required DateTime now}) {
    final roomNumbers = activeRooms
        .map((room) => room.roomNumber)
        .toList(growable: false);
    var next = this;
    var changed = false;
    for (final roomNumber in roomNumbers) {
      final mutation = next._replaceRoomValue(
        roomNumber: roomNumber,
        changedAt: now,
        transform: (room) {
          return room.advanceScheduledIfDue(now: now).room;
        },
      );
      if (mutation.status == WorkSessionMutationStatus.changed) {
        next = mutation.session;
        changed = true;
      }
    }
    return WorkSessionMutation(
      session: next,
      status: changed
          ? WorkSessionMutationStatus.changed
          : WorkSessionMutationStatus.ignored,
    );
  }

  WorkSessionMutation _replaceRoomValue({
    required String roomNumber,
    required DateTime changedAt,
    required RoomState Function(RoomState room) transform,
  }) {
    for (final owner in activeAssignments) {
      final current = owner.room(roomNumber);
      if (current == null) continue;
      final replacement = transform(current);
      if (replacement == current) return _ignored();
      return _replaceAssignment(
        owner.replacingRoom(replacement, changedAt: changedAt),
        changedAt: changedAt,
      );
    }
    return _ignored();
  }
}
