import 'package:flutter_test/flutter_test.dart';
import 'package:interaction_foundation/interaction_foundation.dart';

void main() {
  test('stable event id is emitted at most once', () async {
    final bridge = _RecordingBridge();
    final runtime = InteractionFeedbackRuntime(bridge: bridge);
    addTearDown(runtime.dispose);

    runtime.emit(
      eventId: 'settings:open:1',
      cue: InteractionFeedbackCue.confirm,
    );
    runtime.emit(
      eventId: 'settings:open:1',
      cue: InteractionFeedbackCue.confirm,
    );
    runtime.emit(
      eventId: 'settings:open:2',
      cue: InteractionFeedbackCue.confirm,
    );
    await Future<void>.delayed(Duration.zero);

    expect(bridge.requests.map((request) => request.requestId), [
      'settings:open:1',
      'settings:open:2',
    ]);
  });

  test('unkeyed rapid actions remain independent', () async {
    final bridge = _RecordingBridge();
    final runtime = InteractionFeedbackRuntime(bridge: bridge);
    addTearDown(runtime.dispose);

    runtime.emit(cue: InteractionFeedbackCue.select);
    runtime.emit(cue: InteractionFeedbackCue.select);
    await Future<void>.delayed(Duration.zero);

    expect(bridge.requests, hasLength(2));
    expect(bridge.requests[0].requestId, isNot(bridge.requests[1].requestId));
  });
}

final class _RecordingBridge implements InteractionFeedbackBridge {
  final requests = <InteractionFeedbackRequest>[];

  @override
  Future<void> clearPending() async {}

  @override
  Future<void> configure(
    InteractionFeedbackConfiguration configuration,
  ) async {}

  @override
  Future<void> emit(InteractionFeedbackRequest request) async {
    requests.add(request);
  }

  @override
  Future<void> previewSound(String soundId) async {}

  @override
  Future<void> setAudioContext(InteractionAudioContext context) async {}
}
