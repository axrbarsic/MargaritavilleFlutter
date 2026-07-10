import '../../../shared/visual_runtime/visual_frame_clock.dart';

final class SummaryVisualPolicy {
  const SummaryVisualPolicy({
    required this.framePolicy,
    this.liveCellsEnabled = false,
    this.vipJellyEnabled = true,
    this.vipHdrLightEnabled = false,
    this.statusPulseEnabled = false,
    this.sdrGlowEnabled = true,
    this.vipJellySpeed = 0.75,
    this.springIntensity = 0.72,
  });

  static const balanced = SummaryVisualPolicy(
    framePolicy: VisualFramePolicy(maxFramesPerSecond: 30),
  );

  final VisualFramePolicy framePolicy;
  final bool liveCellsEnabled;
  final bool vipJellyEnabled;
  final bool vipHdrLightEnabled;
  final bool statusPulseEnabled;
  final bool sdrGlowEnabled;
  final double vipJellySpeed;
  final double springIntensity;

  bool get transientPulseEnabled => liveCellsEnabled || statusPulseEnabled;
}
