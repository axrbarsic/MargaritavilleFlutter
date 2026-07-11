import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interaction_foundation/interaction_foundation.dart';
import 'package:interaction_foundation/src/generated/voice_capture_api.g.dart';
import 'package:interaction_foundation/src/voice_capture_event_router.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('router isolates operations and rejects stale sequences', () {
    final router = VoiceCaptureEventRouter.forTesting();
    final first = <int>[];
    final second = <int>[];
    final other = <int>[];
    final all = <String>[];
    final firstSubscription = router.subscribe(
      'operation-a',
      (event) => first.add(event.sequence),
    );
    router.subscribe('operation-a', (event) => second.add(event.sequence));
    router.subscribe('operation-b', (event) => other.add(event.sequence));
    router.subscribeAll(
      (event) => all.add('${event.operationId}:${event.sequence}'),
    );

    router.route(_event('operation-a', 2));
    router.route(_event('operation-a', 1));
    router.route(_event('operation-b', 7));
    firstSubscription.cancel();
    router.route(_event('operation-a', 3));

    expect(first, [2]);
    expect(second, [2, 3]);
    expect(other, [7]);
    expect(all, ['operation-a:2', 'operation-b:7', 'operation-a:3']);
    expect(firstSubscription.isCancelled, isTrue);
  });

  test('terminal event closes an operation and replays exactly once', () async {
    final router = VoiceCaptureEventRouter.forTesting();
    final initial = <int>[];
    final replayed = <int>[];
    router.subscribe('operation-terminal', (event) {
      initial.add(event.sequence);
    });

    router.route(_event('operation-terminal', 4, terminal: true));
    router.route(_event('operation-terminal', 5));
    router.subscribe('operation-terminal', (event) {
      replayed.add(event.sequence);
    });
    await Future<void>.delayed(Duration.zero);

    expect(initial, [4]);
    expect(replayed, [4]);
  });

  test('cancelled subscription does not receive deferred replay', () async {
    final router = VoiceCaptureEventRouter.forTesting();
    router.route(_event('operation-replay', 9));
    final received = <int>[];
    final subscription = router.subscribe('operation-replay', (event) {
      received.add(event.sequence);
    });

    subscription.cancel();
    subscription.cancel();
    await Future<void>.delayed(Duration.zero);

    expect(received, isEmpty);
  });

  test('Pigeon callback preserves Unicode and 64-bit result fields', () async {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    final router = VoiceCaptureEventRouter.forTesting();
    final received = <VoiceCaptureEvent>[];
    router.ensureInstalled(binaryMessenger: messenger);
    router.subscribe('operation-unicode', received.add);
    addTearDown(() {
      VoiceCaptureFlutterApi.setUp(null, binaryMessenger: messenger);
    });
    final dto = VoiceCaptureEventDto(
      contractVersion: VoiceCaptureContract.version,
      operationId: 'operation-unicode',
      sequence: 9223372036854770000,
      phase: VoiceCapturePhaseDto.completed,
      statusCode: VoiceCaptureStatusCodeDto.completed,
      result: VoiceCaptureResultDto(
        contractVersion: VoiceCaptureContract.version,
        operationId: 'operation-unicode',
        resultId: 'result-1',
        temporaryFilePath: 'Voice/результат.m4a',
        originDeviceId: 'device-1',
        createdAtMicros: 9007199254740993,
        durationMs: 12034,
        byteLength: 9223372036854770000,
        mimeType: 'audio/mp4',
        codec: 'aac',
        sampleRateHz: 44100,
        channelCount: 1,
        recognizedText: 'Комната готова — полотенца принесены.',
      ),
    );
    final channel = BasicMessageChannel<Object?>(
      'dev.flutter.pigeon.interaction_foundation.'
      'VoiceCaptureFlutterApi.onCaptureEvent',
      VoiceCaptureFlutterApi.pigeonChannelCodec,
      binaryMessenger: messenger,
    );

    await messenger.handlePlatformMessage(
      channel.name,
      VoiceCaptureFlutterApi.pigeonChannelCodec.encodeMessage(<Object?>[dto]),
      null,
    );

    final result = received.single.result!;
    expect(received.single.sequence, 9223372036854770000);
    expect(result.createdAtMicros, 9007199254740993);
    expect(result.byteLength, 9223372036854770000);
    expect(result.temporaryFilePath, 'Voice/результат.m4a');
    expect(result.recognizedText, 'Комната готова — полотенца принесены.');
    expect(result.sampleRateHz, 44100);
    expect(result.channelCount, 1);
  });
}

VoiceCaptureEvent _event(
  String operationId,
  int sequence, {
  bool terminal = false,
}) => VoiceCaptureEvent(
  contractVersion: VoiceCaptureContract.version,
  operationId: operationId,
  sequence: sequence,
  phase: terminal ? VoiceCapturePhase.completed : VoiceCapturePhase.recording,
  statusCode: terminal
      ? VoiceCaptureStatusCode.completed
      : VoiceCaptureStatusCode.recording,
);
