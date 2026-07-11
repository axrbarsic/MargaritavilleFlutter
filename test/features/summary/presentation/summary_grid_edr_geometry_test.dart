import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/app/margaritaville_theme.dart';
import 'package:margaritaville_flutter/features/summary/presentation/summary_screen.dart';
import 'package:margaritaville_flutter/features/summary/presentation/summary_visual_policy.dart';
import 'package:margaritaville_flutter/features/summary/presentation/widgets/summary_assignment_section.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/hotel_profile.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/housekeeper.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/room_state.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_assignment.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_session.dart';
import 'package:margaritaville_flutter/shared/edr/edr_overlay_bridge.dart';
import 'package:margaritaville_flutter/shared/edr/edr_overlay_controller.dart';
import 'package:margaritaville_flutter/shared/edr/edr_overlay_scope.dart';
import 'package:margaritaville_flutter/shared/edr/edr_window_surface.dart';
import 'package:margaritaville_flutter/shared/edr/generated/edr_overlay_api.g.dart';

void main() {
  testWidgets('EDR snapshot uses the actual three-column RenderBox bounds', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final bridge = _RecordingBridge();
    final controller = EdrOverlayController(bridge: bridge, supported: true);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: MargaritavilleTheme.dark,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 424,
              height: 500,
              child: EdrViewportScope(
                controller: controller,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    EdrWindowSurface(controller: controller),
                    Align(
                      alignment: Alignment.topCenter,
                      child: SummaryAssignmentSection(
                        assignment: _vipAssignment(),
                        visualPolicy: const SummaryVisualPolicy(
                          gridColumns: SummaryGridColumns.three,
                          vipHdrLightEnabled: true,
                        ),
                        onAdvance: (_) {},
                        onReset: (_) {},
                        onToggleVip: (_) {},
                        onSchedule: (_) {},
                        onOpenMedia: (_) {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump();
    await tester.pump();

    final tileSize = tester.getSize(find.byKey(const Key('summary-room-101')));
    final paintedSize = tester.getSize(
      find.byKey(const Key('summary-room-surface-101')),
    );
    final snapshot = bridge.tiles.single;
    expect(tileSize.width, closeTo(130.67, 0.01));
    expect(tileSize.height, 73.5);
    expect(paintedSize, tileSize);
    expect(snapshot.width, closeTo(tileSize.width, 0.001));
    expect(snapshot.height, tileSize.height);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('switching columns invalidates stable native EDR geometry', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(440, 956);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final bridge = _RecordingBridge();
    final controller = EdrOverlayController(bridge: bridge, supported: true);
    final columns = ValueNotifier(SummaryGridColumns.four);
    addTearDown(columns.dispose);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: MargaritavilleTheme.dark,
          home: ValueListenableBuilder(
            valueListenable: columns,
            builder: (context, value, _) => SummaryScreen(
              session: _vipSession(),
              edrController: controller,
              visualPolicy: SummaryVisualPolicy(
                gridColumns: value,
                vipHdrLightEnabled: true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump();
    await tester.pump();
    final fourColumnWidth = bridge.tiles.single.width;
    expect(bridge.tiles.single.height, 98);

    columns.value = SummaryGridColumns.three;
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(bridge.tiles.single.width, greaterThan(fourColumnWidth));
    expect(bridge.tiles.single.height, 73.5);

    columns.value = SummaryGridColumns.four;
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(bridge.tiles.single.width, closeTo(fourColumnWidth, 0.001));
    expect(bridge.tiles.single.height, 98);
    debugDefaultTargetPlatformOverride = null;
  });
}

WorkSession _vipSession() {
  final startedAt = DateTime(2027, 2, 10, 20, 47);
  return WorkSession.create(
    id: 'vip-session',
    hotel: HotelProfile.margaritaville,
    startedAt: startedAt,
    assignments: [_vipAssignment()],
  ).lockWorkday(changedAt: startedAt.add(const Duration(minutes: 1)));
}

WorkAssignment _vipAssignment() {
  final selectedAt = DateTime(2027, 2, 10, 20, 47);
  return WorkAssignment(
    id: 'assignment-1',
    cartNumber: 1,
    housekeeper: Housekeeper(
      id: 'ketty',
      displayName: 'Ketty',
      paletteKey: 'ruby',
      updatedAt: selectedAt,
    ),
    assignedAt: selectedAt,
    updatedAt: selectedAt,
    rooms: [
      RoomState.pending(
        roomNumber: '101',
        selectedAt: selectedAt,
      ).setVip(isVip: true, changedAt: selectedAt),
    ],
  );
}

final class _RecordingBridge implements EdrOverlayBridge {
  List<EdrTileSnapshot> tiles = const [];

  @override
  Future<void> clearWindow(
    int surfaceSessionId,
    int activationId,
    int contentRevision,
  ) async {}

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
    this.tiles = List.unmodifiable(tiles);
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
  Future<void> suspendWindow(
    int surfaceSessionId,
    int activationId,
    int presentationRevision,
  ) async {}
}
