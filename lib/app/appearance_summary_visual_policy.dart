import '../features/settings/domain/models/appearance_settings.dart';
import '../features/settings/domain/models/summary_grid_preference.dart';
import '../features/summary/presentation/summary_visual_policy.dart';

abstract final class AppearanceSummaryVisualPolicy {
  static SummaryVisualPolicy fromSettings(AppearanceSettings settings) {
    return SummaryVisualPolicy(
      liveCellsEnabled: settings.liveCellsEnabled,
      vipJellyEnabled: settings.vipJellyEnabled,
      vipHdrLightEnabled: settings.vipHdrLightEnabled,
      statusPulseEnabled: settings.statusHdrPulseEnabled,
      vividStatusPaletteEnabled: settings.vividStatusPaletteEnabled,
      vipJellySpeed: settings.vipJellySpeed,
      springIntensity: settings.cellSpringIntensity,
      gridColumns: switch (settings.summaryGridPreference) {
        SummaryGridPreference.four => SummaryGridColumns.four,
        SummaryGridPreference.three => SummaryGridColumns.three,
      },
    );
  }
}
