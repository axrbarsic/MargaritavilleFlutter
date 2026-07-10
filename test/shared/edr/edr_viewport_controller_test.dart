import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/design/margaritaville_colors.dart';
import 'package:margaritaville_flutter/features/summary/presentation/summary_visual_policy.dart';
import 'package:margaritaville_flutter/features/summary/presentation/summary_visual_pulse.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/room_state.dart';
import 'package:margaritaville_flutter/shared/edr/edr_overlay_bridge.dart';
import 'package:margaritaville_flutter/shared/edr/edr_overlay_controller.dart';
import 'package:margaritaville_flutter/shared/edr/edr_ready_router.dart';
import 'package:margaritaville_flutter/shared/edr/edr_tile_snapshot_factory.dart';
import 'package:margaritaville_flutter/shared/edr/generated/edr_overlay_api.g.dart';

void main() {
  test('row snapshot keeps donor EDR and additive colors separate', () {
    final startedAt = DateTime(2027, 2, 10, 20, 47);
    final room = RoomState.pending(roomNumber: '209', selectedAt: startedAt);
    final pulse = SummaryVisualPulseEvent(
      generation: 7,
      status: RoomDisplayStatus.ready,
      startedAt: startedAt,
    );

    final snapshot = EdrTileSnapshotFactory.create(
      room: room,
      policy: const SummaryVisualPolicy(
        statusPulseEnabled: true,
        vividStatusPaletteEnabled: false,
      ),
      pulseEvent: pulse,
      left: 20,
      width: 96,
    );

    expect(snapshot.left, 20);
    expect(snapshot.width, 96);
    expect(snapshot.pulseGeneration, 7);
    expect(
      snapshot.pulseColorArgb,
      MargaritavilleColors.status(RoomDisplayStatus.ready).toARGB32(),
    );
    expect(
      snapshot.pulseBoostColorArgb,
      MargaritavilleColors.vividStatus(RoomDisplayStatus.ready).toARGB32(),
    );
  });

  testWidgets('stale acknowledgement cannot own a recycled tile generation', (
    tester,
  ) async {
    final bridge = _DeferredEdrBridge();
    final controller = EdrOverlayController(bridge: bridge, supported: true);
    final firstRenderKey = GlobalKey();
    final secondRenderKey = GlobalKey();
    addTearDown(controller.dispose);

    await tester.pumpWidget(_controllerHost(controller, firstRenderKey));
    _registerTile(controller, firstRenderKey);
    controller.attachWindow();
    await tester.pump();
    expect(bridge.pendingCount, 1);

    await tester.pumpWidget(_controllerHost(controller, secondRenderKey));
    _registerTile(controller, secondRenderKey);
    controller.removeTile('101', renderKey: firstRenderKey);
    await tester.pump();
    expect(controller.isTileRendered('101', secondRenderKey), isFalse);

    bridge.completeOldest();
    await tester.pump();
    EdrReadyRouter.instance.windowReady(1);
    await tester.pump();
    expect(controller.isTileRendered('101', secondRenderKey), isFalse);
    expect(bridge.pendingCount, 1);
    expect(bridge.lastTiles.single.roomId, '101');

    bridge.completeOldest();
    await tester.pump();
    EdrReadyRouter.instance.windowReady(2);
    await tester.pump();
    expect(controller.isTileRendered('101', secondRenderKey), isTrue);
  });

  testWidgets(
    'modal visibility clears native ownership and restores it fresh',
    (tester) async {
      final bridge = _RecordingEdrBridge();
      final controller = EdrOverlayController(bridge: bridge, supported: true);
      final renderKey = GlobalKey();
      addTearDown(controller.dispose);

      await tester.pumpWidget(_controllerHost(controller, renderKey));
      _registerTile(controller, renderKey);
      controller.attachWindow();
      await tester.pump();
      EdrReadyRouter.instance.windowReady(1);
      await tester.pump();
      expect(controller.isTileRendered('101', renderKey), isTrue);

      controller.setWindowVisible(false);
      await tester.pump();
      expect(controller.isTileRendered('101', renderKey), isFalse);
      expect(bridge.lastTiles, isEmpty);

      controller.setWindowVisible(true);
      await tester.pump();
      expect(bridge.lastRevision, 3);
      EdrReadyRouter.instance.windowReady(3);
      await tester.pump();
      expect(controller.isTileRendered('101', renderKey), isTrue);
    },
  );
}

Widget _controllerHost(EdrOverlayController controller, GlobalKey renderKey) {
  return MaterialApp(
    home: SizedBox(
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
  );
}

void _registerTile(EdrOverlayController controller, GlobalKey renderKey) {
  controller.upsertTile(
    roomId: '101',
    timeText: '8:17 PM',
    renderKey: renderKey,
    renderState: ValueNotifier(false),
    baseColorArgb: 0xFF00E524,
    cornerRadius: 16,
    vipHdrEnabled: true,
    vipJellyEnabled: true,
    vipJellySpeed: 0.75,
    springIntensity: 0.72,
  );
}

final class _RecordingEdrBridge implements EdrOverlayBridge {
  int? lastRevision;
  Rect? lastViewport;
  int configurationCount = 0;
  List<EdrTileSnapshot> lastTiles = const [];

  @override
  Future<void> clearWindow(int revision) async {
    lastRevision = revision;
    lastViewport = null;
    lastTiles = const [];
  }

  @override
  Future<void> configureWindow(
    int revision,
    double viewportLeft,
    double viewportTop,
    double viewportWidth,
    double viewportHeight,
    List<EdrTileSnapshot> tiles,
  ) async {
    lastRevision = revision;
    lastViewport = Rect.fromLTWH(
      viewportLeft,
      viewportTop,
      viewportWidth,
      viewportHeight,
    );
    configurationCount++;
    lastTiles = List.of(tiles);
  }
}

final class _DeferredEdrBridge extends _RecordingEdrBridge {
  final _pending = <Completer<void>>[];

  int get pendingCount => _pending.length;

  void completeOldest() {
    _pending.removeAt(0).complete();
  }

  @override
  Future<void> configureWindow(
    int revision,
    double viewportLeft,
    double viewportTop,
    double viewportWidth,
    double viewportHeight,
    List<EdrTileSnapshot> tiles,
  ) async {
    await super.configureWindow(
      revision,
      viewportLeft,
      viewportTop,
      viewportWidth,
      viewportHeight,
      tiles,
    );
    final completer = Completer<void>();
    _pending.add(completer);
    await completer.future;
  }
}
