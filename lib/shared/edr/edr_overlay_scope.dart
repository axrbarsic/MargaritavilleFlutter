import 'package:flutter/widgets.dart';

import 'edr_overlay_controller.dart';

final class EdrOverlayScope extends InheritedNotifier<EdrOverlayController> {
  const EdrOverlayScope({
    required EdrOverlayController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static EdrOverlayController? maybeControllerOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<EdrOverlayScope>()
        ?.notifier;
  }
}
