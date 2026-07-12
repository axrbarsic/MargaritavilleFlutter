import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/summary/presentation/summary_swipe_commit_policy.dart';
import 'package:margaritaville_flutter/features/summary/presentation/widgets/room_gesture_arena_target.dart';

void main() {
  testWidgets('slow swipe emits warning only once inside one gesture', (
    tester,
  ) async {
    var starts = 0;
    var warnings = 0;
    var commits = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            key: const Key('target'),
            width: 100,
            height: 100,
            child: RoomGestureArenaTarget(
              onHoldCommit: () {},
              onSwipeStart: () => starts += 1,
              onSwipeWarning: () => warnings += 1,
              onSwipeCommit: () => commits += 1,
              onOpenActions: () {},
              child: const ColoredBox(color: Colors.green),
            ),
          ),
        ),
      ),
    );

    final target = find.byKey(const Key('target'));
    final origin = tester.getCenter(target);
    final threshold = SummarySwipeCommitPolicy.compactThreshold(
      tester.getSize(target).width,
    );
    final drag = await tester.startGesture(origin);
    await drag.moveTo(origin + Offset(threshold * 0.87, 0));
    await drag.moveTo(origin + Offset(threshold * 0.95, 0));
    await drag.moveTo(origin + Offset(threshold * 0.97, 0));
    await drag.moveTo(origin + Offset(threshold * 0.99, 0));
    await drag.moveTo(origin + Offset(threshold * 0.95, 30));
    await drag.moveTo(origin + Offset(threshold * 0.95, 0));
    await drag.moveTo(origin + Offset(threshold * 1.01, 0));
    await drag.moveTo(origin + Offset(threshold * 0.99, 0));
    await drag.moveTo(origin + Offset(threshold * 1.01, 0));
    await tester.pump();

    expect(starts, 1);
    expect(warnings, 1);
    expect(commits, 1);
    await drag.cancel();
  });
}
