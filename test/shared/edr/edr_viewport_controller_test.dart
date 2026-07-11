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

part 'edr_bridge_test_support.dart';

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
    final firstConfiguration = bridge.configurations.single;
    final firstRevision = firstConfiguration.contentRevision;

    await tester.pumpWidget(_controllerHost(controller, secondRenderKey));
    _registerTile(controller, secondRenderKey);
    controller.removeTile('101', renderKey: firstRenderKey);
    await tester.pump();
    expect(controller.isTileRendered('101', secondRenderKey), isFalse);

    bridge.complete(firstRevision);
    await tester.pump();
    EdrReadyRouter.instance.windowReady(
      controller.surfaceSessionId,
      firstConfiguration.activationId,
      firstRevision,
    );
    await tester.pump();
    expect(controller.isTileRendered('101', secondRenderKey), isFalse);
    expect(bridge.pendingCount, 1);
    expect(bridge.lastTiles.single.roomId, '101');

    final secondConfiguration = bridge.configurations.last;
    final secondRevision = secondConfiguration.contentRevision;
    bridge.complete(secondRevision);
    await tester.pump();
    EdrReadyRouter.instance.windowReady(
      controller.surfaceSessionId,
      secondConfiguration.activationId,
      secondRevision,
    );
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
      final firstConfiguration = bridge.configurations.single;
      final firstRevision = firstConfiguration.contentRevision;
      EdrReadyRouter.instance.windowReady(
        controller.surfaceSessionId,
        firstConfiguration.activationId,
        firstRevision,
      );
      await tester.pump();
      expect(controller.isTileRendered('101', renderKey), isTrue);

      controller.setWindowVisible(false);
      await tester.pump();
      expect(controller.isTileRendered('101', renderKey), isFalse);
      expect(bridge.clears, isNotEmpty);
      expect(bridge.clears.last.$2, firstConfiguration.activationId);

      controller.setWindowVisible(true);
      await tester.pump();
      final restoredConfiguration = bridge.configurations.last;
      final restoredRevision = restoredConfiguration.contentRevision;
      expect(restoredRevision, greaterThan(firstRevision));
      expect(
        restoredConfiguration.activationId,
        greaterThan(firstConfiguration.activationId),
      );
      EdrReadyRouter.instance.windowReady(
        controller.surfaceSessionId,
        firstConfiguration.activationId,
        restoredRevision,
      );
      await tester.pump();
      expect(controller.isTileRendered('101', renderKey), isFalse);

      EdrReadyRouter.instance.windowReady(
        controller.surfaceSessionId,
        restoredConfiguration.activationId,
        restoredRevision,
      );
      await tester.pump();
      expect(controller.isTileRendered('101', renderKey), isTrue);
    },
  );

  testWidgets(
    'stable membership sends offset only and preserves native ownership',
    (tester) async {
      final bridge = _RecordingEdrBridge();
      final controller = EdrOverlayController(bridge: bridge, supported: true);
      final renderKey = GlobalKey();
      final renderState = ValueNotifier(false);
      addTearDown(controller.dispose);
      addTearDown(renderState.dispose);

      await tester.pumpWidget(_controllerHost(controller, renderKey));
      _registerTile(controller, renderKey, renderState: renderState);
      controller.attachWindow();
      await tester.pump();
      final configuration = bridge.configurations.single;
      EdrReadyRouter.instance.windowReady(
        controller.surfaceSessionId,
        configuration.activationId,
        configuration.contentRevision,
      );
      await tester.pump();
      expect(renderState.value, isTrue);
      expect(configuration.tiles.single.top, 30);

      controller.updateScrollOffset(const Offset(0, 42));
      expect(bridge.geometries, hasLength(1));
      expect(bridge.geometries.single.scrollOffset, const Offset(0, 42));
      await tester.pump();

      expect(bridge.configurations, hasLength(1));
      expect(bridge.geometries, hasLength(1));
      expect(bridge.geometries.single.scrollOffset, const Offset(0, 42));
      expect(renderState.value, isTrue);

      controller.updateScrollOffset(const Offset(0, -18.5));
      await tester.pump();

      expect(bridge.configurations, hasLength(1));
      expect(bridge.geometries, hasLength(2));
      expect(bridge.geometries.last.scrollOffset.dy, -18.5);
      expect(renderState.value, isTrue);
    },
  );

  testWidgets(
    'membership change restores removed fallback and waits for new ready',
    (tester) async {
      final bridge = _RecordingEdrBridge();
      final controller = EdrOverlayController(bridge: bridge, supported: true);
      final firstKey = GlobalKey();
      final secondKey = GlobalKey();
      final firstState = ValueNotifier(false);
      final secondState = ValueNotifier(false);
      addTearDown(controller.dispose);
      addTearDown(firstState.dispose);
      addTearDown(secondState.dispose);

      await tester.pumpWidget(
        _controllerHostWithPositions(controller, {
          firstKey: 30,
          secondKey: 700,
        }),
      );
      _registerTile(controller, firstKey, renderState: firstState);
      _registerTile(
        controller,
        secondKey,
        roomId: '202',
        renderState: secondState,
      );
      controller.attachWindow();
      await tester.pump();
      final firstConfiguration = bridge.configurations.single;
      final firstRevision = firstConfiguration.contentRevision;
      expect(bridge.configurations.single.tiles.map((tile) => tile.roomId), [
        '101',
      ]);
      EdrReadyRouter.instance.windowReady(
        controller.surfaceSessionId,
        firstConfiguration.activationId,
        firstRevision,
      );
      await tester.pump();
      expect(firstState.value, isTrue);
      expect(secondState.value, isFalse);

      controller.updateScrollOffset(const Offset(0, 500));
      await tester.pump();

      expect(bridge.configurations, hasLength(2));
      expect(bridge.configurations.last.tiles.map((tile) => tile.roomId), [
        '202',
      ]);
      expect(firstState.value, isFalse);
      expect(secondState.value, isFalse);

      final secondConfiguration = bridge.configurations.last;
      final secondRevision = secondConfiguration.contentRevision;
      EdrReadyRouter.instance.windowReady(
        controller.surfaceSessionId,
        secondConfiguration.activationId,
        secondRevision,
      );
      await tester.pump();
      expect(firstState.value, isFalse);
      expect(secondState.value, isTrue);
    },
  );

  testWidgets('readiness from another Summary session is ignored', (
    tester,
  ) async {
    final bridge = _RecordingEdrBridge();
    final controller = EdrOverlayController(bridge: bridge, supported: true);
    final renderKey = GlobalKey();
    addTearDown(controller.dispose);

    await tester.pumpWidget(_controllerHost(controller, renderKey));
    _registerTile(controller, renderKey);
    controller.attachWindow();
    await tester.pump();
    final configuration = bridge.configurations.single;
    final revision = configuration.contentRevision;

    EdrReadyRouter.instance.windowReady(
      controller.surfaceSessionId + 1,
      configuration.activationId,
      revision,
    );
    await tester.pump();

    expect(controller.isTileRendered('101', renderKey), isFalse);
  });
}
