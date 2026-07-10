import 'package:flutter/widgets.dart';

import 'edr_overlay_controller.dart';

final class EdrViewportScope extends InheritedNotifier<EdrOverlayController> {
  const EdrViewportScope({
    required EdrOverlayController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static EdrOverlayController? maybeControllerOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<EdrViewportScope>()
        ?.notifier;
  }
}
