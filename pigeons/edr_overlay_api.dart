import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/shared/edr/generated/edr_overlay_api.g.dart',
    dartOptions: DartOptions(),
    dartPackageName: 'margaritaville_flutter',
    swiftOut: 'ios/Runner/EdrOverlayApi.g.swift',
    swiftOptions: SwiftOptions(),
    kotlinOut:
        'android/app/src/main/kotlin/com/alex/margaritaville/flutter/beta/edr/EdrOverlayApi.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'com.alex.margaritaville.flutter.beta.edr',
    ),
  ),
)
class EdrTileSnapshot {
  late String roomId;
  late String timeText;
  late double primaryFontSize;
  late double secondaryFontSize;
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

enum EdrPresentationOutcome {
  transparentPresented,
  structurallyDetached,
  neverPresentedFlutterOnly,
  staleRejected,
  failed,
}

class EdrPresentationAck {
  late int surfaceSessionId;
  late int activationId;
  late int presentationRevision;
  late bool suppressed;
  late EdrPresentationOutcome outcome;
  late int nativeGeneration;
  late int presentedAtNanos;
}

class EdrReadyAck {
  late int surfaceSessionId;
  late int activationId;
  late int contentRevision;
  late int presentationRevision;
  late bool accepted;
}

@HostApi()
abstract class EdrOverlayHostApi {
  void configureWindow(
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

  void updateWindowGeometry(
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

  @async
  EdrPresentationAck suspendWindow(
    int surfaceSessionId,
    int activationId,
    int presentationRevision,
  );

  void clearWindow(int surfaceSessionId, int activationId, int contentRevision);
}

@FlutterApi()
abstract class EdrOverlayFlutterApi {
  @async
  EdrReadyAck windowReady(
    int surfaceSessionId,
    int activationId,
    int contentRevision,
    int presentationRevision,
  );
}
