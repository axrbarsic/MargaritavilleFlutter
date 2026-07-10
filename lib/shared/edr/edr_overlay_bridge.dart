import 'generated/edr_overlay_api.g.dart';

abstract interface class EdrOverlayBridge {
  Future<void> configureViewport(
    int viewId,
    int revision,
    double scrollOffset,
    List<EdrTileSnapshot> tiles,
  );

  Future<void> updateScrollOffset(
    int viewId,
    int revision,
    int sequence,
    double scrollOffset,
  );

  Future<void> clearViewport(int viewId, int revision);
}

final class PigeonEdrOverlayBridge implements EdrOverlayBridge {
  PigeonEdrOverlayBridge({EdrOverlayHostApi? api})
    : _api = api ?? EdrOverlayHostApi();

  final EdrOverlayHostApi _api;

  @override
  Future<void> configureViewport(
    int viewId,
    int revision,
    double scrollOffset,
    List<EdrTileSnapshot> tiles,
  ) {
    return _api.configureViewport(viewId, revision, scrollOffset, tiles);
  }

  @override
  Future<void> updateScrollOffset(
    int viewId,
    int revision,
    int sequence,
    double scrollOffset,
  ) {
    return _api.updateScrollOffset(viewId, revision, sequence, scrollOffset);
  }

  @override
  Future<void> clearViewport(int viewId, int revision) {
    return _api.clearViewport(viewId, revision);
  }
}
