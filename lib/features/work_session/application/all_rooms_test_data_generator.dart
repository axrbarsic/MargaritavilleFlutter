import 'dart:math';

import '../../housekeeper_catalog/domain/models/housekeeper.dart';
import '../domain/catalogs/margaritaville_room_catalog.dart';
import '../domain/models/room_state.dart';
import '../domain/models/room_timestamps.dart';

final class AllRoomsTestData {
  AllRoomsTestData({
    required List<String> roomNumbers,
    required List<Housekeeper> housekeepers,
    required List<RoomState> rooms,
  }) : roomNumbers = List.unmodifiable(roomNumbers),
       housekeepers = List.unmodifiable(housekeepers),
       rooms = List.unmodifiable(rooms);

  final List<String> roomNumbers;
  final List<Housekeeper> housekeepers;
  final List<RoomState> rooms;
}

/// Produces complete-hotel room input for explicit developer/test actions.
final class AllRoomsTestDataGenerator {
  const AllRoomsTestDataGenerator();

  static final List<String> orderedRoomNumbers = List.unmodifiable(
    MargaritavilleRoomCatalog.territories.expand(
      (territory) => territory.rooms,
    ),
  );

  List<String> shuffledRoomNumbers(Random random) {
    final roomNumbers = [...orderedRoomNumbers];
    roomNumbers.shuffle(random);
    return List.unmodifiable(roomNumbers);
  }

  AllRoomsTestData generate({
    required List<Housekeeper> housekeepers,
    required DateTime changedAt,
    required int seed,
  }) {
    final random = Random(seed);
    final roomNumbers = shuffledRoomNumbers(random);
    final shuffledHousekeepers = [...housekeepers]..shuffle(random);
    final assignmentCount = max(1, shuffledHousekeepers.length);
    final rooms = <RoomState>[];
    for (var index = 0; index < roomNumbers.length; index++) {
      final status = RoomDisplayStatus.values[(index ~/ assignmentCount) % 4];
      final phase = switch (status) {
        RoomDisplayStatus.pending ||
        RoomDisplayStatus.scheduled => RoomPhase.pending,
        RoomDisplayStatus.open => RoomPhase.open,
        RoomDisplayStatus.ready => RoomPhase.ready,
      };
      rooms.add(
        RoomState(
          roomNumber: roomNumbers[index],
          phase: phase,
          isVip: index % 5 != 0,
          scheduledFor: status == RoomDisplayStatus.scheduled
              ? changedAt.add(Duration(minutes: index + 1))
              : null,
          timestamps: RoomTimestamps(
            selectedAt: changedAt,
            phaseUpdatedAt: changedAt,
          ),
        ),
      );
    }
    return AllRoomsTestData(
      roomNumbers: roomNumbers,
      housekeepers: shuffledHousekeepers,
      rooms: rooms,
    );
  }
}
