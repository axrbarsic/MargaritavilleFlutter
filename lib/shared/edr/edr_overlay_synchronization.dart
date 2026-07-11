part of 'edr_overlay_controller.dart';

extension _EdrOverlaySynchronization on EdrOverlayController {
  Future<void> _sendCurrentSnapshot() async {
    if (_disposed) return;
    final surface = surfaceKey.currentContext?.findRenderObject();
    if (!_attached ||
        !_windowVisible ||
        surface is! RenderBox ||
        !surface.hasSize) {
      return;
    }
    final surfaceOrigin = surface.localToGlobal(Offset.zero);
    if (_lastSurfaceSize != surface.size) {
      _lastSurfaceSize = surface.size;
      _geometryCache.invalidate();
    }
    final viewportBounds = surfaceOrigin & surface.size;
    _lastViewportBounds = viewportBounds;
    final membershipBounds = viewportBounds.inflate(
      EdrOverlayController.verticalPreload,
    );
    final visibleRoomIds = _geometryCache.resolveVisibleRoomIds(
      entries: _entries,
      surfaceOrigin: surfaceOrigin,
      scrollOffset: _scrollOffset,
      membershipBounds: membershipBounds,
    );
    final contentRevision = _contentRevision;
    final layoutGeneration = _geometryCache.layoutGeneration;
    final scrollOffset = _scrollOffset;
    final membershipMatches =
        visibleRoomIds.length == _sentTiles.length &&
        visibleRoomIds.every(
          (roomId) =>
              identical(_sentTiles[roomId], _entries[roomId]?.renderKey),
        );
    final configureContent =
        _sentContentRevision != contentRevision ||
        _sentLayoutGeneration != layoutGeneration ||
        !membershipMatches;
    try {
      if (configureContent) {
        final layoutChanged =
            _sentLayoutGeneration >= 0 &&
            _sentLayoutGeneration != layoutGeneration;
        if (layoutChanged) {
          _pendingConfigurations.clear();
          _replaceRenderedTiles(const {});
        }
        final geometryRevision = ++_geometryRevision;
        final nextRenderedTiles = <String, GlobalKey>{
          for (final roomId in visibleRoomIds)
            if (_entries[roomId] case final entry?) roomId: entry.renderKey,
        };
        final tiles = <EdrTileSnapshot>[
          for (final roomId in visibleRoomIds)
            if (_entries[roomId] case final entry?)
              _geometryCache.snapshot(roomId, entry: entry),
        ];
        final removedNativeTiles = <String>{
          for (final roomId in _renderedTiles.keys)
            if (!nextRenderedTiles.containsKey(roomId)) roomId,
        };
        if (removedNativeTiles.isNotEmpty) {
          _replaceRenderedTiles(
            {..._renderedTiles}
              ..removeWhere((roomId, _) => removedNativeTiles.contains(roomId)),
          );
        }
        final revision = ++_contentConfigurationRevision;
        _pendingConfigurations[revision] = _PendingEdrConfiguration(
          contentRevision: contentRevision,
          layoutGeneration: layoutGeneration,
          renderedTiles: nextRenderedTiles,
        );
        await _bridge.configureWindow(
          surfaceSessionId,
          _activationId,
          layoutGeneration,
          revision,
          geometryRevision,
          surfaceOrigin.dx,
          surfaceOrigin.dy,
          surface.size.width,
          surface.size.height,
          scrollOffset.dx,
          scrollOffset.dy,
          tiles,
        );
        _sentContentRevision = contentRevision;
        _sentLayoutGeneration = layoutGeneration;
        _sentTiles = Map.unmodifiable(nextRenderedTiles);
        _lastGeometryOffset = scrollOffset;
      } else if (_lastGeometryOffset != scrollOffset) {
        final geometryRevision = ++_geometryRevision;
        await _bridge.updateWindowGeometry(
          surfaceSessionId,
          _activationId,
          layoutGeneration,
          geometryRevision,
          surfaceOrigin.dx,
          surfaceOrigin.dy,
          surface.size.width,
          surface.size.height,
          scrollOffset.dx,
          scrollOffset.dy,
        );
        _lastGeometryOffset = scrollOffset;
      }
    } catch (error) {
      debugPrint('Нативный EDR-overlay недоступен: $error');
      _pendingConfigurations.clear();
      _resetSentContent();
      _lastGeometryOffset = null;
      _replaceRenderedTiles(const {});
      _scheduleSync();
      return;
    }
    if (_disposed || !_attached) return;
    if (_contentRevision != contentRevision ||
        _geometryCache.layoutGeneration != layoutGeneration ||
        _scrollOffset != scrollOffset) {
      _syncAgain = true;
    }
  }
}
