import 'package:flutter/services.dart';

import 'generated/voice_capture_api.g.dart';
import 'voice_capture_contract.dart';

VoiceCaptureCapabilities mapVoiceCapabilities(VoiceCaptureCapabilitiesDto dto) {
  _requireContract(dto.contractVersion);
  return VoiceCaptureCapabilities(
    contractVersion: dto.contractVersion,
    supported: dto.supported,
    speechPermission: _permission(dto.speechPermission),
    microphonePermission: _permission(dto.microphonePermission),
    recognizerAvailable: dto.recognizerAvailable,
    unavailableReason: dto.unavailableReason,
  );
}

VoiceCaptureStartRequestDto mapVoiceStartRequest(
  VoiceCaptureStartRequest request,
) {
  _requireContract(request.contractVersion, operationId: request.operationId);
  return VoiceCaptureStartRequestDto(
    contractVersion: request.contractVersion,
    operationId: request.operationId,
    mediaId: request.mediaId,
    localeIdentifier: request.localeIdentifier,
    addsPunctuation: request.addsPunctuation,
  );
}

VoiceCaptureAcknowledgement mapVoiceAcknowledgement(
  VoiceCaptureAckDto dto, {
  String? expectedOperationId,
}) {
  _requireContract(dto.contractVersion, operationId: dto.operationId);
  if (expectedOperationId != null && dto.operationId != expectedOperationId) {
    throw VoiceCaptureFailure(
      code: VoiceCaptureFailureCode.invalidResponse,
      message: 'Нативный ответ относится к другой операции записи.',
      operationId: expectedOperationId,
      details: dto.operationId,
    );
  }
  return VoiceCaptureAcknowledgement(
    contractVersion: dto.contractVersion,
    operationId: dto.operationId,
    accepted: dto.accepted,
    statusCode: _status(dto.statusCode),
    diagnosticMessage: dto.diagnosticMessage,
  );
}

VoiceCaptureResult mapVoiceResult(VoiceCaptureResultDto dto) {
  _requireContract(dto.contractVersion, operationId: dto.operationId);
  return VoiceCaptureResult(
    contractVersion: dto.contractVersion,
    operationId: dto.operationId,
    resultId: dto.resultId,
    temporaryFilePath: dto.temporaryFilePath,
    originDeviceId: dto.originDeviceId,
    createdAtMicros: dto.createdAtMicros,
    durationMs: dto.durationMs,
    byteLength: dto.byteLength,
    mimeType: dto.mimeType,
    codec: dto.codec,
    sampleRateHz: dto.sampleRateHz,
    channelCount: dto.channelCount,
    recognizedText: dto.recognizedText,
  );
}

VoiceCaptureEvent mapVoiceEvent(VoiceCaptureEventDto dto) {
  _requireContract(dto.contractVersion, operationId: dto.operationId);
  final result = dto.result == null ? null : mapVoiceResult(dto.result!);
  if (result != null && result.operationId != dto.operationId) {
    throw VoiceCaptureFailure(
      code: VoiceCaptureFailureCode.invalidResponse,
      message: 'Нативный результат относится к другой операции записи.',
      operationId: dto.operationId,
      details: result.operationId,
    );
  }
  return VoiceCaptureEvent(
    contractVersion: dto.contractVersion,
    operationId: dto.operationId,
    sequence: dto.sequence,
    phase: _phase(dto.phase),
    statusCode: _status(dto.statusCode),
    diagnosticMessage: dto.diagnosticMessage,
    result: result,
  );
}

VoiceCaptureFailure mapVoiceFailure(Object error, {String? operationId}) {
  if (error is VoiceCaptureFailure) return error;
  if (error is MissingPluginException) {
    return VoiceCaptureFailure(
      code: VoiceCaptureFailureCode.unavailable,
      message: 'Нативная голосовая запись недоступна.',
      operationId: operationId,
      details: error,
    );
  }
  if (error is PlatformException) {
    final code = switch (error.code) {
      'channel-error' || 'unsupported' => VoiceCaptureFailureCode.unavailable,
      'speech-denied' ||
      'microphone-denied' ||
      'permission-denied' => VoiceCaptureFailureCode.permissionDenied,
      'busy' => VoiceCaptureFailureCode.busy,
      'contract-mismatch' => VoiceCaptureFailureCode.contractMismatch,
      _ => VoiceCaptureFailureCode.nativeFailure,
    };
    return VoiceCaptureFailure(
      code: code,
      message: 'Сбой нативной голосовой записи.',
      operationId: operationId,
      details: error.details,
    );
  }
  return VoiceCaptureFailure(
    code: VoiceCaptureFailureCode.transport,
    message: 'Сбой канала голосовой записи.',
    operationId: operationId,
    details: error,
  );
}

void _requireContract(int version, {String? operationId}) {
  if (version == VoiceCaptureContract.version) return;
  throw VoiceCaptureFailure(
    code: VoiceCaptureFailureCode.contractMismatch,
    message: 'Неподдерживаемая версия голосового контракта: $version.',
    operationId: operationId,
    details: version,
  );
}

VoicePermissionState _permission(VoicePermissionStateDto value) =>
    switch (value) {
      VoicePermissionStateDto.notDetermined =>
        VoicePermissionState.notDetermined,
      VoicePermissionStateDto.denied => VoicePermissionState.denied,
      VoicePermissionStateDto.restricted => VoicePermissionState.restricted,
      VoicePermissionStateDto.granted => VoicePermissionState.granted,
      VoicePermissionStateDto.unsupported => VoicePermissionState.unsupported,
    };

VoiceCapturePhase _phase(VoiceCapturePhaseDto value) => switch (value) {
  VoiceCapturePhaseDto.idle => VoiceCapturePhase.idle,
  VoiceCapturePhaseDto.requestingPermissions =>
    VoiceCapturePhase.requestingPermissions,
  VoiceCapturePhaseDto.starting => VoiceCapturePhase.starting,
  VoiceCapturePhaseDto.recording => VoiceCapturePhase.recording,
  VoiceCapturePhaseDto.finishing => VoiceCapturePhase.finishing,
  VoiceCapturePhaseDto.completed => VoiceCapturePhase.completed,
  VoiceCapturePhaseDto.failed => VoiceCapturePhase.failed,
  VoiceCapturePhaseDto.interrupted => VoiceCapturePhase.interrupted,
  VoiceCapturePhaseDto.cancelled => VoiceCapturePhase.cancelled,
};

VoiceCaptureStatusCode _status(VoiceCaptureStatusCodeDto value) =>
    VoiceCaptureStatusCode.values[value.index];
