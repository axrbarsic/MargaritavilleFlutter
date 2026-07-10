import 'package:flutter/widgets.dart';

import 'edr_overlay_controller.dart';

final class EdrViewportScope extends InheritedWidget {
  const EdrViewportScope({
    required this.controller,
    required super.child,
    super.key,
  });

  final EdrOverlayController controller;

  static EdrOverlayController? maybeControllerOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<EdrViewportScope>()
        ?.controller;
  }

  @override
  bool updateShouldNotify(EdrViewportScope oldWidget) =>
      !identical(controller, oldWidget.controller);
}
