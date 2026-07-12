import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interaction_foundation/interaction_foundation.dart';

import '../application/margaritaville_feedback_controller.dart';
import '../application/margaritaville_interaction_dispatcher.dart';
import '../domain/margaritaville_sound_routing.dart';
import 'controllers/interaction_sound_settings_controller.dart';

final class MargaritavilleFeedbackScope extends ConsumerStatefulWidget {
  const MargaritavilleFeedbackScope({
    required this.child,
    this.controller,
    super.key,
  });

  final Widget child;
  final MargaritavilleFeedbackController? controller;

  static MargaritavilleInteractionDispatcher dispatcherOf(
    BuildContext context,
  ) {
    final dispatcher = context
        .dependOnInheritedWidgetOfExactType<_FeedbackControllerScope>()
        ?.dispatcher;
    assert(dispatcher != null, 'MargaritavilleFeedbackScope is missing.');
    return dispatcher!;
  }

  @override
  ConsumerState<MargaritavilleFeedbackScope> createState() =>
      _MargaritavilleFeedbackScopeState();
}

final class _MargaritavilleFeedbackScopeState
    extends ConsumerState<MargaritavilleFeedbackScope>
    with WidgetsBindingObserver {
  late final MargaritavilleFeedbackController _controller;
  late final MargaritavilleInteractionDispatcher _dispatcher;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? MargaritavilleFeedbackController();
    _dispatcher = MargaritavilleInteractionDispatcher(_controller);
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
    final assignments = ref
        .watch(interactionSoundSettingsControllerProvider)
        .value;
    _controller.updateSoundAssignments(
      assignments ?? MargaritavilleSoundAssignments.defaults,
    );
    return _FeedbackControllerScope(
      controller: _controller,
      dispatcher: _dispatcher,
      child: widget.child,
    );
  }
}

final class _FeedbackControllerScope extends InheritedWidget {
  const _FeedbackControllerScope({
    required this.controller,
    required this.dispatcher,
    required super.child,
  });

  final MargaritavilleFeedbackController controller;
  final MargaritavilleInteractionDispatcher dispatcher;

  @override
  bool updateShouldNotify(_FeedbackControllerScope oldWidget) {
    return oldWidget.controller != controller;
  }
}
