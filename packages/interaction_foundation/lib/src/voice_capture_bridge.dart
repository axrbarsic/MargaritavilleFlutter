import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'voice_capture_contract.dart';
import 'voice_capture_event_router.dart';
import 'voice_capture_mapping.dart';
import 'voice_capture_transport.dart';

abstract interface class VoiceCaptureBridge {
  Future<VoiceCaptureCapabilities> getCapabilities({
    String localeIdentifier = VoiceCaptureContract.defaultLocaleIdentifier,
  });

  Future<VoiceCaptureAcknowledgement> startCapture(
    VoiceCaptureStartRequest request,
  );

  Future<VoiceCaptureAcknowledgement> stopCapture(String operationId);

  Future<VoiceCaptureAcknowledgement> cancelCapture(String operationId);

  Future<void> releaseResult(String resultId);

  VoiceCaptureEventSubscription subscribe(
    String operationId,
    VoiceCaptureEventListener listener, {
    bool replayLatest = true,
  });

  VoiceCaptureEventSubscription subscribeAll(
    VoiceCaptureEventListener listener,
  );

  void forgetOperation(String operationId);
}

final class PigeonVoiceCaptureBridge implements VoiceCaptureBridge {
  PigeonVoiceCaptureBridge({BinaryMessenger? binaryMessenger})
    : _transport = PigeonVoiceCaptureTransport(
        binaryMessenger: binaryMessenger,
      ),
      _router = VoiceCaptureEventRouter.instance {
    _router.ensureInstalled(binaryMessenger: binaryMessenger);
  }

  @visibleForTesting
  PigeonVoiceCaptureBridge.forTesting({
    required VoiceCaptureTransport transport,
    required VoiceCaptureEventRouter router,
  }) : _transport = transport,
       _router = router;

  final VoiceCaptureTransport _transport;
  final VoiceCaptureEventRouter _router;

  @override
  Future<VoiceCaptureCapabilities> getCapabilities({
    String localeIdentifier = VoiceCaptureContract.defaultLocaleIdentifier,
  }) async {
    try {
      return mapVoiceCapabilities(
        await _transport.getCapabilities(localeIdentifier),
      );
    } catch (error) {
      final failure = mapVoiceFailure(error);
      if (failure.code == VoiceCaptureFailureCode.unavailable) {
        return VoiceCaptureCapabilities.unavailable(failure.message);
      }
      throw failure;
    }
  }

  @override
  Future<VoiceCaptureAcknowledgement> startCapture(
    VoiceCaptureStartRequest request,
  ) async {
    try {
      final dto = await _transport.startCapture(mapVoiceStartRequest(request));
      return mapVoiceAcknowledgement(
        dto,
        expectedOperationId: request.operationId,
      );
    } catch (error) {
      throw mapVoiceFailure(error, operationId: request.operationId);
    }
  }

  @override
  Future<VoiceCaptureAcknowledgement> stopCapture(String operationId) async {
    try {
      return mapVoiceAcknowledgement(
        await _transport.stopCapture(operationId),
        expectedOperationId: operationId,
      );
    } catch (error) {
      throw mapVoiceFailure(error, operationId: operationId);
    }
  }

  @override
  Future<VoiceCaptureAcknowledgement> cancelCapture(String operationId) async {
    try {
      return mapVoiceAcknowledgement(
        await _transport.cancelCapture(operationId),
        expectedOperationId: operationId,
      );
    } catch (error) {
      throw mapVoiceFailure(error, operationId: operationId);
    }
  }

  @override
  Future<void> releaseResult(String resultId) async {
    try {
      await _transport.releaseResult(resultId);
    } catch (error) {
      throw mapVoiceFailure(error);
    }
  }

  @override
  VoiceCaptureEventSubscription subscribe(
    String operationId,
    VoiceCaptureEventListener listener, {
    bool replayLatest = true,
  }) => _router.subscribe(operationId, listener, replayLatest: replayLatest);

  @override
  VoiceCaptureEventSubscription subscribeAll(
    VoiceCaptureEventListener listener,
  ) => _router.subscribeAll(listener);

  @override
  void forgetOperation(String operationId) =>
      _router.forgetOperation(operationId);
}
