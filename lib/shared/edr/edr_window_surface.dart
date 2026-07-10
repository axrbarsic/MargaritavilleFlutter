import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'edr_overlay_controller.dart';

/// Lifecycle and geometry anchor for the window-level native visual runtime.
///
/// This widget paints no platform view. The Swift overlay lives outside the
/// Flutter PlatformView compositor and receives one batched viewport snapshot.
final class EdrWindowSurface extends StatefulWidget {
  const EdrWindowSurface({required this.controller, super.key});

  final EdrOverlayController controller;

  static bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  @override
  State<EdrWindowSurface> createState() => _EdrWindowSurfaceState();
}

final class _EdrWindowSurfaceState extends State<EdrWindowSurface> {
  bool? _lastRouteVisible;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && EdrWindowSurface.supported) {
        widget.controller.attachWindow();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeVisible =
        TickerMode.valuesOf(context).enabled &&
        (ModalRoute.of(context)?.isCurrent ?? true);
    if (_lastRouteVisible == routeVisible) return;
    _lastRouteVisible = routeVisible;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.controller.setWindowVisible(routeVisible);
    });
  }

  @override
  void dispose() {
    widget.controller.detachWindow();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(key: widget.controller.surfaceKey);
  }
}
