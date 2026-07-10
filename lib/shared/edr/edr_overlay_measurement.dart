part of 'edr_overlay_controller.dart';

final class _MeasuredEdrTile {
  const _MeasuredEdrTile({
    required this.roomId,
    required this.globalOrigin,
    required this.bounds,
    required this.entry,
  });

  final String roomId;
  final Offset globalOrigin;
  final Rect bounds;
  final _EdrTileEntry entry;

  EdrTileSnapshot snapshot({required Offset relativeTo}) {
    final origin = globalOrigin - relativeTo;
    return EdrTileSnapshot(
      roomId: roomId,
      left: origin.dx,
      top: origin.dy,
      width: bounds.width,
      height: bounds.height,
      cornerRadius: entry.cornerRadius,
      baseColorArgb: entry.baseColorArgb,
      vipHdrEnabled: entry.vipHdrEnabled,
      vipJellyEnabled: entry.vipJellyEnabled,
      vipJellySpeed: entry.vipJellySpeed,
      pulseGeneration: entry.pulseGeneration,
      pulseColorArgb: entry.pulseColorArgb,
      pulseStartedAtMicros: entry.pulseStartedAtMicros,
      springIntensity: entry.springIntensity,
    );
  }
}
