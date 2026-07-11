part of 'work_session.dart';

extension WorkSessionSetupActions on WorkSession {
  WorkAssignment? assignmentForHousekeeper(String housekeeperId) {
    for (final candidate in activeAssignments) {
      if (candidate.housekeeper.id == housekeeperId) return candidate;
    }
    return null;
  }

  WorkSessionMutation toggleHousekeeperWorkItem({
    required String housekeeperId,
    required String displayName,
    required String paletteKey,
    required DateTime changedAt,
  }) {
    if (workdayLocked) return _ignored();
    final normalizedId = housekeeperId.trim();
    final normalizedName = displayName.trim();
    if (normalizedId.isEmpty || normalizedName.isEmpty) return _ignored();
    final existing = assignmentForHousekeeper(normalizedId);
    if (existing != null) {
      final tombstoned = existing.copyWith(
        updatedAt: changedAt,
        deletedAt: changedAt,
        rooms: [
          for (final room in existing.rooms)
            if (room.isDeleted) room else room.tombstone(changedAt: changedAt),
        ],
      );
      return WorkSessionMutation(
        session: _copy(
          assignments: [
            for (final value in assignments)
              if (value.id == existing.id) tombstoned else value,
          ],
          updatedAt: changedAt,
        ),
        status: WorkSessionMutationStatus.changed,
      );
    }
    final occupiedCartNumbers = activeAssignments
        .map((value) => value.cartNumber)
        .toSet();
    int? nextCartNumber;
    for (var candidate = 1; candidate <= 100; candidate++) {
      if (!occupiedCartNumbers.contains(candidate)) {
        nextCartNumber = candidate;
        break;
      }
    }
    if (nextCartNumber == null) return _ignored();
    final territoryId = MargaritavilleRoomCatalog.preferredTerritoryId(
      nextCartNumber,
      boundTerritoryIds: activeAssignments.map((value) => value.territoryId),
    );
    final housekeeper = Housekeeper(
      id: normalizedId,
      displayName: normalizedName,
      paletteKey: paletteKey,
      updatedAt: changedAt,
    );
    final reusable = assignments.cast<WorkAssignment?>().firstWhere(
      (value) =>
          value?.cartNumber == nextCartNumber && value?.deletedAt != null,
      orElse: () => null,
    );
    final assignment = reusable == null
        ? WorkAssignment.create(
            id: _uniqueAssignmentId('work-item-$nextCartNumber'),
            cartNumber: nextCartNumber,
            housekeeper: housekeeper,
            assignedAt: changedAt,
            territoryId: territoryId,
          )
        : reusable.copyWith(
            housekeeper: housekeeper,
            territoryId: territoryId,
            updatedAt: changedAt,
            deletedAt: null,
          );
    return WorkSessionMutation(
      session: _copy(
        assignments: reusable == null
            ? [...assignments, assignment]
            : [
                for (final value in assignments)
                  if (value.id == reusable.id) assignment else value,
              ],
        updatedAt: changedAt,
      ),
      status: WorkSessionMutationStatus.changed,
    );
  }

  WorkSessionMutation setAssignmentTerritory({
    required String assignmentId,
    required String territoryId,
    required DateTime changedAt,
  }) {
    if (workdayLocked ||
        MargaritavilleRoomCatalog.territory(territoryId) == null) {
      return _ignored();
    }
    final current = assignment(assignmentId);
    if (current == null || current.territoryId == territoryId) {
      return _ignored();
    }
    return _replaceAssignment(
      current.copyWith(territoryId: territoryId, updatedAt: changedAt),
      changedAt: changedAt,
    );
  }

  WorkSessionMutation assignRoom({
    required String assignmentId,
    required String roomNumber,
    required DateTime changedAt,
  }) {
    final normalizedRoomNumber = roomNumber.trim();
    if (workdayLocked ||
        !MargaritavilleRoomCatalog.contains(normalizedRoomNumber)) {
      return _ignored();
    }
    final target = assignment(assignmentId);
    if (target == null) return _ignored();
    for (final owner in activeAssignments) {
      final existing = owner.room(normalizedRoomNumber);
      if (existing == null) continue;
      if (owner.id == assignmentId) return _ignored();
      return WorkSessionMutation(
        session: this,
        status: WorkSessionMutationStatus.blocked,
        conflict: RoomAssignmentConflict(
          roomNumber: normalizedRoomNumber,
          ownerAssignmentId: owner.id,
          ownerHousekeeperId: owner.housekeeper.id,
        ),
      );
    }
    final room = RoomState.pending(
      roomNumber: normalizedRoomNumber,
      selectedAt: changedAt,
    );
    final nextAssignments = assignments.map((assignment) {
      if (assignment.id == target.id) {
        return assignment.replacingRoom(room, changedAt: changedAt);
      }
      if (assignment.rooms.any(
        (candidate) =>
            candidate.roomNumber == normalizedRoomNumber && candidate.isDeleted,
      )) {
        return assignment.removingRoomRecord(
          normalizedRoomNumber,
          changedAt: changedAt,
        );
      }
      return assignment;
    }).toList();
    return WorkSessionMutation(
      session: _copy(assignments: nextAssignments, updatedAt: changedAt),
      status: WorkSessionMutationStatus.changed,
    );
  }

  WorkSessionMutation unassignRoom({
    required String assignmentId,
    required String roomNumber,
    required DateTime changedAt,
  }) {
    if (workdayLocked) return _ignored();
    final normalizedRoomNumber = roomNumber.trim();
    final owner = assignment(assignmentId);
    final current = owner?.room(normalizedRoomNumber);
    if (owner == null || current == null) return _ignored();
    return _replaceAssignment(
      owner.replacingRoom(
        current.tombstone(changedAt: changedAt),
        changedAt: changedAt,
      ),
      changedAt: changedAt,
    );
  }

  WorkSessionMutation toggleRoomSelection({
    required String assignmentId,
    required String roomNumber,
    required DateTime changedAt,
  }) {
    final normalizedRoomNumber = roomNumber.trim();
    final target = assignment(assignmentId);
    if (target?.room(normalizedRoomNumber) != null) {
      return unassignRoom(
        assignmentId: assignmentId,
        roomNumber: normalizedRoomNumber,
        changedAt: changedAt,
      );
    }
    return assignRoom(
      assignmentId: assignmentId,
      roomNumber: normalizedRoomNumber,
      changedAt: changedAt,
    );
  }

  String _uniqueAssignmentId(String preferred) {
    final ids = assignments.map((value) => value.id).toSet();
    if (!ids.contains(preferred)) return preferred;
    var suffix = 2;
    while (ids.contains('$preferred-$suffix')) {
      suffix += 1;
    }
    return '$preferred-$suffix';
  }
}
