import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/summary/presentation/summary_swipe_commit_policy.dart';

void main() {
  test('compact room action threshold follows the donor clamp', () {
    expect(SummarySwipeCommitPolicy.compactThreshold(60), 58);
    expect(
      SummarySwipeCommitPolicy.compactThreshold(96),
      closeTo(69.12, 0.001),
    );
    expect(SummarySwipeCommitPolicy.compactThreshold(200), 84);
  });

  test('compact swipe can commit by distance or predicted finish', () {
    expect(
      SummarySwipeCommitPolicy.compactArmed(
        translation: 70,
        velocity: 0,
        cellWidth: 96,
      ),
      isTrue,
    );
    expect(
      SummarySwipeCommitPolicy.compactArmed(
        translation: 55,
        velocity: 0,
        cellWidth: 96,
      ),
      isFalse,
    );
    expect(
      SummarySwipeCommitPolicy.compactArmed(
        translation: 55,
        velocity: 300,
        cellWidth: 96,
      ),
      isTrue,
    );
  });
}
