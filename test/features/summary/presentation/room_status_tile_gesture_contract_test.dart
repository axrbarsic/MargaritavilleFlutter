import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interaction_foundation/interaction_foundation.dart';
import 'package:margaritaville_flutter/app/margaritaville_theme.dart';
import 'package:margaritaville_flutter/features/interaction/application/margaritaville_feedback_controller.dart';
import 'package:margaritaville_flutter/features/interaction/presentation/controllers/interaction_sound_settings_controller.dart';
import 'package:margaritaville_flutter/features/interaction/presentation/margaritaville_feedback_scope.dart';
import 'package:margaritaville_flutter/features/summary/presentation/summary_swipe_commit_policy.dart';
import 'package:margaritaville_flutter/features/summary/presentation/widgets/room_status_tile.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/room_state.dart';

import 'support/feedback_test_support.dart';

void main() {
  testWidgets('room hold commits at the donor 460 ms deadline', (tester) async {
    final harness = _RoomGestureHarness();
    addTearDown(harness.dispose);
    await tester.pumpWidget(harness.app());
    await tester.pump();

    final hold = await tester.startGesture(harness.tileCenter(tester));
    await tester.pump(const Duration(milliseconds: 459));
    expect(harness.advances, 0);
    expect(harness.cues, isEmpty);

    await tester.pump(const Duration(milliseconds: 1));
    expect(harness.advances, 1);
    expect(harness.cues, const [InteractionFeedbackCue.holdCommit]);

    await tester.pump(const Duration(milliseconds: 200));
    await hold.up();
    expect(harness.advances, 1);
  });

  testWidgets('room hold cancels immediately beyond eight points', (
    tester,
  ) async {
    final harness = _RoomGestureHarness();
    addTearDown(harness.dispose);
    await tester.pumpWidget(harness.app());
    await tester.pump();

    final hold = await tester.startGesture(harness.tileCenter(tester));
    await hold.moveBy(const Offset(8.01, 0));
    await tester.pump(const Duration(milliseconds: 600));
    await hold.up();

    expect(harness.advances, 0);
    expect(harness.cues, isEmpty);
  });

  testWidgets('room hold still accepts exactly eight points', (tester) async {
    final harness = _RoomGestureHarness();
    addTearDown(harness.dispose);
    await tester.pumpWidget(harness.app());
    await tester.pump();

    final hold = await tester.startGesture(harness.tileCenter(tester));
    await hold.moveBy(const Offset(8, 0));
    await tester.pump(const Duration(milliseconds: 460));
    await hold.up();

    expect(harness.advances, 1);
    expect(harness.cues, const [InteractionFeedbackCue.holdCommit]);
  });

  testWidgets('diagonal vertical intent through a room keeps scrolling', (
    tester,
  ) async {
    final harness = _RoomGestureHarness();
    addTearDown(harness.dispose);
    await tester.pumpWidget(harness.app());
    await tester.pump();

    final drag = await tester.startGesture(harness.tileCenter(tester));
    await drag.moveBy(const Offset(20, -20));
    await tester.pump();
    await drag.moveBy(const Offset(0, -60));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await drag.up();

    expect(harness.scrollController.offset, greaterThan(0));
    expect(harness.advances, 0);
    expect(harness.cues, isEmpty);
    expect(find.byKey(const Key('room-action-media')), findsNothing);
  });

  testWidgets('donor-invalid diagonal right swipe cannot open actions', (
    tester,
  ) async {
    final harness = _RoomGestureHarness();
    addTearDown(harness.dispose);
    await tester.pumpWidget(harness.app());
    await tester.pump();

    final width = tester.getSize(harness.tile).width;
    final threshold = SummarySwipeCommitPolicy.compactThreshold(width);
    final dx = threshold * 1.1;
    final drag = await tester.startGesture(harness.tileCenter(tester));
    await drag.moveBy(Offset(dx, dx / 2.4));
    await tester.pump();
    await drag.up();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('room-action-media')), findsNothing);
    expect(harness.advances, 0);
    expect(harness.cues, isEmpty);
  });

  testWidgets('left swipe remains completely inert', (tester) async {
    final harness = _RoomGestureHarness();
    addTearDown(harness.dispose);
    await tester.pumpWidget(harness.app());
    await tester.pump();

    final width = tester.getSize(harness.tile).width;
    final threshold = SummarySwipeCommitPolicy.compactThreshold(width);
    final drag = await tester.startGesture(harness.tileCenter(tester));
    await drag.moveBy(Offset(-threshold * 1.1, 0));
    await tester.pump(const Duration(milliseconds: 600));
    await drag.up();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('room-action-media')), findsNothing);
    expect(harness.advances, 0);
    expect(harness.cues, isEmpty);
  });

  testWidgets('right swipe emits donor threshold feedback in order', (
    tester,
  ) async {
    final harness = _RoomGestureHarness();
    addTearDown(harness.dispose);
    await tester.pumpWidget(harness.app());
    await tester.pump();

    final width = tester.getSize(harness.tile).width;
    final threshold = SummarySwipeCommitPolicy.compactThreshold(width);
    final origin = harness.tileCenter(tester);
    final drag = await tester.startGesture(origin);
    await drag.moveTo(origin + Offset(threshold * 0.85, 0));
    await tester.pump();
    expect(harness.cues, isEmpty);

    await drag.moveTo(origin + Offset(threshold * 0.87, 0));
    await tester.pump();
    expect(harness.cues, const [InteractionFeedbackCue.holdStart]);

    await drag.moveTo(origin + Offset(threshold * 0.95, 0));
    await tester.pump();
    expect(harness.cues, const [
      InteractionFeedbackCue.holdStart,
      InteractionFeedbackCue.holdWarning,
    ]);

    await drag.moveTo(origin + Offset(threshold * 1.01, 0));
    await tester.pump();
    expect(harness.cues, const [
      InteractionFeedbackCue.holdStart,
      InteractionFeedbackCue.holdWarning,
      InteractionFeedbackCue.holdCommit,
    ]);

    await drag.up();
    await tester.pumpAndSettle();
    expect(harness.cues, const [
      InteractionFeedbackCue.holdStart,
      InteractionFeedbackCue.holdWarning,
      InteractionFeedbackCue.holdCommit,
      InteractionFeedbackCue.none,
    ]);
    expect(find.byKey(const Key('room-action-media')), findsOneWidget);
  });

  testWidgets('direct swipe leap skips warning exactly like donor', (
    tester,
  ) async {
    final harness = _RoomGestureHarness();
    addTearDown(harness.dispose);
    await tester.pumpWidget(harness.app());
    await tester.pump();

    final width = tester.getSize(harness.tile).width;
    final threshold = SummarySwipeCommitPolicy.compactThreshold(width);
    final drag = await tester.startGesture(harness.tileCenter(tester));
    await drag.moveBy(Offset(threshold * 1.01, 0));
    await tester.pump();

    expect(harness.cues, const [
      InteractionFeedbackCue.holdStart,
      InteractionFeedbackCue.holdCommit,
    ]);

    await drag.up();
    await tester.pumpAndSettle();
    expect(harness.cues, const [
      InteractionFeedbackCue.holdStart,
      InteractionFeedbackCue.holdCommit,
      InteractionFeedbackCue.none,
    ]);
    expect(find.byKey(const Key('room-action-media')), findsOneWidget);
  });

  testWidgets('wide three-column tile keeps its full rectangular hit target', (
    tester,
  ) async {
    final harness = _RoomGestureHarness(
      tileSize: const Size(99.2, 72.4),
      contentScale: 72.4 / 98,
    );
    addTearDown(harness.dispose);
    await tester.pumpWidget(harness.app());
    await tester.pump();
    final point = tester.getBottomRight(harness.tile) - const Offset(1, 1);
    final hold = await tester.startGesture(point);
    await tester.pump(const Duration(milliseconds: 460));
    await hold.up();
    expect(harness.advances, 1);
  });
}

final class _RoomGestureHarness {
  _RoomGestureHarness({
    this.tileSize = const Size(96, 98),
    this.contentScale = 1,
  });
  final Size tileSize;
  final double contentScale;
  final bridge = RecordingFeedbackBridge();
  final scrollController = ScrollController();
  late final feedbackController = MargaritavilleFeedbackController(
    runtime: InteractionFeedbackRuntime(bridge: bridge),
  );
  var advances = 0;
  Finder get tile => find.byKey(const Key('summary-room-101'));
  List<InteractionFeedbackCue> get cues =>
      bridge.requests.map((request) => request.cue).toList();
  Offset tileCenter(WidgetTester tester) => tester.getCenter(tile);

  Widget app() {
    final room = RoomState.pending(
      roomNumber: '101',
      selectedAt: DateTime(2027, 2, 10, 20, 47),
    );
    return ProviderScope(
      overrides: [
        interactionSoundSettingsRepositoryProvider.overrideWithValue(
          MemorySoundRepository(),
        ),
      ],
      child: MargaritavilleFeedbackScope(
        controller: feedbackController,
        child: MaterialApp(
          theme: MargaritavilleTheme.dark,
          home: Scaffold(
            body: SizedBox(
              height: 320,
              child: SingleChildScrollView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Center(
                      child: SizedBox(
                        width: tileSize.width,
                        height: tileSize.height,
                        child: RoomStatusTile(
                          room: room,
                          onAdvance: () => advances++,
                          onReset: () {},
                          onToggleVip: () {},
                          onSchedule: () {},
                          onOpenMedia: () {},
                          contentScale: contentScale,
                        ),
                      ),
                    ),
                    const SizedBox(height: 800),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void dispose() {
    feedbackController.dispose();
    scrollController.dispose();
  }
}
