import 'generated/edr_overlay_api.g.dart';

abstract interface class EdrOverlayBridge {
  Future<void> configureWindow(
    int surfaceSessionId,
    int activationId,
    int layoutGeneration,
    int contentRevision,
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
    int geometryRevision,
    double viewportLeft,
    double viewportTop,
    double viewportWidth,
    double viewportHeight,
    double scrollOffsetX,
    double scrollOffsetY,
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
  Future<void> clearWindow(
    int surfaceSessionId,
    int activationId,
    int contentRevision,
  ) {
    return _api.clearWindow(surfaceSessionId, activationId, contentRevision);
  }
}
