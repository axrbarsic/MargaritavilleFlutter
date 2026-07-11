import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interaction_foundation/interaction_foundation.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/room_state.dart';

import 'summary_header_interaction_test_support.dart';

void main() {
  testWidgets('puzzle emits donor thresholds and resets after 160ms', (
    tester,
  ) async {
    final harness = SummaryHeaderFeedbackHarness();
    addTearDown(harness.dispose);
    var completions = 0;
    await tester.pumpWidget(harness.app(onOpenSelection: () => completions++));
    await tester.pump();

    const travel = 337.0;
    final puzzle = find.byKey(const Key('unlock-workday'));
    final drag = await tester.startGesture(tester.getCenter(puzzle));
    await drag.moveBy(const Offset(-3, 0));
    await tester.pump();
    expect(interactionCues(harness), const [InteractionFeedbackCue.holdStart]);

    await drag.moveBy(const Offset(-(travel * 0.5 - 3), 0));
    await tester.pump();
    final halfOpacity = tester.widget<Opacity>(
      find.byKey(const Key('summary-settings-opacity')),
    );
    expect(halfOpacity.opacity, closeTo(0.175, 0.001));

    await drag.moveBy(const Offset(-(travel * 0.33), 0));
    await tester.pump();
    expect(interactionCues(harness), const [
      InteractionFeedbackCue.holdStart,
      InteractionFeedbackCue.holdWarning,
    ]);

    await drag.moveBy(const Offset(-(travel * 0.18), 0));
    await tester.pump();
    expect(interactionCues(harness), const [
      InteractionFeedbackCue.holdStart,
      InteractionFeedbackCue.holdWarning,
      InteractionFeedbackCue.holdCommit,
    ]);

    await drag.up();
    await tester.pump();
    expect(completions, 1);
    expect(interactionCues(harness), const [
      InteractionFeedbackCue.holdStart,
      InteractionFeedbackCue.holdWarning,
      InteractionFeedbackCue.holdCommit,
      InteractionFeedbackCue.confirm,
      InteractionFeedbackCue.confirm,
      InteractionFeedbackCue.none,
    ]);
    expect(harness.bridge.requests.last.soundPriority, 70);
    expect(settingsOpacity(tester), 0);
    await tester.pump(const Duration(milliseconds: 159));
    expect(settingsOpacity(tester), 0);
    await tester.pump(const Duration(milliseconds: 1));
    expect(settingsOpacity(tester), 1);
  });

  testWidgets('status filter emits one tap cue before changing', (
    tester,
  ) async {
    final harness = SummaryHeaderFeedbackHarness();
    addTearDown(harness.dispose);
    RoomDisplayStatus? selected;
    await tester.pumpWidget(
      harness.app(onFilterChanged: (value) => selected = value),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('summary-filter-open')));
    await tester.pump();

    expect(selected, RoomDisplayStatus.open);
    expect(interactionCues(harness), const [InteractionFeedbackCue.tap]);
  });
}
