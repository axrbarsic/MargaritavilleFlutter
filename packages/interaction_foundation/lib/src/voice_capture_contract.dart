import 'package:flutter/foundation.dart';

abstract final class VoiceCaptureContract {
  static const version = 1;
  static const defaultLocaleIdentifier = 'ru-RU';
}

enum VoiceCapturePhase {
  idle,
  requestingPermissions,
  starting,
  recording,
  finishing,
  completed,
  failed,
  interrupted,
  cancelled,
}

enum VoiceCaptureStatusCode {
  ready,
  checkingAccess,
  speechDenied,
  microphoneDenied,
  startingMicrophone,
  recording,
  finishingTranscription,
  noRecording,
  speechUnavailable,
  completed,
  noRecognizedText,
  microphoneFailure,
  interrupted,
  mediaServicesReset,
  cancelled,
  busy,
  unsupported,
}

enum VoicePermissionState {
  notDetermined,
  denied,
  restricted,
  granted,
  unsupported,
}

enum VoiceCaptureFailureCode {
  unavailable,
  permissionDenied,
  busy,
  invalidResponse,
  contractMismatch,
  nativeFailure,
  transport,
}

@immutable
final class VoiceCaptureCapabilities {
  const VoiceCaptureCapabilities({
    required this.contractVersion,
    required this.supported,
    required this.speechPermission,
    required this.microphonePermission,
    required this.recognizerAvailable,
    this.unavailableReason,
  });

  const VoiceCaptureCapabilities.unavailable([String? reason])
    : contractVersion = VoiceCaptureContract.version,
      supported = false,
      speechPermission = VoicePermissionState.unsupported,
      microphonePermission = VoicePermissionState.unsupported,
      recognizerAvailable = false,
      unavailableReason = reason;

  final int contractVersion;
  final bool supported;
  final VoicePermissionState speechPermission;
  final VoicePermissionState microphonePermission;
  final bool recognizerAvailable;
  final String? unavailableReason;
}

@immutable
final class VoiceCaptureStartRequest {
  const VoiceCaptureStartRequest({
    required this.operationId,
    required this.mediaId,
    this.contractVersion = VoiceCaptureContract.version,
    this.localeIdentifier = VoiceCaptureContract.defaultLocaleIdentifier,
    this.addsPunctuation = true,
  }) : assert(operationId != ''),
       assert(mediaId != ''),
       assert(localeIdentifier != '');

  final int contractVersion;
  final String operationId;
  final String mediaId;
  final String localeIdentifier;
  final bool addsPunctuation;
}

@immutable
final class VoiceCaptureAcknowledgement {
  const VoiceCaptureAcknowledgement({
    required this.contractVersion,
    required this.operationId,
    required this.accepted,
    required this.statusCode,
    this.diagnosticMessage,
  });

  final int contractVersion;
  final String operationId;
  final bool accepted;
  final VoiceCaptureStatusCode statusCode;
  final String? diagnosticMessage;
}

@immutable
final class VoiceCaptureResult {
  const VoiceCaptureResult({
    required this.contractVersion,
    required this.operationId,
    required this.resultId,
    required this.temporaryFilePath,
    required this.originDeviceId,
    required this.createdAtMicros,
    required this.durationMs,
    required this.byteLength,
    required this.mimeType,
    required this.codec,
    required this.sampleRateHz,
    required this.channelCount,
    this.recognizedText,
  });

  final int contractVersion;
  final String operationId;
  final String resultId;
  final String temporaryFilePath;
  final String originDeviceId;
  final int createdAtMicros;
  final int durationMs;
  final int byteLength;
  final String mimeType;
  final String codec;
  final int sampleRateHz;
  final int channelCount;
  final String? recognizedText;
}

@immutable
final class VoiceCaptureEvent {
  const VoiceCaptureEvent({
    required this.contractVersion,
    required this.operationId,
    required this.sequence,
    required this.phase,
    required this.statusCode,
    this.diagnosticMessage,
    this.result,
  });

  final int contractVersion;
  final String operationId;
  final int sequence;
  final VoiceCapturePhase phase;
  final VoiceCaptureStatusCode statusCode;
  final String? diagnosticMessage;
  final VoiceCaptureResult? result;

  bool get isTerminal => switch (phase) {
    VoiceCapturePhase.completed ||
    VoiceCapturePhase.failed ||
    VoiceCapturePhase.interrupted ||
    VoiceCapturePhase.cancelled => true,
    _ => false,
  };
}

@immutable
final class VoiceCaptureFailure implements Exception {
  const VoiceCaptureFailure({
    required this.code,
    required this.message,
    this.operationId,
    this.details,
  });

  final VoiceCaptureFailureCode code;
  final String message;
  final String? operationId;
  final Object? details;

  @override
  String toString() => 'VoiceCaptureFailure($code, $message)';
}
