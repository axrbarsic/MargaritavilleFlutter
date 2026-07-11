part of 'edr_overlay_controller.dart';

/// Caches stable tile bounds in scroll-content coordinates. A scroll frame
/// performs only arithmetic over cached rects; it never calls `localToGlobal`
/// for the complete hotel catalog.
final class _EdrOverlayGeometryCache {
  final Map<String, _CachedEdrTileGeometry> _tiles = {};
  var _dirty = true;
  var _layoutGeneration = 0;

  int get layoutGeneration => _layoutGeneration;

  void invalidate() {
    _dirty = true;
  }

  void remove(String roomId) {
    _tiles.remove(roomId);
  }

  void clear() {
    _tiles.clear();
    _dirty = true;
  }

  List<String> resolveVisibleRoomIds({
    required Map<String, _EdrTileEntry> entries,
    required Offset surfaceOrigin,
    required Offset scrollOffset,
    required Rect membershipBounds,
  }) {
    if (_dirty) {
      _rebuild(
        entries: entries,
        surfaceOrigin: surfaceOrigin,
        scrollOffset: scrollOffset,
      );
    }
    final visibleRoomIds = <String>[];
    for (final MapEntry(key: roomId, value: cached) in _tiles.entries) {
      final entry = entries[roomId];
      if (entry == null || !identical(entry.renderKey, cached.renderKey)) {
        continue;
      }
      final screenOrigin =
          surfaceOrigin + cached.contentBounds.topLeft - scrollOffset;
      final screenBounds = screenOrigin & cached.contentBounds.size;
      if (screenBounds.overlaps(membershipBounds)) {
        visibleRoomIds.add(roomId);
      }
    }
    return visibleRoomIds;
  }

  EdrTileSnapshot snapshot(String roomId, {required _EdrTileEntry entry}) {
    final contentBounds = _tiles[roomId]!.contentBounds;
    return EdrTileSnapshot(
      roomId: roomId,
      timeText: entry.timeText,
      left: contentBounds.left,
      top: contentBounds.top,
      width: contentBounds.width,
      height: contentBounds.height,
      cornerRadius: entry.cornerRadius,
      baseColorArgb: entry.baseColorArgb,
      vipHdrEnabled: entry.vipHdrEnabled,
      vipJellyEnabled: entry.vipJellyEnabled,
      vipJellySpeed: entry.vipJellySpeed,
      pulseGeneration: entry.pulseGeneration,
      pulseColorArgb: entry.pulseColorArgb,
      pulseBoostColorArgb: entry.pulseBoostColorArgb,
      pulseStartedAtMicros: entry.pulseStartedAtMicros,
      springIntensity: entry.springIntensity,
    );
  }

  void _rebuild({
    required Map<String, _EdrTileEntry> entries,
    required Offset surfaceOrigin,
    required Offset scrollOffset,
  }) {
    final next = <String, _CachedEdrTileGeometry>{};
    for (final MapEntry(key: roomId, value: entry) in entries.entries) {
      final renderObject = entry.renderKey.currentContext?.findRenderObject();
      if (renderObject is! RenderBox || !renderObject.hasSize) continue;
      final globalOrigin = renderObject.localToGlobal(Offset.zero);
      final contentOrigin = globalOrigin - surfaceOrigin + scrollOffset;
      next[roomId] = _CachedEdrTileGeometry(
        renderKey: entry.renderKey,
        contentBounds: contentOrigin & renderObject.size,
      );
    }
    _tiles
      ..clear()
      ..addAll(next);
    _dirty = false;
    _layoutGeneration++;
  }
}

final class _CachedEdrTileGeometry {
  const _CachedEdrTileGeometry({
    required this.renderKey,
    required this.contentBounds,
  });

  final GlobalKey renderKey;
  final Rect contentBounds;
}
