part of 'work_session.dart';

extension WorkSessionRoomAssignmentReplacement on WorkSession {
  WorkSessionMutation replaceAllRoomAssignments({
    required List<String> roomNumbers,
    required List<Housekeeper> housekeepers,
    List<RoomState>? testRooms,
    required DateTime changedAt,
  }) {
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

    final uniqueHousekeepers = <Housekeeper>[];
    final seenHousekeeperIds = <String>{};
    for (final housekeeper in housekeepers) {
      if (seenHousekeeperIds.add(housekeeper.id)) {
        uniqueHousekeepers.add(housekeeper);
      }
    }
    if (uniqueHousekeepers.isEmpty) return _ignored();
    final maximumCartCount = normalized.length < 100 ? normalized.length : 100;
    final activeCount = uniqueHousekeepers.length.clamp(1, maximumCartCount);
    final activeHousekeepers = uniqueHousekeepers.take(activeCount).toList();

    final existingRooms = {
      for (final room in activeRooms) room.roomNumber: room,
    };
    final fixtureRooms = {
      for (final room in testRooms ?? const <RoomState>[])
        room.roomNumber: room,
    };
    if (fixtureRooms.isNotEmpty &&
        (fixtureRooms.length != normalized.length ||
            !fixtureRooms.keys.toSet().containsAll(unique))) {
      throw ArgumentError.value(
        testRooms,
        'testRooms',
        'Expected one test state for every room number.',
      );
    }
    final roomsByAssignment = List.generate(
      activeHousekeepers.length,
      (_) => <RoomState>[],
      growable: false,
    );
    for (var index = 0; index < normalized.length; index++) {
      final roomNumber = normalized[index];
      roomsByAssignment[index % activeHousekeepers.length].add(
        fixtureRooms[roomNumber] ??
            existingRooms[roomNumber] ??
            RoomState.pending(roomNumber: roomNumber, selectedAt: changedAt),
      );
    }

    final nextAssignments = <WorkAssignment>[
      for (var index = 0; index < activeHousekeepers.length; index++)
        _replacementAssignment(
          existing: assignments,
          cartNumber: index + 1,
          housekeeper: activeHousekeepers[index],
          rooms: roomsByAssignment[index],
          changedAt: changedAt,
        ),
    ];
    return WorkSessionMutation(
      session: _copy(assignments: nextAssignments, updatedAt: changedAt),
      status: WorkSessionMutationStatus.changed,
    );
  }
}

WorkAssignment _replacementAssignment({
  required List<WorkAssignment> existing,
  required int cartNumber,
  required Housekeeper housekeeper,
  required List<RoomState> rooms,
  required DateTime changedAt,
}) {
  final previous = existing.cast<WorkAssignment?>().firstWhere(
    (value) => value?.cartNumber == cartNumber,
    orElse: () => null,
  );
  final territoryId = _territoryForAssignedRooms(rooms, cartNumber: cartNumber);
  if (previous != null) {
    return previous.copyWith(
      housekeeper: housekeeper,
      territoryId: territoryId,
      updatedAt: changedAt,
      rooms: rooms,
      deletedAt: null,
    );
  }
  return WorkAssignment(
    id: 'test-work-item-$cartNumber',
    cartNumber: cartNumber,
    housekeeper: housekeeper,
    territoryId: territoryId,
    assignedAt: changedAt,
    updatedAt: changedAt,
    rooms: rooms,
  );
}

String _territoryForAssignedRooms(
  List<RoomState> rooms, {
  required int cartNumber,
}) {
  final sortedRoomNumbers = rooms.map((room) => room.roomNumber).toList()
    ..sort();
  if (sortedRoomNumbers.isNotEmpty) {
    final territory = MargaritavilleRoomCatalog.territoryForRoom(
      sortedRoomNumbers.first,
    );
    if (territory != null) return territory.id;
  }
  return MargaritavilleRoomCatalog.preferredTerritoryId(cartNumber);
}
