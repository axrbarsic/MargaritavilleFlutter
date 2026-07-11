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
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  @override
  State<EdrWindowSurface> createState() => _EdrWindowSurfaceState();
}

final class _EdrWindowSurfaceState extends State<EdrWindowSurface>
    with WidgetsBindingObserver {
  ModalRoute<dynamic>? _route;
  Animation<double>? _primaryAnimation;
  Animation<double>? _secondaryAnimation;
  var _stabilityGeneration = 0;
  var _attached = false;
  var _presented = false;
  var _tickerEnabled = true;
  var _appVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.controller.setWindowVisible(false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && EdrWindowSurface.supported) {
        _attached = true;
        widget.controller.attachWindow();
        _evaluatePresentation();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tickerEnabled = TickerMode.valuesOf(context).enabled;
    final nextRoute = ModalRoute.of(context);
    if (!identical(_route, nextRoute)) {
      _removeRouteListeners();
      _route = nextRoute;
      _primaryAnimation = nextRoute?.animation;
      _secondaryAnimation = nextRoute?.secondaryAnimation;
      _primaryAnimation?.addStatusListener(_routeAnimationChanged);
      _secondaryAnimation?.addStatusListener(_routeAnimationChanged);
    }
    _evaluatePresentation();
  }

  @override
  void didUpdateWidget(covariant EdrWindowSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (identical(oldWidget.controller, widget.controller)) return;
    oldWidget.controller.detachWindow();
    widget.controller.setWindowVisible(false);
    if (_attached) widget.controller.attachWindow();
    _presented = false;
    _evaluatePresentation();
  }

  @override
  void dispose() {
    _stabilityGeneration += 1;
    WidgetsBinding.instance.removeObserver(this);
    _removeRouteListeners();
    widget.controller.detachWindow();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appVisible = state == AppLifecycleState.resumed;
    _evaluatePresentation();
  }

  void _routeAnimationChanged(AnimationStatus _) {
    _evaluatePresentation();
  }

  void _removeRouteListeners() {
    _primaryAnimation?.removeStatusListener(_routeAnimationChanged);
    _secondaryAnimation?.removeStatusListener(_routeAnimationChanged);
  }

  void _evaluatePresentation() {
    if (!mounted) return;
    final route = _route;
    final eligible =
        _appVisible &&
        _tickerEnabled &&
        (route?.isCurrent ?? true) &&
        (_primaryAnimation?.status ?? AnimationStatus.completed) ==
            AnimationStatus.completed &&
        (_secondaryAnimation?.status ?? AnimationStatus.dismissed) ==
            AnimationStatus.dismissed;
    if (!eligible) {
      _stabilityGeneration += 1;
      if (_presented) {
        _presented = false;
        widget.controller.setWindowVisible(false);
      }
      return;
    }
    if (!_attached || _presented) return;
    final generation = ++_stabilityGeneration;
    _checkStableGeometry(generation, previous: null, stableFrames: 0);
  }

  void _checkStableGeometry(
    int generation, {
    required Rect? previous,
    required int stableFrames,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || generation != _stabilityGeneration || !_attached) return;
      final surface = widget.controller.surfaceKey.currentContext
          ?.findRenderObject();
      if (surface is! RenderBox || !surface.hasSize) {
        _scheduleNextStabilityFrame(generation, null, 0);
        return;
      }
      final current = surface.localToGlobal(Offset.zero) & surface.size;
      final nextStableFrames = current == previous ? stableFrames + 1 : 1;
      if (nextStableFrames >= 2) {
        _presented = true;
        widget.controller.setWindowVisible(true);
        return;
      }
      _scheduleNextStabilityFrame(generation, current, nextStableFrames);
    });
  }

  void _scheduleNextStabilityFrame(
    int generation,
    Rect? previous,
    int stableFrames,
  ) {
    WidgetsBinding.instance.scheduleFrame();
    _checkStableGeometry(
      generation,
      previous: previous,
      stableFrames: stableFrames,
    );
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (_) {
        widget.controller.requestGeometrySync();
        return false;
      },
      child: SizeChangedLayoutNotifier(
        child: SizedBox.expand(key: widget.controller.surfaceKey),
      ),
    );
  }
}
