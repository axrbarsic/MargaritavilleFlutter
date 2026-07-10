import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/design/margaritaville_colors.dart';
import 'package:margaritaville_flutter/features/summary/presentation/summary_visual_policy.dart';
import 'package:margaritaville_flutter/features/summary/presentation/summary_visual_pulse.dart';
import 'package:margaritaville_flutter/features/summary/presentation/widgets/room_status_light_painter.dart';
import 'package:margaritaville_flutter/features/summary/presentation/widgets/room_status_tile.dart';
import 'package:margaritaville_flutter/features/summary/presentation/widgets/room_visual_effect_surface.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/room_state.dart';
import 'package:margaritaville_flutter/shared/visual_runtime/visual_runtime_activity.dart';

void main() {
  testWidgets('effect stack paints the full grid slot, not child intrinsics', (
    tester,
  ) async {
    final selectedAt = DateTime(2027, 2, 10, 12);
    final room = RoomState.pending(roomNumber: '1', selectedAt: selectedAt);

    await tester.pumpWidget(
      _tile(room: room, policy: const SummaryVisualPolicy()),
    );

    expect(
      tester.getSize(find.byKey(const Key('summary-room-surface-1'))),
      const Size(96, 98),
    );
  });

  testWidgets('VIP HDR setting owns the static SDR light fallback', (
    tester,
  ) async {
    final selectedAt = DateTime(2027, 2, 10, 12);
    final room = RoomState.pending(
      roomNumber: '101',
      selectedAt: selectedAt,
    ).setVip(isVip: true, changedAt: selectedAt);
    const policy = SummaryVisualPolicy(
      vipJellyEnabled: false,
      vipHdrLightEnabled: true,
    );

    await tester.pumpWidget(_tile(room: room, policy: policy));

    expect(find.byKey(const Key('vip-light-layer-101')), findsOneWidget);
    expect(find.byKey(const Key('status-pulse-layer-101')), findsNothing);
    final light = tester.widget<CustomPaint>(
      find.byKey(const Key('vip-light-layer-101')),
    );
    final painter = light.painter! as RoomStatusLightPainter;
    expect(painter.color, MargaritavilleColors.vividStatus(room.displayStatus));
    expect(painter.fullFill, isFalse);
  });

  testWidgets('live-cell physics bends without pretending to be HDR', (
    tester,
  ) async {
    final startedAt = DateTime.now().subtract(
      const Duration(milliseconds: 580),
    );
    final room = RoomState.pending(roomNumber: '102', selectedAt: startedAt);
    final event = SummaryVisualPulseEvent(
      generation: 1,
      status: RoomDisplayStatus.pending,
      startedAt: startedAt,
    );
    const policy = SummaryVisualPolicy(
      liveCellsEnabled: true,
      statusPulseEnabled: false,
    );

    await tester.pumpWidget(
      _tile(room: room, policy: policy, pulseEvent: event),
    );

    expect(find.byKey(const Key('status-pulse-layer-102')), findsNothing);
  });

  testWidgets('status HDR setting mounts the same-color pulse layer', (
    tester,
  ) async {
    final startedAt = DateTime.now().subtract(
      const Duration(milliseconds: 580),
    );
    final room = RoomState.pending(roomNumber: '103', selectedAt: startedAt);
    final event = SummaryVisualPulseEvent(
      generation: 1,
      status: RoomDisplayStatus.pending,
      startedAt: startedAt,
    );
    const policy = SummaryVisualPolicy(statusPulseEnabled: true);

    await tester.pumpWidget(
      _tile(room: room, policy: policy, pulseEvent: event),
    );

    expect(find.byKey(const Key('status-pulse-layer-103')), findsOneWidget);
    final light = tester.widget<CustomPaint>(
      find.byKey(const Key('status-pulse-layer-103')),
    );
    final painter = light.painter! as RoomStatusLightPainter;
    expect(painter.color, MargaritavilleColors.vividStatus(event.status));
    expect(painter.fullFill, isTrue);
  });

  testWidgets('native EDR ownership releases the invisible Flutter clock', (
    tester,
  ) async {
    final selectedAt = DateTime(2027, 2, 10, 12);
    final room = RoomState.pending(
      roomNumber: '104',
      selectedAt: selectedAt,
    ).setVip(isVip: true, changedAt: selectedAt);
    const policy = SummaryVisualPolicy(
      vipJellyEnabled: true,
      vipHdrLightEnabled: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 96,
          height: 98,
          child: RoomVisualEffectSurface(
            room: room,
            baseColor: MargaritavilleColors.vividStatus(room.displayStatus),
            policy: policy,
            nativeEdrActive: true,
            nativeEdrManaged: true,
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('vip-jelly-shape-104')), findsNothing);
    expect(
      tester
          .widget<VisualRuntimeActivity>(find.byType(VisualRuntimeActivity))
          .active,
      isFalse,
    );
  });
}

Widget _tile({
  required RoomState room,
  required SummaryVisualPolicy policy,
  SummaryVisualPulseEvent? pulseEvent,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 96,
          height: 98,
          child: RoomStatusTile(
            room: room,
            visualPolicy: policy,
            pulseEvent: pulseEvent,
            onAdvance: () {},
            onReset: () {},
            onToggleVip: () {},
            onSchedule: () {},
            onOpenMedia: () {},
          ),
        ),
      ),
    ),
  );
}
