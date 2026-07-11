import 'app_background_mode.dart';
import 'summary_grid_preference.dart';

final class AppearanceSettings {
  const AppearanceSettings({
    required this.liveCellsEnabled,
    required this.cellSpringIntensity,
    required this.vipJellyEnabled,
    required this.vipJellySpeed,
    required this.vipHdrLightEnabled,
    required this.statusHdrPulseEnabled,
    required this.vividStatusPaletteEnabled,
    this.summaryGridPreference = SummaryGridPreference.four,
    this.backgroundMode = AppBackgroundMode.matrixRain,
    this.matrixSpeed = 1,
  });

  static const defaults = AppearanceSettings(
    liveCellsEnabled: false,
    cellSpringIntensity: 0.72,
    vipJellyEnabled: true,
    vipJellySpeed: 0.75,
    vipHdrLightEnabled: false,
    statusHdrPulseEnabled: false,
    vividStatusPaletteEnabled: true,
    summaryGridPreference: SummaryGridPreference.four,
    backgroundMode: AppBackgroundMode.matrixRain,
    matrixSpeed: 1,
  );

  final bool liveCellsEnabled;
  final double cellSpringIntensity;
  final bool vipJellyEnabled;
  final double vipJellySpeed;
  final bool vipHdrLightEnabled;
  final bool statusHdrPulseEnabled;
  final bool vividStatusPaletteEnabled;
  final SummaryGridPreference summaryGridPreference;
  final AppBackgroundMode backgroundMode;
  final double matrixSpeed;

  AppearanceSettings copyWith({
    bool? liveCellsEnabled,
    double? cellSpringIntensity,
    bool? vipJellyEnabled,
    double? vipJellySpeed,
    bool? vipHdrLightEnabled,
    bool? statusHdrPulseEnabled,
    bool? vividStatusPaletteEnabled,
    SummaryGridPreference? summaryGridPreference,
    AppBackgroundMode? backgroundMode,
    double? matrixSpeed,
  }) {
    return AppearanceSettings(
      liveCellsEnabled: liveCellsEnabled ?? this.liveCellsEnabled,
      cellSpringIntensity: cellSpringIntensity ?? this.cellSpringIntensity,
      vipJellyEnabled: vipJellyEnabled ?? this.vipJellyEnabled,
      vipJellySpeed: vipJellySpeed ?? this.vipJellySpeed,
      vipHdrLightEnabled: vipHdrLightEnabled ?? this.vipHdrLightEnabled,
      statusHdrPulseEnabled:
          statusHdrPulseEnabled ?? this.statusHdrPulseEnabled,
      vividStatusPaletteEnabled:
          vividStatusPaletteEnabled ?? this.vividStatusPaletteEnabled,
      summaryGridPreference:
          summaryGridPreference ?? this.summaryGridPreference,
      backgroundMode: backgroundMode ?? this.backgroundMode,
      matrixSpeed: matrixSpeed ?? this.matrixSpeed,
    );
  }

  AppearanceSettings normalized() {
    return copyWith(
      cellSpringIntensity: cellSpringIntensity.clamp(0, 1).toDouble(),
      vipJellySpeed: vipJellySpeed.clamp(0.2, 2.5).toDouble(),
      matrixSpeed: matrixSpeed.clamp(0.08, 3).toDouble(),
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
        other.statusHdrPulseEnabled == statusHdrPulseEnabled &&
        other.vividStatusPaletteEnabled == vividStatusPaletteEnabled &&
        other.summaryGridPreference == summaryGridPreference &&
        other.backgroundMode == backgroundMode &&
        other.matrixSpeed == matrixSpeed;
  }

  @override
  int get hashCode => Object.hash(
    liveCellsEnabled,
    cellSpringIntensity,
    vipJellyEnabled,
    vipJellySpeed,
    vipHdrLightEnabled,
    statusHdrPulseEnabled,
    vividStatusPaletteEnabled,
    summaryGridPreference,
    backgroundMode,
    matrixSpeed,
  );
}
