import 'package:flutter/services.dart';

import 'generated/voice_capture_api.g.dart';

abstract interface class VoiceCaptureTransport {
  Future<VoiceCaptureCapabilitiesDto> getCapabilities(String localeIdentifier);

  Future<VoiceCaptureAckDto> startCapture(VoiceCaptureStartRequestDto request);

  Future<VoiceCaptureAckDto> stopCapture(String operationId);

  Future<VoiceCaptureAckDto> cancelCapture(String operationId);

  Future<void> releaseResult(String resultId);
}

final class PigeonVoiceCaptureTransport implements VoiceCaptureTransport {
  PigeonVoiceCaptureTransport({BinaryMessenger? binaryMessenger})
    : _api = VoiceCaptureHostApi(binaryMessenger: binaryMessenger);

  final VoiceCaptureHostApi _api;

  @override
  Future<VoiceCaptureCapabilitiesDto> getCapabilities(
    String localeIdentifier,
  ) => _api.getCapabilities(localeIdentifier);

  @override
  Future<VoiceCaptureAckDto> startCapture(
    VoiceCaptureStartRequestDto request,
  ) => _api.startCapture(request);

  @override
  Future<VoiceCaptureAckDto> stopCapture(String operationId) =>
      _api.stopCapture(operationId);

  @override
  Future<VoiceCaptureAckDto> cancelCapture(String operationId) =>
      _api.cancelCapture(operationId);

  @override
  Future<void> releaseResult(String resultId) => _api.releaseResult(resultId);
}
