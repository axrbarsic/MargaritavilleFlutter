import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:interaction_foundation/interaction_foundation.dart';
import 'package:margaritaville_flutter/features/interaction/application/margaritaville_feedback_controller.dart';
import 'package:margaritaville_flutter/features/interaction/application/margaritaville_interaction_dispatcher.dart';
import 'package:margaritaville_flutter/features/interaction/domain/margaritaville_interaction_intent.dart';

void main() {
  test('accepted action emits before durable work starts', () async {
    final order = <String>[];
    final bridge = _OrderedBridge(order);
    final controller = MargaritavilleFeedbackController(
      runtime: InteractionFeedbackRuntime(bridge: bridge),
    );
    final dispatcher = MargaritavilleInteractionDispatcher(controller);
    addTearDown(controller.dispose);

    await dispatcher.acceptAsync(
      MargaritavilleInteractionIntent.confirm,
      () async {
        order.add('operation-start');
        await Future<void>.delayed(Duration.zero);
        order.add('operation-end');
      },
    );

    expect(order, ['feedback', 'operation-start', 'operation-end']);
  });

  test('in-flight action admits one rapid tap and one cue', () async {
    final order = <String>[];
    final bridge = _OrderedBridge(order);
    final controller = MargaritavilleFeedbackController(
      runtime: InteractionFeedbackRuntime(bridge: bridge),
    );
    final dispatcher = MargaritavilleInteractionDispatcher(controller);
    final gate = Completer<void>();
    var operations = 0;
    addTearDown(controller.dispose);

    Future<void> operation() async {
      operations += 1;
      await gate.future;
    }

    final first = dispatcher.acceptAsyncOnce(
      'photo-camera-capture',
      MargaritavilleInteractionIntent.confirm,
      operation,
    );
    final second = dispatcher.acceptAsyncOnce(
      'photo-camera-capture',
      MargaritavilleInteractionIntent.confirm,
      operation,
    );
    await Future<void>.delayed(Duration.zero);

    expect(operations, 1);
    expect(order, ['feedback']);
    await second;
    gate.complete();
    await first;
  });
}

final class _OrderedBridge implements InteractionFeedbackBridge {
  _OrderedBridge(this.order);

  final List<String> order;

  @override
  Future<void> clearPending() async {}

  @override
  Future<void> configure(
    InteractionFeedbackConfiguration configuration,
  ) async {}

  @override
  Future<void> emit(InteractionFeedbackRequest request) async {
    order.add('feedback');
  }

  @override
  Future<void> previewSound(String soundId) async {}

  @override
  Future<void> setAudioContext(InteractionAudioContext context) async {}
}
