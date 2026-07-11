import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interaction_foundation/interaction_foundation.dart';
import 'package:interaction_foundation/src/generated/voice_capture_api.g.dart';
import 'package:interaction_foundation/src/voice_capture_event_router.dart';
import 'package:interaction_foundation/src/voice_capture_transport.dart';

void main() {
  test('bridge maps capabilities and hides mutable transport DTOs', () async {
    final transport = _FakeTransport();
    final bridge = PigeonVoiceCaptureBridge.forTesting(
      transport: transport,
      router: VoiceCaptureEventRouter.forTesting(),
    );

    final capabilities = await bridge.getCapabilities();

    expect(transport.lastLocale, 'ru-RU');
    expect(capabilities.supported, isTrue);
    expect(capabilities.speechPermission, VoicePermissionState.granted);
    expect(capabilities.microphonePermission, VoicePermissionState.granted);
    expect(capabilities.recognizerAvailable, isTrue);
  });

  test('start mapping preserves typed operation contract', () async {
    final transport = _FakeTransport();
    final bridge = PigeonVoiceCaptureBridge.forTesting(
      transport: transport,
      router: VoiceCaptureEventRouter.forTesting(),
    );
    const request = VoiceCaptureStartRequest(
      operationId: 'operation-42',
      mediaId: 'media-42',
      localeIdentifier: 'ru-RU',
      addsPunctuation: true,
    );

    final acknowledgement = await bridge.startCapture(request);

    final sent = transport.lastStart!;
    expect(sent.contractVersion, VoiceCaptureContract.version);
    expect(sent.operationId, request.operationId);
    expect(sent.mediaId, request.mediaId);
    expect(sent.localeIdentifier, request.localeIdentifier);
    expect(sent.addsPunctuation, isTrue);
    expect(acknowledgement.operationId, request.operationId);
    expect(acknowledgement.accepted, isTrue);
    expect(
      acknowledgement.statusCode,
      VoiceCaptureStatusCode.startingMicrophone,
    );
  });

  test('missing native capabilities degrade to typed unavailable', () async {
    final transport = _FakeTransport()
      ..capabilitiesError = MissingPluginException('not installed');
    final bridge = PigeonVoiceCaptureBridge.forTesting(
      transport: transport,
      router: VoiceCaptureEventRouter.forTesting(),
    );

    final capabilities = await bridge.getCapabilities();

    expect(capabilities.supported, isFalse);
    expect(capabilities.microphonePermission, VoicePermissionState.unsupported);
    expect(capabilities.unavailableReason, contains('недоступна'));
  });

  test('native failures become typed public failures', () async {
    final transport = _FakeTransport()
      ..stopError = PlatformException(code: 'busy', message: 'Занято');
    final bridge = PigeonVoiceCaptureBridge.forTesting(
      transport: transport,
      router: VoiceCaptureEventRouter.forTesting(),
    );

    await expectLater(
      bridge.stopCapture('operation-busy'),
      throwsA(
        isA<VoiceCaptureFailure>()
            .having((value) => value.code, 'code', VoiceCaptureFailureCode.busy)
            .having(
              (value) => value.operationId,
              'operationId',
              'operation-busy',
            ),
      ),
    );
  });

  test('mismatched acknowledgement cannot cross operation ownership', () async {
    final transport = _FakeTransport()..ackOperationId = 'another-operation';
    final bridge = PigeonVoiceCaptureBridge.forTesting(
      transport: transport,
      router: VoiceCaptureEventRouter.forTesting(),
    );

    await expectLater(
      bridge.startCapture(
        const VoiceCaptureStartRequest(
          operationId: 'expected-operation',
          mediaId: 'media-1',
        ),
      ),
      throwsA(
        isA<VoiceCaptureFailure>().having(
          (value) => value.code,
          'code',
          VoiceCaptureFailureCode.invalidResponse,
        ),
      ),
    );
  });

  test('contract version mismatch is rejected before native start', () async {
    final transport = _FakeTransport();
    final bridge = PigeonVoiceCaptureBridge.forTesting(
      transport: transport,
      router: VoiceCaptureEventRouter.forTesting(),
    );

    await expectLater(
      bridge.startCapture(
        const VoiceCaptureStartRequest(
          contractVersion: 999,
          operationId: 'operation-newer',
          mediaId: 'media-newer',
        ),
      ),
      throwsA(
        isA<VoiceCaptureFailure>().having(
          (value) => value.code,
          'code',
          VoiceCaptureFailureCode.contractMismatch,
        ),
      ),
    );
    expect(transport.lastStart, isNull);
  });
}

final class _FakeTransport implements VoiceCaptureTransport {
  Object? capabilitiesError;
  Object? stopError;
  String? ackOperationId;
  String? lastLocale;
  VoiceCaptureStartRequestDto? lastStart;

  @override
  Future<VoiceCaptureCapabilitiesDto> getCapabilities(
    String localeIdentifier,
  ) async {
    lastLocale = localeIdentifier;
    if (capabilitiesError case final error?) throw error;
    return VoiceCaptureCapabilitiesDto(
      contractVersion: VoiceCaptureContract.version,
      supported: true,
      speechPermission: VoicePermissionStateDto.granted,
      microphonePermission: VoicePermissionStateDto.granted,
      recognizerAvailable: true,
    );
  }

  @override
  Future<VoiceCaptureAckDto> startCapture(
    VoiceCaptureStartRequestDto request,
  ) async {
    lastStart = request;
    return _ack(
      ackOperationId ?? request.operationId,
      VoiceCaptureStatusCodeDto.startingMicrophone,
    );
  }

  @override
  Future<VoiceCaptureAckDto> stopCapture(String operationId) async {
    if (stopError case final error?) throw error;
    return _ack(operationId, VoiceCaptureStatusCodeDto.finishingTranscription);
  }

  @override
  Future<VoiceCaptureAckDto> cancelCapture(String operationId) async =>
      _ack(operationId, VoiceCaptureStatusCodeDto.cancelled);

  @override
  Future<void> releaseResult(String resultId) async {}

  VoiceCaptureAckDto _ack(
    String operationId,
    VoiceCaptureStatusCodeDto status,
  ) => VoiceCaptureAckDto(
    contractVersion: VoiceCaptureContract.version,
    operationId: operationId,
    accepted: true,
    statusCode: status,
  );
}
