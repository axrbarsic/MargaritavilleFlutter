import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/cell_calibration/presentation/room_cell_calibration_fixture.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/room_state.dart';

void main() {
  test(
    'ephemeral stand fixture covers every live status and many VIP cells',
    () {
      final rooms = RoomCellCalibrationFixture.build();

      expect(
        rooms.map((room) => room.displayStatus).toSet(),
        RoomDisplayStatus.values.toSet(),
      );
      expect(
        rooms.where((room) => room.isVip).length,
        greaterThanOrEqualTo(rooms.length * 0.6),
      );
      expect(rooms.where((room) => !room.isVip), isNotEmpty);
    },
  );
}
