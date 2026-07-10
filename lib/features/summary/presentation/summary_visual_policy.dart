final class SummaryVisualPolicy {
  const SummaryVisualPolicy({
    this.liveCellsEnabled = false,
    this.vipJellyEnabled = true,
    this.vipHdrLightEnabled = false,
    this.statusPulseEnabled = false,
    this.sdrGlowEnabled = true,
    this.vipJellySpeed = 0.75,
    this.springIntensity = 0.72,
  });

  static const balanced = SummaryVisualPolicy();

  final bool liveCellsEnabled;
  final bool vipJellyEnabled;
  final bool vipHdrLightEnabled;
  final bool statusPulseEnabled;
  final bool sdrGlowEnabled;
  final double vipJellySpeed;
  final double springIntensity;

  bool get transientPulseEnabled => liveCellsEnabled || statusPulseEnabled;
}
