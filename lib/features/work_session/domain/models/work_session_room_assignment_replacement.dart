part of 'work_session.dart';

extension WorkSessionRoomAssignmentReplacement on WorkSession {
  WorkSessionMutation replaceAllRoomAssignments({
    required List<String> roomNumbers,
    required List<Housekeeper> housekeepers,
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
    final roomsByAssignment = List.generate(
      activeHousekeepers.length,
      (_) => <RoomState>[],
      growable: false,
    );
    for (var index = 0; index < normalized.length; index++) {
      final roomNumber = normalized[index];
      roomsByAssignment[index % activeHousekeepers.length].add(
        existingRooms[roomNumber] ??
            RoomState.pending(roomNumber: roomNumber, selectedAt: changedAt),
      );
    }

    final nextAssignments = <WorkAssignment>[
      for (var index = 0; index < activeHousekeepers.length; index++)
        WorkAssignment(
          id: 'test-work-item-${index + 1}-${changedAt.microsecondsSinceEpoch}',
          cartNumber: index + 1,
          housekeeper: activeHousekeepers[index],
          territoryId: _territoryForAssignedRooms(
            roomsByAssignment[index],
            cartNumber: index + 1,
          ),
          assignedAt: changedAt,
          updatedAt: changedAt,
          rooms: roomsByAssignment[index],
        ),
    ];
    return WorkSessionMutation(
      session: _copy(assignments: nextAssignments, updatedAt: changedAt),
      status: WorkSessionMutationStatus.changed,
    );
  }
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
