part of 'edr_overlay_controller.dart';

int _nextEdrSurfaceSessionId = 0;
int _nextEdrActivationId = 0;

extension _EdrOverlayLifecycle on EdrOverlayController {
  Future<void> _suspendNative() {
    _pendingConfigurations.clear();
    _resetSentContent();
    final activationId = _activationId;
    final presentationRevision = ++_presentationRevision;
    return _nativeCommandLane.submitBarrier(() async {
      final ack = await _bridge.suspendWindow(
        surfaceSessionId,
        activationId,
        presentationRevision,
      );
      final hasDisplayReceipt =
          ack.outcome == EdrPresentationOutcome.transparentPresented &&
          ack.nativeGeneration > 0 &&
          ack.presentedAtNanos > 0;
      final hasStructuralReceipt =
          ack.outcome == EdrPresentationOutcome.structurallyDetached &&
          ack.nativeGeneration > 0;
      final hasNoNativePaint =
          ack.outcome == EdrPresentationOutcome.neverPresentedFlutterOnly;
      if (!ack.suppressed ||
          (!hasDisplayReceipt && !hasStructuralReceipt && !hasNoNativePaint) ||
          ack.surfaceSessionId != surfaceSessionId ||
          ack.activationId != activationId ||
          ack.presentationRevision != presentationRevision) {
        throw StateError(
          'Native presentation fence не подтвердил exact lease: '
          'ожидался ($surfaceSessionId, $activationId, '
          '$presentationRevision), получен (${ack.surfaceSessionId}, '
          '${ack.activationId}, ${ack.presentationRevision}, '
          'suppressed=${ack.suppressed}, generation=${ack.nativeGeneration}, '
          'presentedAtNanos=${ack.presentedAtNanos}, outcome=${ack.outcome})',
        );
      }
      _nativeMayPaint = false;
    }, dropGeometry: true);
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
    _activationId = ++_nextEdrActivationId;
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
