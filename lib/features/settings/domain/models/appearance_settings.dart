final class AppearanceSettings {
  const AppearanceSettings({
    required this.liveCellsEnabled,
    required this.cellSpringIntensity,
    required this.vipJellyEnabled,
    required this.vipJellySpeed,
    required this.vipHdrLightEnabled,
    required this.statusHdrPulseEnabled,
  });

  static const defaults = AppearanceSettings(
    liveCellsEnabled: false,
    cellSpringIntensity: 0.72,
    vipJellyEnabled: true,
    vipJellySpeed: 0.75,
    vipHdrLightEnabled: false,
    statusHdrPulseEnabled: false,
  );

  final bool liveCellsEnabled;
  final double cellSpringIntensity;
  final bool vipJellyEnabled;
  final double vipJellySpeed;
  final bool vipHdrLightEnabled;
  final bool statusHdrPulseEnabled;

  AppearanceSettings copyWith({
    bool? liveCellsEnabled,
    double? cellSpringIntensity,
    bool? vipJellyEnabled,
    double? vipJellySpeed,
    bool? vipHdrLightEnabled,
    bool? statusHdrPulseEnabled,
  }) {
    return AppearanceSettings(
      liveCellsEnabled: liveCellsEnabled ?? this.liveCellsEnabled,
      cellSpringIntensity: cellSpringIntensity ?? this.cellSpringIntensity,
      vipJellyEnabled: vipJellyEnabled ?? this.vipJellyEnabled,
      vipJellySpeed: vipJellySpeed ?? this.vipJellySpeed,
      vipHdrLightEnabled: vipHdrLightEnabled ?? this.vipHdrLightEnabled,
      statusHdrPulseEnabled:
          statusHdrPulseEnabled ?? this.statusHdrPulseEnabled,
    );
  }

  AppearanceSettings normalized() {
    return copyWith(
      cellSpringIntensity: cellSpringIntensity.clamp(0, 1).toDouble(),
      vipJellySpeed: vipJellySpeed.clamp(0.2, 2.5).toDouble(),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AppearanceSettings &&
        other.liveCellsEnabled == liveCellsEnabled &&
        other.cellSpringIntensity == cellSpringIntensity &&
        other.vipJellyEnabled == vipJellyEnabled &&
        other.vipJellySpeed == vipJellySpeed &&
        other.vipHdrLightEnabled == vipHdrLightEnabled &&
        other.statusHdrPulseEnabled == statusHdrPulseEnabled;
  }

  @override
  int get hashCode => Object.hash(
    liveCellsEnabled,
    cellSpringIntensity,
    vipJellyEnabled,
    vipJellySpeed,
    vipHdrLightEnabled,
    statusHdrPulseEnabled,
  );
}
