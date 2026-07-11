part of 'work_session.dart';

extension WorkSessionRoomAssignmentReplacement on WorkSession {
  WorkSessionMutation replaceAllRoomAssignments({
    required List<String> roomNumbers,
    required DateTime changedAt,
  }) {
    final active = activeAssignments.toList(growable: false);
    if (active.isEmpty) return _ignored();

    final normalized = roomNumbers
        .map((roomNumber) => roomNumber.trim())
        .toList(growable: false);
    final unique = normalized.toSet();
    if (normalized.length != MargaritavilleRoomCatalog.roomNumbers.length ||
        unique.length != normalized.length ||
        !unique.containsAll(MargaritavilleRoomCatalog.roomNumbers)) {
      throw ArgumentError.value(
        roomNumbers,
        'roomNumbers',
        'Expected every current catalog room exactly once.',
      );
    }

    final roomsByAssignment = List.generate(
      active.length,
      (_) => <RoomState>[],
      growable: false,
    );
    for (var index = 0; index < normalized.length; index++) {
      roomsByAssignment[index % active.length].add(
        RoomState.pending(roomNumber: normalized[index], selectedAt: changedAt),
      );
    }

    var activeIndex = 0;
    final nextAssignments = assignments
        .map((assignment) {
          if (assignment.deletedAt != null) return assignment;
          return assignment.copyWith(
            rooms: roomsByAssignment[activeIndex++],
            updatedAt: changedAt,
          );
        })
        .toList(growable: false);
    return WorkSessionMutation(
      session: _copy(assignments: nextAssignments, updatedAt: changedAt),
      status: WorkSessionMutationStatus.changed,
    );
  }
}
