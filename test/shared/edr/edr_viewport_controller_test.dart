import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/summary/presentation/summary_visual_policy.dart';
import 'package:margaritaville_flutter/features/summary/presentation/widgets/room_status_tile.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/room_state.dart';
import 'package:margaritaville_flutter/shared/edr/edr_overlay_bridge.dart';
import 'package:margaritaville_flutter/shared/edr/edr_overlay_controller.dart';
import 'package:margaritaville_flutter/shared/edr/edr_overlay_scope.dart';
import 'package:margaritaville_flutter/shared/edr/generated/edr_overlay_api.g.dart';

void main() {
  testWidgets('fixed viewport owns every visible background without a pulse', (
    tester,
  ) async {
    final bridge = _RecordingEdrBridge();
    final controller = EdrOverlayController(bridge: bridge, supported: true);
    addTearDown(controller.dispose);
    final room = RoomState.pending(
      roomNumber: '147',
      selectedAt: DateTime(2027, 2, 10, 20, 47),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: EdrViewportScope(
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
                  child: _tile(
                    room,
                    policy: const SummaryVisualPolicy(statusPulseEnabled: true),
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
    expect(bridge.lastRevision, 1);
    expect(bridge.lastAnchorScrollOffset, 0);
    expect(bridge.lastTiles, hasLength(1));
    final snapshot = bridge.lastTiles.single;
    expect(snapshot.roomId, '147');
    expect(snapshot.left, closeTo(20, 0.01));
    expect(snapshot.top, closeTo(30, 0.01));
    expect(snapshot.width, closeTo(96, 0.01));
    expect(snapshot.height, closeTo(98, 0.01));
    expect(snapshot.vipHdrEnabled, isFalse);
    expect(snapshot.pulseGeneration, isNull);

    final surface = tester.widget<DecoratedBox>(
      find.byKey(const Key('summary-room-surface-147')),
    );
    expect((surface.decoration as BoxDecoration).color, Colors.transparent);
  });

  testWidgets('scroll sends one scalar then reanchors geometry at rest', (
    tester,
  ) async {
    final bridge = _RecordingEdrBridge();
    final controller = EdrOverlayController(bridge: bridge, supported: true);
    final scrollController = ScrollController();
    addTearDown(controller.dispose);
    addTearDown(scrollController.dispose);
    final room = RoomState.pending(
      roomNumber: '101',
      selectedAt: DateTime(2027, 2, 10, 20, 47),
    ).setVip(isVip: true, changedAt: DateTime(2027, 2, 10, 20, 48));

    await tester.pumpWidget(
      MaterialApp(
        home: EdrViewportScope(
          controller: controller,
          child: SizedBox(
            width: 220,
            height: 240,
            child: Stack(
              fit: StackFit.expand,
              children: [
                SizedBox.expand(key: controller.surfaceKey),
                ListView(
                  controller: scrollController,
                  children: [
                    const SizedBox(height: 40),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 96,
                        height: 98,
                        child: _tile(
                          room,
                          policy: const SummaryVisualPolicy(
                            vipHdrLightEnabled: true,
                            vipJellyEnabled: true,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 500),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    controller.attachView(18);
    await tester.pumpAndSettle();
    final initialTop = bridge.lastTiles.single.top;
    final initialConfigurationCount = bridge.configurationCount;

    scrollController.jumpTo(24);
    controller.updateScrollOffset(24);
    await tester.pumpAndSettle();

    expect(bridge.configurationCount, initialConfigurationCount);
    expect(bridge.scrollUpdates.last.offset, 24);
    expect(bridge.scrollUpdates.last.revision, bridge.lastRevision);

    controller.requestGeometrySync();
    await tester.pumpAndSettle();

    expect(bridge.configurationCount, initialConfigurationCount + 1);
    expect(bridge.lastAnchorScrollOffset, 24);
    expect(bridge.lastTiles.single.top, closeTo(initialTop - 24, 0.01));
    expect(bridge.lastTiles.single.vipHdrEnabled, isTrue);
    expect(bridge.lastTiles.single.vipJellyEnabled, isTrue);
  });
}

Widget _tile(RoomState room, {required SummaryVisualPolicy policy}) {
  return RoomStatusTile(
    room: room,
    visualPolicy: policy,
    onAdvance: () {},
    onReset: () {},
    onToggleVip: () {},
    onSchedule: () {},
    onOpenMedia: () {},
  );
}

final class _RecordingEdrBridge implements EdrOverlayBridge {
  int? lastViewId;
  int? lastRevision;
  double? lastAnchorScrollOffset;
  int configurationCount = 0;
  List<EdrTileSnapshot> lastTiles = const [];
  final scrollUpdates = <({int revision, int sequence, double offset})>[];

  @override
  Future<void> clearViewport(int viewId, int revision) async {
    lastViewId = viewId;
    lastRevision = revision;
    lastTiles = const [];
  }

  @override
  Future<void> configureViewport(
    int viewId,
    int revision,
    double scrollOffset,
    List<EdrTileSnapshot> tiles,
  ) async {
    lastViewId = viewId;
    lastRevision = revision;
    lastAnchorScrollOffset = scrollOffset;
    configurationCount++;
    lastTiles = List.of(tiles);
  }

  @override
  Future<void> updateScrollOffset(
    int viewId,
    int revision,
    int sequence,
    double scrollOffset,
  ) async {
    lastViewId = viewId;
    scrollUpdates.add((
      revision: revision,
      sequence: sequence,
      offset: scrollOffset,
    ));
  }
}
