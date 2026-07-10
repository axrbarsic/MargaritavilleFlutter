import '../../../shared/visual_runtime/visual_frame_clock.dart';

final class SummaryVisualPolicy {
  const SummaryVisualPolicy({
    required this.framePolicy,
    this.vipJellyEnabled = true,
    this.statusPulseEnabled = true,
    this.sdrGlowEnabled = true,
    this.vipJellySpeed = 0.75,
    this.springIntensity = 1,
  });

  static const balanced = SummaryVisualPolicy(
    framePolicy: VisualFramePolicy(maxFramesPerSecond: 30),
  );

  final VisualFramePolicy framePolicy;
  final bool vipJellyEnabled;
  final bool statusPulseEnabled;
  final bool sdrGlowEnabled;
  final double vipJellySpeed;
  final double springIntensity;
}
