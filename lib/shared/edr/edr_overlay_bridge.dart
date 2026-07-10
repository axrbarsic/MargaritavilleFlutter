import 'generated/edr_overlay_api.g.dart';

abstract interface class EdrOverlayBridge {
  Future<void> configureWindow(
    int revision,
    double viewportLeft,
    double viewportTop,
    double viewportWidth,
    double viewportHeight,
    List<EdrTileSnapshot> tiles,
  );

  Future<void> clearWindow(int revision);
}

final class PigeonEdrOverlayBridge implements EdrOverlayBridge {
  PigeonEdrOverlayBridge({EdrOverlayHostApi? api})
    : _api = api ?? EdrOverlayHostApi();

  final EdrOverlayHostApi _api;

  @override
  Future<void> configureWindow(
    int revision,
    double viewportLeft,
    double viewportTop,
    double viewportWidth,
    double viewportHeight,
    List<EdrTileSnapshot> tiles,
  ) {
    return _api.configureWindow(
      revision,
      viewportLeft,
      viewportTop,
      viewportWidth,
      viewportHeight,
      tiles,
    );
  }

  @override
  Future<void> clearWindow(int revision) {
    return _api.clearWindow(revision);
  }
}
