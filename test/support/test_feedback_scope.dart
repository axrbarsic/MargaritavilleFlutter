import 'package:flutter/widgets.dart';
import 'package:interaction_foundation/interaction_foundation.dart';
import 'package:margaritaville_flutter/features/interaction/application/margaritaville_feedback_controller.dart';
import 'package:margaritaville_flutter/features/interaction/presentation/margaritaville_feedback_scope.dart';

final class TestFeedbackScope extends StatefulWidget {
  const TestFeedbackScope({required this.child, super.key});

  final Widget child;

  @override
  State<TestFeedbackScope> createState() => _TestFeedbackScopeState();
}

final class _TestFeedbackScopeState extends State<TestFeedbackScope> {
  late final _controller = MargaritavilleFeedbackController(
    runtime: InteractionFeedbackRuntime(bridge: const _NoopFeedbackBridge()),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MargaritavilleFeedbackScope(
      controller: _controller,
      child: widget.child,
    );
  }
}

final class _NoopFeedbackBridge implements InteractionFeedbackBridge {
  const _NoopFeedbackBridge();

  @override
  Future<void> clearPending() async {}

  @override
  Future<void> configure(
    InteractionFeedbackConfiguration configuration,
  ) async {}

  @override
  Future<void> emit(InteractionFeedbackRequest request) async {}

  @override
  Future<void> previewSound(String soundId) async {}

  @override
  Future<void> setAudioContext(InteractionAudioContext context) async {}
}
