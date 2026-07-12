part of 'edr_overlay_controller.dart';

final class _PendingEdrConfiguration {
  const _PendingEdrConfiguration({
    required this.contentRevision,
    required this.presentationRevision,
    required this.layoutGeneration,
    required this.renderedTiles,
  });

  final int contentRevision;
  final int presentationRevision;
  final int layoutGeneration;
  final Map<String, GlobalKey> renderedTiles;
}

@immutable
final class _EdrTileEntry {
  const _EdrTileEntry({
    required this.renderKey,
    required this.renderState,
    required this.timeText,
    required this.baseColorArgb,
    required this.cornerRadius,
    required this.vipHdrEnabled,
    required this.vipJellyEnabled,
    required this.vipJellySpeed,
    required this.pulseGeneration,
    required this.pulseColorArgb,
    required this.pulseBoostColorArgb,
    required this.pulseStartedAtMicros,
    required this.springIntensity,
    required this.primaryFontSize,
    required this.secondaryFontSize,
  });

  final GlobalKey renderKey;
  final ValueNotifier<bool> renderState;
  final String timeText;
  final int baseColorArgb;
  final double cornerRadius;
  final bool vipHdrEnabled;
  final bool vipJellyEnabled;
  final double vipJellySpeed;
  final int? pulseGeneration;
  final int? pulseColorArgb;
  final int? pulseBoostColorArgb;
  final int? pulseStartedAtMicros;
  final double springIntensity;
  final double primaryFontSize;
  final double secondaryFontSize;

  @override
  bool operator ==(Object other) {
    return other is _EdrTileEntry &&
        other.renderKey == renderKey &&
        identical(other.renderState, renderState) &&
        other.timeText == timeText &&
        other.baseColorArgb == baseColorArgb &&
        other.cornerRadius == cornerRadius &&
        other.vipHdrEnabled == vipHdrEnabled &&
        other.vipJellyEnabled == vipJellyEnabled &&
        other.vipJellySpeed == vipJellySpeed &&
        other.pulseGeneration == pulseGeneration &&
        other.pulseColorArgb == pulseColorArgb &&
        other.pulseBoostColorArgb == pulseBoostColorArgb &&
        other.pulseStartedAtMicros == pulseStartedAtMicros &&
        other.springIntensity == springIntensity &&
        other.primaryFontSize == primaryFontSize &&
        other.secondaryFontSize == secondaryFontSize;
  }

  @override
  int get hashCode => Object.hash(
    renderKey,
    renderState,
    timeText,
    baseColorArgb,
    cornerRadius,
    vipHdrEnabled,
    vipJellyEnabled,
    vipJellySpeed,
    pulseGeneration,
    pulseColorArgb,
    pulseBoostColorArgb,
    pulseStartedAtMicros,
    springIntensity,
    primaryFontSize,
    secondaryFontSize,
  );
}
