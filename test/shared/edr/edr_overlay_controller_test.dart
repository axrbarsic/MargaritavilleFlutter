import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/summary/presentation/summary_visual_policy.dart';
import 'package:margaritaville_flutter/features/summary/presentation/summary_visual_pulse.dart';
import 'package:margaritaville_flutter/features/summary/presentation/widgets/room_status_tile.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/room_state.dart';
import 'package:margaritaville_flutter/shared/edr/edr_overlay_bridge.dart';
import 'package:margaritaville_flutter/shared/edr/edr_overlay_controller.dart';
import 'package:margaritaville_flutter/shared/edr/edr_overlay_scope.dart';
import 'package:margaritaville_flutter/shared/edr/generated/edr_overlay_api.g.dart';

void main() {
  testWidgets('batches logical tile bounds before revealing native EDR', (
    tester,
  ) async {
    final bridge = _FakeEdrOverlayBridge();
    final controller = EdrOverlayController(bridge: bridge, supported: true);
    addTearDown(controller.dispose);
    final startedAt = DateTime.now().subtract(
      const Duration(milliseconds: 580),
    );
    final room = RoomState.pending(roomNumber: '147', selectedAt: startedAt);
    final pulse = SummaryVisualPulseEvent(
      generation: 4,
      status: room.displayStatus,
      startedAt: startedAt,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: EdrOverlayScope(
          controller: controller,
          child: SizedBox(
            width: 220,
            height: 240,
            child: Stack(
              children: [
                Positioned.fill(
                  child: SizedBox.expand(key: controller.surfaceKey),
                ),
                Positioned(
                  left: 20,
                  top: 30,
                  width: 96,
                  height: 98,
                  child: RoomStatusTile(
                    room: room,
                    pulseEvent: pulse,
                    visualPolicy: const SummaryVisualPolicy(
                      statusPulseEnabled: true,
                    ),
                    onAdvance: () {},
                    onReset: () {},
                    onToggleVip: () {},
                    onSchedule: () {},
                    onOpenMedia: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    controller.attachView(17);
    await tester.pumpAndSettle();

    expect(bridge.lastViewId, 17);
    expect(bridge.lastTiles, hasLength(1));
    final snapshot = bridge.lastTiles.single;
    expect(snapshot.roomId, '147');
    expect(snapshot.left, closeTo(20, 0.01));
    expect(snapshot.top, closeTo(30, 0.01));
    expect(snapshot.width, closeTo(96, 0.01));
    expect(snapshot.height, closeTo(98, 0.01));
    expect(snapshot.pulseGeneration, 4);
    expect(snapshot.pulseStartedAtMicros, startedAt.microsecondsSinceEpoch);
    expect(snapshot.vipJellyEnabled, isFalse);
    expect(snapshot.vipJellySpeed, 0.75);

    final surface = tester.widget<DecoratedBox>(
      find.byKey(const Key('summary-room-surface-147')),
    );
    expect((surface.decoration as BoxDecoration).color, Colors.transparent);
  });

  testWidgets('keeps VIP jelly geometry active over native EDR', (
    tester,
  ) async {
    final bridge = _FakeEdrOverlayBridge();
    final controller = EdrOverlayController(bridge: bridge, supported: true);
    addTearDown(controller.dispose);
    final selectedAt = DateTime(2027, 2, 10, 12);
    final room = RoomState.pending(
      roomNumber: '101',
      selectedAt: selectedAt,
    ).setVip(isVip: true, changedAt: selectedAt);

    await tester.pumpWidget(
      MaterialApp(
        home: EdrOverlayScope(
          controller: controller,
          child: SizedBox(
            width: 220,
            height: 240,
            child: Stack(
              children: [
                Positioned.fill(
                  child: SizedBox.expand(key: controller.surfaceKey),
                ),
                Positioned(
                  left: 20,
                  top: 30,
                  width: 96,
                  height: 98,
                  child: RoomStatusTile(
                    room: room,
                    visualPolicy: const SummaryVisualPolicy(
                      vipHdrLightEnabled: true,
                      vipJellyEnabled: true,
                      vipJellySpeed: 0.75,
                    ),
                    onAdvance: () {},
                    onReset: () {},
                    onToggleVip: () {},
                    onSchedule: () {},
                    onOpenMedia: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    controller.attachView(18);
    await tester.pumpAndSettle();

    expect(bridge.lastTiles.single.vipJellyEnabled, isTrue);
    expect(bridge.lastTiles.single.vipJellySpeed, 0.75);
    expect(find.byKey(const Key('vip-jelly-shape-101')), findsOneWidget);
  });
}

final class _FakeEdrOverlayBridge implements EdrOverlayBridge {
  int? lastViewId;
  List<EdrTileSnapshot> lastTiles = const [];

  @override
  Future<void> clearTiles(int viewId) async {
    lastViewId = viewId;
    lastTiles = const [];
  }

  @override
  Future<void> updateTiles(int viewId, List<EdrTileSnapshot> tiles) async {
    lastViewId = viewId;
    lastTiles = List.of(tiles);
  }
}
