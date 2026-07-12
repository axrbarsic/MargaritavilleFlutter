import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/shared/edr/edr_overlay_bridge.dart';
import 'package:margaritaville_flutter/shared/edr/edr_overlay_controller.dart';
import 'package:margaritaville_flutter/shared/edr/edr_ready_router.dart';
import 'package:margaritaville_flutter/shared/edr/edr_window_surface.dart';
import 'package:margaritaville_flutter/shared/edr/generated/edr_overlay_api.g.dart';

void main() {
  testWidgets(
    '4 to 3 to 4 layout waits for exact native frame acknowledgement',
    (tester) async {
      final bridge = _RecordingBridge();
      final controller = EdrOverlayController(bridge: bridge, supported: true);
      final renderKey = GlobalKey();
      final renderState = ValueNotifier(false);
      addTearDown(controller.dispose);
      addTearDown(renderState.dispose);

      await tester.pumpWidget(
        _host(controller, renderKey, width: 72.4, height: 72.4),
      );
      _register(controller, renderKey, renderState);
      controller.attachWindow();
      await tester.pump();
      final first = bridge.configurations.single;
      _ack(controller, first);
      await tester.pump();
      expect(renderState.value, isTrue);
      expect(first.tiles.single, _hasSize(72.4, 72.4));

      await tester.pumpWidget(
        _host(controller, renderKey, width: 99.2, height: 72.4),
      );
      controller.requestGeometrySync();
      await tester.pump();
      final second = bridge.configurations.last;
      expect(second.tiles.single, _hasSize(99.2, 72.4));
      expect(renderState.value, isFalse);

      _ack(controller, first);
      await tester.pump();
      expect(renderState.value, isFalse);
      _ack(controller, second);
      await tester.pump();
      expect(renderState.value, isTrue);

      await tester.pumpWidget(
        _host(controller, renderKey, width: 72.4, height: 72.4),
      );
      controller.requestGeometrySync();
      await tester.pump();
      final third = bridge.configurations.last;
      expect(third.tiles.single, _hasSize(72.4, 72.4));
      expect(renderState.value, isFalse);
      _ack(controller, third);
      await tester.pump();
      expect(renderState.value, isTrue);
    },
  );

  testWidgets('width-only surface resize creates a new layout generation', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final bridge = _RecordingBridge();
    final controller = EdrOverlayController(bridge: bridge, supported: true);
    final renderKey = GlobalKey();
    final renderState = ValueNotifier(false);
    final width = ValueNotifier(300.0);
    addTearDown(controller.dispose);
    addTearDown(renderState.dispose);
    addTearDown(width.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: ValueListenableBuilder<double>(
            valueListenable: width,
            builder: (context, value, _) => SizedBox(
              width: value,
              height: 300,
              child: Stack(
                children: [
                  EdrWindowSurface(controller: controller),
                  Positioned(
                    left: 20,
                    top: 30,
                    width: value / 4,
                    height: 72.4,
                    child: SizedBox(key: renderKey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    _register(controller, renderKey, renderState);
    controller.requestGeometrySync();
    await tester.pump();
    await tester.pump();
    await tester.pump();
    await tester.pump();
    final first = bridge.configurations.last;

    width.value = 320;
    await tester.pump();
    await tester.pump();
    await tester.pump();
    final resized = bridge.configurations.last;

    expect(resized.layoutGeneration, greaterThan(first.layoutGeneration));
    expect(first.tiles.single.width, closeTo(75, 0.01));
    expect(resized.tiles.single.width, closeTo(80, 0.01));
    debugDefaultTargetPlatformOverride = null;
  });
}

Matcher _hasSize(double width, double height) => isA<EdrTileSnapshot>()
    .having((tile) => tile.width, 'width', closeTo(width, 0.01))
    .having((tile) => tile.height, 'height', height);

void _ack(EdrOverlayController controller, _Configuration configuration) {
  unawaited(
    EdrReadyRouter.instance.windowReady(
      controller.surfaceSessionId,
      configuration.activationId,
      configuration.contentRevision,
      configuration.presentationRevision,
    ),
  );
}

void _register(
  EdrOverlayController controller,
  GlobalKey renderKey,
  ValueNotifier<bool> renderState,
) {
  controller.upsertTile(
    roomId: '101',
    timeText: '8:17 PM',
    renderKey: renderKey,
    renderState: renderState,
    baseColorArgb: 0xFF00E524,
    cornerRadius: 16,
    vipHdrEnabled: true,
    vipJellyEnabled: true,
    vipJellySpeed: 0.75,
    springIntensity: 0.72,
  );
}

Widget _host(
  EdrOverlayController controller,
  GlobalKey renderKey, {
  required double width,
  required double height,
}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        children: [
          SizedBox.expand(key: controller.surfaceKey),
          Positioned(
            left: 20,
            top: 30,
            width: width,
            height: height,
            child: SizedBox(key: renderKey),
          ),
        ],
      ),
    ),
  );
}

final class _Configuration {
  const _Configuration({
    required this.activationId,
    required this.layoutGeneration,
    required this.contentRevision,
    required this.presentationRevision,
    required this.tiles,
  });

  final int activationId;
  final int layoutGeneration;
  final int contentRevision;
  final int presentationRevision;
  final List<EdrTileSnapshot> tiles;
}

final class _RecordingBridge implements EdrOverlayBridge {
  final configurations = <_Configuration>[];

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
    configurations.add(
      _Configuration(
        activationId: activationId,
        layoutGeneration: layoutGeneration,
        contentRevision: contentRevision,
        presentationRevision: presentationRevision,
        tiles: List.unmodifiable(tiles),
      ),
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
  ) async {}

  @override
  Future<EdrPresentationAck> suspendWindow(
    int surfaceSessionId,
    int activationId,
    int presentationRevision,
  ) async => EdrPresentationAck(
    surfaceSessionId: surfaceSessionId,
    activationId: activationId,
    presentationRevision: presentationRevision,
    suppressed: true,
    outcome: EdrPresentationOutcome.transparentPresented,
    nativeGeneration: presentationRevision + 1,
    presentedAtNanos: 1,
  );

  @override
  Future<void> clearWindow(
    int surfaceSessionId,
    int activationId,
    int contentRevision,
  ) async {}
}
