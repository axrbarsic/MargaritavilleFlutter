import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/cell_calibration/domain/models/room_cell_typography_profile.dart';

void main() {
  test('scales only the selected production typography role', () {
    const profile = RoomCellTypographyProfile.defaults;

    expect(
      profile.scale(RoomCellTypographyRole.roomNumber, 1.25),
      const RoomCellTypographyProfile(roomNumberSize: 55, roomTimeSize: 16),
    );
    expect(
      profile.scale(RoomCellTypographyRole.roomTime, 1.25),
      const RoomCellTypographyProfile(roomNumberSize: 44, roomTimeSize: 20),
    );
  });

  test('proportional scaling clamps both roles at typed limits', () {
    const profile = RoomCellTypographyProfile.defaults;

    expect(
      profile.scale(RoomCellTypographyRole.proportional, 10),
      const RoomCellTypographyProfile(roomNumberSize: 64, roomTimeSize: 26),
    );
    expect(profile.wouldClamp(RoomCellTypographyRole.proportional, 10), isTrue);
  });

  test('versioned snapshot round-trips platform and layout', () {
    const snapshot = RoomCellCalibrationSnapshot(
      platform: RoomCellCalibrationPlatform.ios,
      layout: RoomCellLayoutProfile.three,
      profile: RoomCellTypographyProfile(
        roomNumberSize: 47.2,
        roomTimeSize: 17.4,
      ),
    );

    final encoded = snapshot.encode();
    final restored = RoomCellCalibrationSnapshot.decode(encoded);

    expect(restored.version, RoomCellCalibrationSnapshot.currentVersion);
    expect(restored.platform, snapshot.platform);
    expect(restored.layout, snapshot.layout);
    expect(restored.profile, snapshot.profile);
    expect(encoded, contains('"columns":3'));
  });
}
