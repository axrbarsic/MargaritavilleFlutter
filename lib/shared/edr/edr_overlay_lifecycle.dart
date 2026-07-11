part of 'edr_overlay_controller.dart';

extension _EdrOverlayLifecycle on EdrOverlayController {
  void _clearNative() {
    _pendingConfigurations.clear();
    _resetSentContent();
    _bridge
        .clearWindow(
          surfaceSessionId,
          _activationId,
          ++_contentConfigurationRevision,
        )
        .ignore();
  }

  void _beginActivation() {
    _activationId = ++EdrOverlayController._nextActivationId;
    _pendingConfigurations.clear();
    _resetSentContent();
  }

  void _resetSentContent() {
    _sentContentRevision = -1;
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
