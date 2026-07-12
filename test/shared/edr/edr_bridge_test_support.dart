part of 'edr_viewport_controller_test.dart';

Widget _controllerHost(EdrOverlayController controller, GlobalKey renderKey) {
  return MaterialApp(
    home: Center(
      child: SizedBox(
        key: controller.surfaceKey,
        width: 220,
        height: 240,
        child: Stack(
          children: [
            Positioned(
              left: 20,
              top: 30,
              width: 96,
              height: 98,
              child: SizedBox.expand(key: renderKey),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _controllerHostWithPositions(
  EdrOverlayController controller,
  Map<GlobalKey, double> tileTops,
) {
  return MaterialApp(
    home: Center(
      child: SizedBox(
        key: controller.surfaceKey,
        width: 220,
        height: 240,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (final entry in tileTops.entries)
              Positioned(
                left: 20,
                top: entry.value,
                width: 96,
                height: 98,
                child: SizedBox.expand(key: entry.key),
              ),
          ],
        ),
      ),
    ),
  );
}

void _registerTile(
  EdrOverlayController controller,
  GlobalKey renderKey, {
  String roomId = '101',
  ValueNotifier<bool>? renderState,
}) {
  controller.upsertTile(
    roomId: roomId,
    timeText: '8:17 PM',
    renderKey: renderKey,
    renderState: renderState ?? ValueNotifier(false),
    baseColorArgb: 0xFF00E524,
    cornerRadius: 16,
    vipHdrEnabled: true,
    vipJellyEnabled: true,
    vipJellySpeed: 0.75,
    springIntensity: 0.72,
  );
}

typedef _ConfigurationCall = ({
  int surfaceSessionId,
  int activationId,
  int layoutGeneration,
  int contentRevision,
  int presentationRevision,
  int geometryRevision,
  Rect viewport,
  Offset scrollOffset,
  List<EdrTileSnapshot> tiles,
});

typedef _GeometryCall = ({
  int surfaceSessionId,
  int activationId,
  int layoutGeneration,
  int presentationRevision,
  int geometryRevision,
  Rect viewport,
  Offset scrollOffset,
});

class _RecordingEdrBridge implements EdrOverlayBridge {
  final configurations = <_ConfigurationCall>[];
  final geometries = <_GeometryCall>[];
  final suspensions = <(int, int, int)>[];
  final clears = <(int, int, int)>[];

  List<EdrTileSnapshot> get lastTiles =>
      configurations.isEmpty ? const [] : configurations.last.tiles;

  @override
  Future<void> clearWindow(
    int surfaceSessionId,
    int activationId,
    int contentRevision,
  ) async {
    clears.add((surfaceSessionId, activationId, contentRevision));
  }

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
  ) async {
    configurations.add((
      surfaceSessionId: surfaceSessionId,
      activationId: activationId,
      layoutGeneration: layoutGeneration,
      contentRevision: contentRevision,
      presentationRevision: presentationRevision,
      geometryRevision: geometryRevision,
      viewport: Rect.fromLTWH(
        viewportLeft,
        viewportTop,
        viewportWidth,
        viewportHeight,
      ),
      scrollOffset: Offset(scrollOffsetX, scrollOffsetY),
      tiles: List.unmodifiable(tiles),
    ));
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
  ) async {
    geometries.add((
      surfaceSessionId: surfaceSessionId,
      activationId: activationId,
      layoutGeneration: layoutGeneration,
      presentationRevision: presentationRevision,
      geometryRevision: geometryRevision,
      viewport: Rect.fromLTWH(
        viewportLeft,
        viewportTop,
        viewportWidth,
        viewportHeight,
      ),
      scrollOffset: Offset(scrollOffsetX, scrollOffsetY),
    ));
  }

  @override
  Future<EdrPresentationAck> suspendWindow(
    int surfaceSessionId,
    int activationId,
    int presentationRevision,
  ) async {
    suspensions.add((surfaceSessionId, activationId, presentationRevision));
    return EdrPresentationAck(
      surfaceSessionId: surfaceSessionId,
      activationId: activationId,
      presentationRevision: presentationRevision,
      suppressed: true,
      outcome: EdrPresentationOutcome.transparentPresented,
      nativeGeneration: presentationRevision + 1,
      presentedAtNanos: 1,
    );
  }
}

final class _DeferredEdrBridge extends _RecordingEdrBridge {
  final _pending = <int, Completer<void>>{};

  int get pendingCount => _pending.length;

  void complete(int revision) {
    _pending.remove(revision)!.complete();
  }

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
  ) async {
    await super.configureWindow(
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
    final completer = Completer<void>();
    _pending[contentRevision] = completer;
    await completer.future;
  }
}

final class _DeferredGeometryEdrBridge extends _RecordingEdrBridge {
  final _pendingGeometry = <Completer<void>>[];
  var activeGeometryCalls = 0;
  var maximumActiveGeometryCalls = 0;

  int get pendingGeometryCount => _pendingGeometry.length;

  void completeNextGeometry() {
    _pendingGeometry.removeAt(0).complete();
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
  ) async {
    await super.updateWindowGeometry(
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
    activeGeometryCalls += 1;
    maximumActiveGeometryCalls = max(
      maximumActiveGeometryCalls,
      activeGeometryCalls,
    );
    final completer = Completer<void>();
    _pendingGeometry.add(completer);
    await completer.future;
    activeGeometryCalls -= 1;
  }
}
