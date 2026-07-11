import Foundation

func voiceAck(
  _ operationId: String,
  accepted: Bool,
  status: VoiceCaptureStatusCodeDto,
  diagnostic: String? = nil
) -> VoiceCaptureAckDto {
  VoiceCaptureAckDto(
    contractVersion: NativeVoiceCaptureRuntime.contractVersion,
    operationId: operationId,
    accepted: accepted,
    statusCode: status,
    diagnosticMessage: diagnostic
  )
}
