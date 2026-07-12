import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'interaction_feedback_bridge.dart';
import 'interaction_feedback_contract.dart';

final class InteractionFeedbackRuntime {
  InteractionFeedbackRuntime({InteractionFeedbackBridge? bridge})
    : _bridge = bridge ?? PigeonInteractionFeedbackBridge();

  final InteractionFeedbackBridge _bridge;
  final _recentEventIds = <String>{};
  final _recentEventOrder = ListQueue<String>();
  var _requestSequence = 0;
  var _disposed = false;

  static const _eventIdCapacity = 256;

  Future<void> configure(InteractionFeedbackConfiguration configuration) {
    return _bestEffort(() => _bridge.configure(configuration));
  }

  void emit({
    required InteractionFeedbackCue cue,
    String? eventId,
    String? soundId,
    int soundPriority = 0,
  }) {
    if (_disposed) return;
    final requestId = eventId ?? _nextRequestId();
    if (!_remember(requestId)) return;
    final request = InteractionFeedbackRequest(
      requestId: requestId,
      cue: cue,
      soundId: soundId,
      soundPriority: soundPriority,
    );
    unawaited(_bestEffort(() => _bridge.emit(request)));
  }

  String _nextRequestId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${_requestSequence++}';

  bool _remember(String eventId) {
    if (!_recentEventIds.add(eventId)) return false;
    _recentEventOrder.addLast(eventId);
    if (_recentEventOrder.length > _eventIdCapacity) {
      _recentEventIds.remove(_recentEventOrder.removeFirst());
    }
    return true;
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
