import 'dart:async';

import 'package:flutter/foundation.dart';

import 'interaction_feedback_bridge.dart';
import 'interaction_feedback_contract.dart';

final class InteractionFeedbackRuntime {
  InteractionFeedbackRuntime({InteractionFeedbackBridge? bridge})
    : _bridge = bridge ?? PigeonInteractionFeedbackBridge();

  final InteractionFeedbackBridge _bridge;
  var _requestSequence = 0;
  var _disposed = false;

  Future<void> configure(InteractionFeedbackConfiguration configuration) {
    return _bestEffort(() => _bridge.configure(configuration));
  }

  void emit({
    required InteractionFeedbackCue cue,
    String? soundId,
    int soundPriority = 0,
  }) {
    if (_disposed) return;
    final request = InteractionFeedbackRequest(
      requestId:
          '${DateTime.now().microsecondsSinceEpoch}-${_requestSequence++}',
      cue: cue,
      soundId: soundId,
      soundPriority: soundPriority,
    );
    unawaited(_bestEffort(() => _bridge.emit(request)));
  }

  void previewSound(String soundId) {
    if (_disposed) return;
    unawaited(_bestEffort(() => _bridge.previewSound(soundId)));
  }

  void setAudioContext(InteractionAudioContext context) {
    if (_disposed) return;
    unawaited(_bestEffort(() => _bridge.setAudioContext(context)));
  }

  void clearPending() {
    if (_disposed) return;
    unawaited(_bestEffort(_bridge.clearPending));
  }

  void dispose() {
    if (_disposed) return;
    clearPending();
    _disposed = true;
  }

  Future<void> _bestEffort(Future<void> Function() operation) async {
    try {
      await operation();
    } catch (error) {
      debugPrint('Interaction feedback runtime unavailable: $error');
    }
  }
}
