import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/shared/edr/generated/edr_overlay_api.g.dart',
    dartOptions: DartOptions(),
    dartPackageName: 'margaritaville_flutter',
    swiftOut: 'ios/Runner/EdrOverlayApi.g.swift',
    swiftOptions: SwiftOptions(),
  ),
)
class EdrTileSnapshot {
  late String roomId;
  late double left;
  late double top;
  late double width;
  late double height;
  late double cornerRadius;
  late int baseColorArgb;
  late bool vipHdrEnabled;
  late bool vipJellyEnabled;
  late double vipJellySpeed;
  int? pulseGeneration;
  int? pulseColorArgb;
  int? pulseStartedAtMicros;
  late double springIntensity;
}

@HostApi()
abstract class EdrOverlayHostApi {
  void configureViewport(
    int viewId,
    int revision,
    double scrollOffset,
    List<EdrTileSnapshot> tiles,
  );

  void updateScrollOffset(
    int viewId,
    int revision,
    int sequence,
    double scrollOffset,
  );

  void clearViewport(int viewId, int revision);
}
