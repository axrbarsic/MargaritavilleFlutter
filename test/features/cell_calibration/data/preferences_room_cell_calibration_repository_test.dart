import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/cell_calibration/data/preferences_room_cell_calibration_repository.dart';
import 'package:margaritaville_flutter/features/cell_calibration/domain/models/room_cell_typography_profile.dart';
import 'package:margaritaville_flutter/shared/persistence/settings_key_value_store.dart';

void main() {
  test('stores independent platform and layout snapshots', () async {
    final store = _MemoryStore();
    final repository = PreferencesRoomCellCalibrationRepository(store);
    const iosThree = RoomCellCalibrationSnapshot(
      platform: RoomCellCalibrationPlatform.ios,
      layout: RoomCellLayoutProfile.three,
      profile: RoomCellTypographyProfile(roomNumberSize: 48, roomTimeSize: 17),
    );
    const androidFour = RoomCellCalibrationSnapshot(
      platform: RoomCellCalibrationPlatform.android,
      layout: RoomCellLayoutProfile.four,
      profile: RoomCellTypographyProfile(roomNumberSize: 41, roomTimeSize: 15),
    );

    await repository.save(iosThree);
    await repository.save(androidFour);

    expect(
      (await repository.load(
        RoomCellCalibrationPlatform.ios,
        RoomCellLayoutProfile.three,
      ))?.profile,
      iosThree.profile,
    );
    expect(
      (await repository.load(
        RoomCellCalibrationPlatform.android,
        RoomCellLayoutProfile.four,
      ))?.profile,
      androidFour.profile,
    );
    expect(store.values, hasLength(2));
  });

  test('ignores a corrupt or unsupported persisted snapshot', () async {
    final store = _MemoryStore();
    final repository = PreferencesRoomCellCalibrationRepository(store);
    final key = PreferencesRoomCellCalibrationRepository.key(
      RoomCellCalibrationPlatform.ios,
      RoomCellLayoutProfile.four,
    );
    store.values[key] = '{"version":99}';

    expect(
      await repository.load(
        RoomCellCalibrationPlatform.ios,
        RoomCellLayoutProfile.four,
      ),
      isNull,
    );
  });
}

final class _MemoryStore implements SettingsKeyValueStore {
  final Map<String, Object> values = {};

  @override
  Future<bool?> readBool(String key) async => values[key] as bool?;
  @override
  Future<double?> readDouble(String key) async => values[key] as double?;
  @override
  Future<String?> readString(String key) async => values[key] as String?;
  @override
  Future<void> writeBool(String key, bool value) async => values[key] = value;
  @override
  Future<void> writeDouble(String key, double value) async =>
      values[key] = value;
  @override
  Future<void> writeString(String key, String value) async =>
      values[key] = value;
}
