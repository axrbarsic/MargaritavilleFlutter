import '../models/room_cell_typography_profile.dart';

abstract interface class RoomCellCalibrationRepository {
  Future<RoomCellCalibrationSnapshot?> load(
    RoomCellCalibrationPlatform platform,
    RoomCellLayoutProfile layout,
  );

  Future<void> save(RoomCellCalibrationSnapshot snapshot);
}
