import 'dart:convert';

enum RoomCellTypographyRole { roomNumber, roomTime, proportional }

enum RoomCellCalibrationPlatform { ios, android }

enum RoomCellLayoutProfile {
  three(3),
  four(4);

  const RoomCellLayoutProfile(this.columns);

  final int columns;
}

final class RoomCellTypographyProfile {
  const RoomCellTypographyProfile({
    required this.roomNumberSize,
    required this.roomTimeSize,
  });

  static const defaults = RoomCellTypographyProfile(
    roomNumberSize: 44,
    roomTimeSize: 16,
  );
  static const roomNumberMin = 28.0;
  static const roomNumberMax = 64.0;
  static const roomTimeMin = 10.0;
  static const roomTimeMax = 26.0;

  final double roomNumberSize;
  final double roomTimeSize;

  RoomCellTypographyProfile scale(RoomCellTypographyRole role, double factor) {
    final safeFactor = factor.isFinite && factor > 0 ? factor : 1.0;
    return RoomCellTypographyProfile(
      roomNumberSize: role == RoomCellTypographyRole.roomTime
          ? roomNumberSize
          : _clampRoomNumber(roomNumberSize * safeFactor),
      roomTimeSize: role == RoomCellTypographyRole.roomNumber
          ? roomTimeSize
          : _clampRoomTime(roomTimeSize * safeFactor),
    );
  }

  bool wouldClamp(RoomCellTypographyRole role, double factor) {
    if (!factor.isFinite || factor <= 0) return false;
    final numberRequested = roomNumberSize * factor;
    final timeRequested = roomTimeSize * factor;
    return (role != RoomCellTypographyRole.roomTime &&
            (numberRequested <= roomNumberMin ||
                numberRequested >= roomNumberMax)) ||
        (role != RoomCellTypographyRole.roomNumber &&
            (timeRequested <= roomTimeMin || timeRequested >= roomTimeMax));
  }

  factory RoomCellTypographyProfile.fromJson(Map<String, Object?> json) {
    return RoomCellTypographyProfile(
      roomNumberSize: _clampRoomNumber(
        (json['roomNumberSize']! as num).toDouble(),
      ),
      roomTimeSize: _clampRoomTime((json['roomTimeSize']! as num).toDouble()),
    );
  }

  Map<String, Object?> toJson() => {
    'roomNumberSize': _rounded(roomNumberSize),
    'roomTimeSize': _rounded(roomTimeSize),
  };

  static double _clampRoomNumber(double value) =>
      value.clamp(roomNumberMin, roomNumberMax).toDouble();

  static double _clampRoomTime(double value) =>
      value.clamp(roomTimeMin, roomTimeMax).toDouble();

  static double _rounded(double value) => (value * 10).roundToDouble() / 10;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomCellTypographyProfile &&
          roomNumberSize == other.roomNumberSize &&
          roomTimeSize == other.roomTimeSize;

  @override
  int get hashCode => Object.hash(roomNumberSize, roomTimeSize);
}

final class RoomCellCalibrationSnapshot {
  const RoomCellCalibrationSnapshot({
    required this.platform,
    required this.layout,
    required this.profile,
    this.version = currentVersion,
  });

  static const currentVersion = 1;

  final int version;
  final RoomCellCalibrationPlatform platform;
  final RoomCellLayoutProfile layout;
  final RoomCellTypographyProfile profile;

  factory RoomCellCalibrationSnapshot.fromJson(Map<String, Object?> json) {
    final version = json['version']! as int;
    if (version != currentVersion) {
      throw FormatException('Unsupported typography snapshot v$version');
    }
    return RoomCellCalibrationSnapshot(
      version: version,
      platform: RoomCellCalibrationPlatform.values.byName(
        json['platform']! as String,
      ),
      layout: RoomCellLayoutProfile.values.byName(json['layout']! as String),
      profile: RoomCellTypographyProfile.fromJson(
        json['profile']! as Map<String, Object?>,
      ),
    );
  }

  factory RoomCellCalibrationSnapshot.decode(String value) {
    return RoomCellCalibrationSnapshot.fromJson(
      jsonDecode(value) as Map<String, Object?>,
    );
  }

  String encode() => jsonEncode(toJson());

  Map<String, Object?> toJson() => {
    'version': version,
    'platform': platform.name,
    'layout': layout.name,
    'columns': layout.columns,
    'profile': profile.toJson(),
  };
}
