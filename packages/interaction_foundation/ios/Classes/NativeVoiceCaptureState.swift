import AVFoundation
import Foundation

@MainActor
final class ActiveNativeVoiceCapture {
  init(
    request: VoiceCaptureStartRequestDto,
    createdAt: Date,
    fileURL: URL,
    recorder: AVAudioRecorder,
    speechAllowed: Bool
  ) {
    operationId = request.operationId
    mediaId = request.mediaId
    localeIdentifier = request.localeIdentifier
    addsPunctuation = request.addsPunctuation
    self.createdAt = createdAt
    self.fileURL = fileURL
    self.recorder = recorder
    self.speechAllowed = speechAllowed
  }

  let operationId: String
  let mediaId: String
  let localeIdentifier: String
  let addsPunctuation: Bool
  let createdAt: Date
  let fileURL: URL
  var recorder: AVAudioRecorder?
  let speechAllowed: Bool
  var durationMs = 0
  var terminalPhase = VoiceCapturePhaseDto.completed
  var terminalStatus: VoiceCaptureStatusCodeDto?
}
