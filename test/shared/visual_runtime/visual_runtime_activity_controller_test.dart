import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/shared/visual_runtime/visual_runtime_activity.dart';

void main() {
  test('shared runtime starts on first lease and idles after the last', () {
    var changes = 0;
    final controller = VisualRuntimeActivityController(
      onActivityChanged: () => changes++,
    );
    final first = Object();
    final second = Object();

    controller.setActive(first, active: true);
    controller.setActive(first, active: true);
    controller.setActive(second, active: true);

    expect(controller.activeClientCount, 2);
    expect(controller.hasActiveClients, isTrue);
    expect(changes, 2);

    controller.remove(first);
    controller.remove(second);

    expect(controller.activeClientCount, 0);
    expect(controller.hasActiveClients, isFalse);
    expect(changes, 4);
  });
}
