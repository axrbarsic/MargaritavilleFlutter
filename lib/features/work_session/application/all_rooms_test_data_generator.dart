import 'dart:math';

import '../domain/catalogs/margaritaville_room_catalog.dart';

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
}
