import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/shared/visual_runtime/visual_frame_clock.dart';

void main() {
  test('one visual clock publishes every OS vsync without an app FPS cap', () {
    final startedAt = DateTime.utc(2027, 2, 10, 12);
    final clock = VisualFrameClock(
      policy: const VisualFramePolicy(),
      startedAt: startedAt,
    );
    addTearDown(clock.dispose);
    var frames = 0;
    clock.addListener(() => frames++);

    expect(
      clock.publish(startedAt.add(const Duration(microseconds: 8333))),
      isTrue,
    );
    expect(
      clock.publish(startedAt.add(const Duration(microseconds: 16666))),
      isTrue,
    );
    expect(
      clock.publish(startedAt.add(const Duration(microseconds: 16666))),
      isFalse,
    );
    expect(
      clock.publish(startedAt.add(const Duration(microseconds: 1000))),
      isFalse,
    );
    expect(frames, 2);
    expect(clock.now, startedAt.add(const Duration(microseconds: 16666)));
  });
}
