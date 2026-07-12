import 'dart:math' as math;

import '../../housekeeper_catalog/domain/catalogs/margaritaville_housekeeper_catalog.dart';
import '../../work_session/application/all_rooms_test_data_generator.dart';
import '../../work_session/domain/models/room_state.dart';

abstract final class RoomCellCalibrationFixture {
  static List<RoomState> build() {
    final changedAt = DateTime.utc(2027, 2, 10, 12);
    final fixture = const AllRoomsTestDataGenerator().generate(
      housekeepers: MargaritavilleHousekeeperCatalog.housekeepers(changedAt),
      changedAt: changedAt,
      seed: 37,
    );
    return fixture.rooms.take(math.min(80, fixture.rooms.length)).toList();
  }
}
