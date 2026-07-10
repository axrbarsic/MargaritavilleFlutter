import 'package:flutter/material.dart';

import 'visual_frame_clock.dart';
import 'visual_runtime_activity_controller.dart';

final class VisualRuntimeScope extends StatefulWidget {
  const VisualRuntimeScope({
    required this.policy,
    required this.enabled,
    required this.child,
    super.key,
  });

  final VisualFramePolicy policy;
  final bool enabled;
  final Widget child;

  static VisualFrameClock? maybeClockOf(BuildContext context) {
    return context
        .getInheritedWidgetOfExactType<_VisualFrameClockScope>()
        ?.clock;
  }

  static VisualRuntimeActivityController? maybeActivityControllerOf(
    BuildContext context,
  ) {
    return context
        .getInheritedWidgetOfExactType<_VisualFrameClockScope>()
        ?.activityController;
  }

  @override
  State<VisualRuntimeScope> createState() => _VisualRuntimeScopeState();
}

final class _VisualRuntimeScopeState extends State<VisualRuntimeScope>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller;
  late final VisualFrameClock _clock;
  late final VisualRuntimeActivityController _activityController;
  var _animationsDisabled = false;
  var _tickerModeEnabled = true;
  var _isForeground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isForeground =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    _clock = VisualFrameClock(policy: widget.policy);
    _activityController = VisualRuntimeActivityController(
      onActivityChanged: _syncTicker,
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(hours: 1),
    )..addListener(_publishFrame);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animationsDisabled =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    _tickerModeEnabled = TickerMode.valuesOf(context).enabled;
    _syncTicker();
  }

  @override
  void didUpdateWidget(covariant VisualRuntimeScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    _clock.updatePolicy(widget.policy);
    _syncTicker();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isForeground = state == AppLifecycleState.resumed;
    _syncTicker();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller
      ..removeListener(_publishFrame)
      ..dispose();
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _VisualFrameClockScope(
      clock: _clock,
      activityController: _activityController,
      child: widget.child,
    );
  }

  void _publishFrame() {
    _clock.publish(DateTime.now());
  }

  void _syncTicker() {
    final shouldRun =
        widget.enabled &&
        widget.policy.enabled &&
        _activityController.hasActiveClients &&
        !_animationsDisabled &&
        _tickerModeEnabled &&
        _isForeground;
    if (shouldRun && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!shouldRun && _controller.isAnimating) {
      _controller.stop();
    }
  }
}

final class _VisualFrameClockScope extends InheritedWidget {
  const _VisualFrameClockScope({
    required this.clock,
    required this.activityController,
    required super.child,
  });

  final VisualFrameClock clock;
  final VisualRuntimeActivityController activityController;

  @override
  bool updateShouldNotify(_VisualFrameClockScope oldWidget) {
    return oldWidget.clock != clock ||
        oldWidget.activityController != activityController;
  }
}
