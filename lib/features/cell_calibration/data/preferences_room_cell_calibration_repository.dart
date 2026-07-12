import '../../../shared/persistence/settings_key_value_store.dart';
import '../domain/models/room_cell_typography_profile.dart';
import '../domain/repositories/room_cell_calibration_repository.dart';

final class PreferencesRoomCellCalibrationRepository
    implements RoomCellCalibrationRepository {
  const PreferencesRoomCellCalibrationRepository(this._store);

  final SettingsKeyValueStore _store;

  static String key(
    RoomCellCalibrationPlatform platform,
    RoomCellLayoutProfile layout,
  ) =>
      'margaritaville.room_cell_typography.${platform.name}.'
      '${layout.columns}.v${RoomCellCalibrationSnapshot.currentVersion}';

  @override
  Future<RoomCellCalibrationSnapshot?> load(
    RoomCellCalibrationPlatform platform,
    RoomCellLayoutProfile layout,
  ) async {
    final raw = await _store.readString(key(platform, layout));
    if (raw == null) return null;
    try {
      final snapshot = RoomCellCalibrationSnapshot.decode(raw);
      if (snapshot.platform != platform || snapshot.layout != layout) {
        return null;
      }
      return snapshot;
    } on Object {
      return null;
    }
  }

  @override
  Future<void> save(RoomCellCalibrationSnapshot snapshot) {
    return _store.writeString(
      key(snapshot.platform, snapshot.layout),
      snapshot.encode(),
    );
  }
}
