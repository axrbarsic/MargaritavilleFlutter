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
  late String timeText;
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
  int? pulseBoostColorArgb;
  int? pulseStartedAtMicros;
  late double springIntensity;
}

@HostApi()
abstract class EdrOverlayHostApi {
  void configureWindow(
    int revision,
    double viewportLeft,
    double viewportTop,
    double viewportWidth,
    double viewportHeight,
    List<EdrTileSnapshot> tiles,
  );

  void clearWindow(int revision);
}

@FlutterApi()
abstract class EdrOverlayFlutterApi {
  void windowReady(int revision);
}
