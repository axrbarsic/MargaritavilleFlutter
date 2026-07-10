import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/shared/visual_runtime/visual_frame_clock.dart';

void main() {
  test('one visual clock enforces its shared frame budget', () {
    final startedAt = DateTime.utc(2027, 2, 10, 12);
    final clock = VisualFrameClock(
      policy: const VisualFramePolicy(maxFramesPerSecond: 30),
      startedAt: startedAt,
    );
    addTearDown(clock.dispose);
    var frames = 0;
    clock.addListener(() => frames++);

    expect(
      clock.publish(startedAt.add(const Duration(milliseconds: 10))),
      isFalse,
    );
    expect(
      clock.publish(startedAt.add(const Duration(milliseconds: 34))),
      isTrue,
    );
    expect(
      clock.publish(startedAt.add(const Duration(milliseconds: 50))),
      isFalse,
    );
    expect(
      clock.publish(startedAt.add(const Duration(milliseconds: 68))),
      isTrue,
    );
    expect(frames, 2);
    expect(clock.now, startedAt.add(const Duration(milliseconds: 68)));
  });
}
