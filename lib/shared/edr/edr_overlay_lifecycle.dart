part of 'edr_overlay_controller.dart';

extension _EdrOverlayLifecycle on EdrOverlayController {
  Future<void> _suspendNative() {
    _pendingConfigurations.clear();
    _resetSentContent();
    final activationId = _activationId;
    final presentationRevision = ++_presentationRevision;
    return _nativeCommandLane.submitBarrier(
      () => _bridge.suspendWindow(
        surfaceSessionId,
        activationId,
        presentationRevision,
      ),
      dropGeometry: true,
    );
  }

  void _clearNative() {
    _pendingConfigurations.clear();
    _resetSentContent();
    final activationId = _activationId;
    final revision = ++_contentConfigurationRevision;
    _nativeCommandLane
        .submitBarrier(
          () => _bridge.clearWindow(surfaceSessionId, activationId, revision),
          dropGeometry: true,
        )
        .ignore();
  }

  void _beginActivation() {
    _nativeCommandLane.dropGeometry();
    _activationId = ++EdrOverlayController._nextActivationId;
    _presentationRevision += 1;
    _pendingConfigurations.clear();
    _resetSentContent();
  }

  void _resetSentContent() {
    _sentContentRevision = -1;
    _sentPresentationRevision = -1;
    _sentLayoutGeneration = -1;
    _sentTiles = const {};
    _lastGeometryOffset = null;
  }

  void _replaceRenderedTiles(Map<String, GlobalKey> next) {
    if (mapEquals(_renderedTiles, next)) return;
    final affectedRoomIds = {..._renderedTiles.keys, ...next.keys};
    _renderedTiles = Map.unmodifiable(next);
    for (final roomId in affectedRoomIds) {
      final entry = _entries[roomId];
      if (entry == null) continue;
      final rendered = identical(next[roomId], entry.renderKey);
      if (entry.renderState.value != rendered) {
        entry.renderState.value = rendered;
      }
    }
  }
}
