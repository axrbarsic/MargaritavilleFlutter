import 'dart:math' as math;

abstract final class SummarySwipeCommitPolicy {
  static double compactThreshold(double cellWidth) {
    return (cellWidth * 0.72).clamp(58, 84);
  }

  static bool compactArmed({
    required double translation,
    required double velocity,
    required double cellWidth,
  }) {
    final predictedTranslation = translation + math.max(velocity, 0) * 0.12;
    final committedTranslation = math.max(
      translation,
      predictedTranslation * 0.78,
    );
    return committedTranslation >= compactThreshold(cellWidth);
  }
}
