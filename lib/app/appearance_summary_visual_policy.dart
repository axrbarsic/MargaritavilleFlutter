import '../features/settings/domain/models/appearance_settings.dart';
import '../features/summary/presentation/summary_visual_policy.dart';
import '../shared/visual_runtime/visual_frame_clock.dart';

abstract final class AppearanceSummaryVisualPolicy {
  static SummaryVisualPolicy fromSettings(AppearanceSettings settings) {
    return SummaryVisualPolicy(
      framePolicy: const VisualFramePolicy(maxFramesPerSecond: 30),
      liveCellsEnabled: settings.liveCellsEnabled,
      vipJellyEnabled: settings.vipJellyEnabled,
      vipHdrLightEnabled: settings.vipHdrLightEnabled,
      statusPulseEnabled: settings.statusHdrPulseEnabled,
      vipJellySpeed: settings.vipJellySpeed,
      springIntensity: settings.cellSpringIntensity,
    );
  }
}
