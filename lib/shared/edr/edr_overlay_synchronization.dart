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
    final activationId = _activationId;
    final presentationRevision = _presentationRevision;
    final membershipMatches =
        visibleRoomIds.length == _sentTiles.length &&
        visibleRoomIds.every(
          (roomId) =>
              identical(_sentTiles[roomId], _entries[roomId]?.renderKey),
        );
    final configureContent =
        _sentContentRevision != contentRevision ||
        _sentPresentationRevision != presentationRevision ||
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
        // Only the newest exact configuration can ever be accepted by
        // _markNativeReady. Keeping superseded revisions here would turn a
        // stalled native-ready callback into unbounded retained UI state.
        _pendingConfigurations
          ..clear()
          ..[revision] = _PendingEdrConfiguration(
            contentRevision: contentRevision,
            presentationRevision: presentationRevision,
            layoutGeneration: layoutGeneration,
            renderedTiles: nextRenderedTiles,
          );
        await _nativeCommandLane.submitBarrier(
          () => _bridge.configureWindow(
            surfaceSessionId,
            activationId,
            layoutGeneration,
            revision,
            presentationRevision,
            geometryRevision,
            surfaceOrigin.dx,
            surfaceOrigin.dy,
            surface.size.width,
            surface.size.height,
            scrollOffset.dx,
            scrollOffset.dy,
            tiles,
          ),
          dropGeometry: true,
        );
        _sentContentRevision = contentRevision;
        _sentPresentationRevision = presentationRevision;
        _sentLayoutGeneration = layoutGeneration;
        _sentTiles = Map.unmodifiable(nextRenderedTiles);
        _lastGeometryOffset = scrollOffset;
      } else if (_lastGeometryOffset != scrollOffset) {
        final geometryRevision = ++_geometryRevision;
        _nativeCommandLane.submitGeometry(
          () => _bridge.updateWindowGeometry(
            surfaceSessionId,
            activationId,
            layoutGeneration,
            presentationRevision,
            geometryRevision,
            surfaceOrigin.dx,
            surfaceOrigin.dy,
            surface.size.width,
            surface.size.height,
            scrollOffset.dx,
            scrollOffset.dy,
          ),
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

extension EdrOverlayTesting on EdrOverlayController {
  @visibleForTesting
  int get debugPendingConfigurationCount => _pendingConfigurations.length;
}
