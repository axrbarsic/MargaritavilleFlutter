abstract final class SummaryHeaderInteractionPolicy {
  static const horizontalPadding = 18.0;
  static const settingsButtonSize = 48.0;
  static const puzzleStartZoneWidth = 86.0;
  static const puzzleStartFeedbackDistance = 2.0;
  static const puzzleWarningProgress = 0.82;
  static const puzzleMaximumProgress = 1.08;
  static const puzzleResetDelay = Duration(milliseconds: 160);
  static const settingsFadeMultiplier = 1.65;

  static double settingsOpacity(double puzzleProgress) {
    return 1 - (puzzleProgress * settingsFadeMultiplier).clamp(0.0, 1.0);
  }
}
