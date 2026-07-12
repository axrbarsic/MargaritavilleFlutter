import 'generated/edr_overlay_api.g.dart';

abstract interface class EdrOverlayBridge {
  Future<void> configureWindow(
    int surfaceSessionId,
    int activationId,
    int layoutGeneration,
    int contentRevision,
    int presentationRevision,
    int geometryRevision,
    double viewportLeft,
    double viewportTop,
    double viewportWidth,
    double viewportHeight,
    double scrollOffsetX,
    double scrollOffsetY,
    List<EdrTileSnapshot> tiles,
  );

  Future<void> updateWindowGeometry(
    int surfaceSessionId,
    int activationId,
    int layoutGeneration,
    int presentationRevision,
    int geometryRevision,
    double viewportLeft,
    double viewportTop,
    double viewportWidth,
    double viewportHeight,
    double scrollOffsetX,
    double scrollOffsetY,
  );

  Future<EdrPresentationAck> suspendWindow(
    int surfaceSessionId,
    int activationId,
    int presentationRevision,
  );

  Future<void> clearWindow(
    int surfaceSessionId,
    int activationId,
    int contentRevision,
  );
}

final class PigeonEdrOverlayBridge implements EdrOverlayBridge {
  PigeonEdrOverlayBridge({EdrOverlayHostApi? api})
    : _api = api ?? EdrOverlayHostApi();

  final EdrOverlayHostApi _api;

  @override
  Future<void> configureWindow(
    int surfaceSessionId,
    int activationId,
    int layoutGeneration,
    int contentRevision,
    int presentationRevision,
    int geometryRevision,
    double viewportLeft,
    double viewportTop,
    double viewportWidth,
    double viewportHeight,
    double scrollOffsetX,
    double scrollOffsetY,
    List<EdrTileSnapshot> tiles,
  ) {
    return _api.configureWindow(
      surfaceSessionId,
      activationId,
      layoutGeneration,
      contentRevision,
      presentationRevision,
      geometryRevision,
      viewportLeft,
      viewportTop,
      viewportWidth,
      viewportHeight,
      scrollOffsetX,
      scrollOffsetY,
      tiles,
    );
  }

  @override
  Future<void> updateWindowGeometry(
    int surfaceSessionId,
    int activationId,
    int layoutGeneration,
    int presentationRevision,
    int geometryRevision,
    double viewportLeft,
    double viewportTop,
    double viewportWidth,
    double viewportHeight,
    double scrollOffsetX,
    double scrollOffsetY,
  ) {
    return _api.updateWindowGeometry(
      surfaceSessionId,
      activationId,
      layoutGeneration,
      presentationRevision,
      geometryRevision,
      viewportLeft,
      viewportTop,
      viewportWidth,
      viewportHeight,
      scrollOffsetX,
      scrollOffsetY,
    );
  }

  @override
  Future<EdrPresentationAck> suspendWindow(
    int surfaceSessionId,
    int activationId,
    int presentationRevision,
  ) {
    return _api.suspendWindow(
      surfaceSessionId,
      activationId,
      presentationRevision,
    );
  }

  @override
  Future<void> clearWindow(
    int surfaceSessionId,
    int activationId,
    int contentRevision,
  ) {
    return _api.clearWindow(surfaceSessionId, activationId, contentRevision);
  }
}
