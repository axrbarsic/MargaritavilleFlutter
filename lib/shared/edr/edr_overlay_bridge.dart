import 'generated/edr_overlay_api.g.dart';

abstract interface class EdrOverlayBridge {
  Future<void> updateTiles(int viewId, List<EdrTileSnapshot> tiles);

  Future<void> clearTiles(int viewId);
}

final class PigeonEdrOverlayBridge implements EdrOverlayBridge {
  PigeonEdrOverlayBridge({EdrOverlayHostApi? api})
    : _api = api ?? EdrOverlayHostApi();

  final EdrOverlayHostApi _api;

  @override
  Future<void> updateTiles(int viewId, List<EdrTileSnapshot> tiles) {
    return _api.updateTiles(viewId, tiles);
  }

  @override
  Future<void> clearTiles(int viewId) {
    return _api.clearTiles(viewId);
  }
}
