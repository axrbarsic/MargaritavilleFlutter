package com.axr.interaction_foundation

internal class AndroidVoiceCaptureUnavailableService : VoiceCaptureHostApi {
  override fun getCapabilities(
    localeIdentifier: String,
    callback: (Result<VoiceCaptureCapabilitiesDto>) -> Unit,
  ) {
    callback(
      Result.success(
        VoiceCaptureCapabilitiesDto(
          contractVersion = CONTRACT_VERSION,
          supported = false,
          speechPermission = VoicePermissionStateDto.UNSUPPORTED,
          microphonePermission = VoicePermissionStateDto.UNSUPPORTED,
          recognizerAvailable = false,
          unavailableReason = "Голосовая запись на Android пока не подключена",
        ),
      ),
    )
  }

  override fun startCapture(
    request: VoiceCaptureStartRequestDto,
    callback: (Result<VoiceCaptureAckDto>) -> Unit,
  ) {
    callback(Result.success(unsupportedAck(request.operationId)))
  }

  override fun stopCapture(
    operationId: String,
    callback: (Result<VoiceCaptureAckDto>) -> Unit,
  ) {
    callback(Result.success(unsupportedAck(operationId)))
  }

  override fun cancelCapture(
    operationId: String,
    callback: (Result<VoiceCaptureAckDto>) -> Unit,
  ) {
    callback(Result.success(unsupportedAck(operationId)))
  }

  override fun releaseResult(
    resultId: String,
    callback: (Result<Unit>) -> Unit,
  ) {
    callback(Result.success(Unit))
  }

  private fun unsupportedAck(operationId: String) =
    VoiceCaptureAckDto(
      contractVersion = CONTRACT_VERSION,
      operationId = operationId,
      accepted = false,
      statusCode = VoiceCaptureStatusCodeDto.UNSUPPORTED,
      diagnosticMessage = null,
    )

  private companion object {
    const val CONTRACT_VERSION = 1L
  }
}
