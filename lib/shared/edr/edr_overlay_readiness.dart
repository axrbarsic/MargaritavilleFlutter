part of 'edr_overlay_controller.dart';

extension _EdrOverlayReadiness on EdrOverlayController {
  Future<EdrReadyAck> _markNativeReady(
    int activationId,
    int revision,
    int presentationRevision,
  ) async {
    EdrReadyAck acknowledgement(bool accepted) => EdrReadyAck(
      surfaceSessionId: surfaceSessionId,
      activationId: activationId,
      contentRevision: revision,
      presentationRevision: presentationRevision,
      accepted: accepted,
    );
    final configuration = _pendingConfigurations[revision];
    if (_disposed ||
        !_windowVisible ||
        activationId != _activationId ||
        presentationRevision != _presentationRevision ||
        configuration == null ||
        revision != _contentConfigurationRevision) {
      return acknowledgement(false);
    }
    if (configuration.contentRevision != _contentRevision ||
        configuration.presentationRevision != _presentationRevision ||
        configuration.layoutGeneration != _geometryCache.layoutGeneration) {
      _scheduleSync();
      return acknowledgement(false);
    }
    if (_readyInFlightRevision == revision) return acknowledgement(false);
    _readyInFlightRevision = revision;
    try {
      _replaceRenderedTiles(configuration.renderedTiles);
      WidgetsBinding.instance.scheduleFrame();
      await WidgetsBinding.instance.endOfFrame;
      final stillExact =
          !_disposed &&
          _windowVisible &&
          activationId == _activationId &&
          presentationRevision == _presentationRevision &&
          identical(_pendingConfigurations[revision], configuration) &&
          revision == _contentConfigurationRevision &&
          configuration.contentRevision == _contentRevision &&
          configuration.layoutGeneration == _geometryCache.layoutGeneration;
      if (!stillExact) {
        _replaceRenderedTiles(const {});
        _scheduleSync();
        return acknowledgement(false);
      }
      _pendingConfigurations.remove(revision);
      _pendingConfigurations.removeWhere((key, _) => key < revision);
      _nativeMayPaint = configuration.renderedTiles.isNotEmpty;
      return acknowledgement(true);
    } finally {
      if (_readyInFlightRevision == revision) _readyInFlightRevision = null;
    }
  }
}
