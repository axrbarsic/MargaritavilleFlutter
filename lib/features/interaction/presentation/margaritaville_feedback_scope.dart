import 'dart:async';

import 'package:flutter/material.dart';
import 'package:interaction_foundation/interaction_foundation.dart';

import '../application/margaritaville_feedback_controller.dart';

final class MargaritavilleFeedbackScope extends StatefulWidget {
  const MargaritavilleFeedbackScope({
    required this.child,
    this.controller,
    super.key,
  });

  final Widget child;
  final MargaritavilleFeedbackController? controller;

  static MargaritavilleFeedbackController? maybeControllerOf(
    BuildContext context,
  ) {
    return context
        .dependOnInheritedWidgetOfExactType<_FeedbackControllerScope>()
        ?.controller;
  }

  @override
  State<MargaritavilleFeedbackScope> createState() =>
      _MargaritavilleFeedbackScopeState();
}

final class _MargaritavilleFeedbackScopeState
    extends State<MargaritavilleFeedbackScope>
    with WidgetsBindingObserver {
  late final MargaritavilleFeedbackController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? MargaritavilleFeedbackController();
    unawaited(_controller.initialize());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _controller.setAudioContext(
      state == AppLifecycleState.resumed
          ? InteractionAudioContext.interactive
          : InteractionAudioContext.background,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FeedbackControllerScope(
      controller: _controller,
      child: widget.child,
    );
  }
}

final class _FeedbackControllerScope extends InheritedWidget {
  const _FeedbackControllerScope({
    required this.controller,
    required super.child,
  });

  final MargaritavilleFeedbackController controller;

  @override
  bool updateShouldNotify(_FeedbackControllerScope oldWidget) {
    return oldWidget.controller != controller;
  }
}
