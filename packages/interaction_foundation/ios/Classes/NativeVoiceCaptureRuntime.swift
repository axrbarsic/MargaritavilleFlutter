import AVFoundation
import Foundation
import UIKit

@MainActor
final class NativeVoiceCaptureRuntime {
  static let contractVersion: Int64 = 1

  init(onEvent: @escaping (VoiceCaptureEventDto) -> Void) {
    self.onEvent = onEvent
    NativeVoiceTemporaryFiles.cleanupOrphans()
  }

  private let audioSession = NativeAudioSessionCoordinator.shared
  private let recognition = NativeVoiceRecognition()
  private let onEvent: (VoiceCaptureEventDto) -> Void
  private var operationId: String?
  private var sequence: Int64 = 0
  private var active: ActiveNativeVoiceCapture?
  private var retainedResults: [String: URL] = [:]

  func capabilities(localeIdentifier: String) -> VoiceCaptureCapabilitiesDto {
    VoiceCaptureCapabilitiesDto(
      contractVersion: Self.contractVersion,
      supported: true,
      speechPermission: NativeVoiceCapturePermissions.speechState(),
      microphonePermission: NativeVoiceCapturePermissions.microphoneState(),
      recognizerAvailable: NativeVoiceCapturePermissions.recognizerAvailable(
        localeIdentifier: localeIdentifier
      ),
      unavailableReason: nil
    )
  }

  func start(_ request: VoiceCaptureStartRequestDto) async -> VoiceCaptureAckDto {
    guard request.contractVersion == Self.contractVersion else {
      return voiceAck(request.operationId, accepted: false, status: .unsupported)
    }
    guard operationId == nil else {
      return voiceAck(request.operationId, accepted: false, status: .busy)
    }
    operationId = request.operationId
    sequence = 0
    emit(request.operationId, phase: .requestingPermissions, status: .checkingAccess)

    let speechAllowed = await NativeVoiceCapturePermissions.requestSpeech()
    guard isCurrent(request.operationId) else {
      return voiceAck(request.operationId, accepted: false, status: .cancelled)
    }
    if !speechAllowed {
      emit(
        request.operationId,
        phase: .requestingPermissions,
        status: .speechDenied
      )
    }
    let microphoneAllowed = await NativeVoiceCapturePermissions.requestMicrophone()
    guard isCurrent(request.operationId) else {
      return voiceAck(request.operationId, accepted: false, status: .cancelled)
    }
    guard microphoneAllowed else {
      finishFailure(request.operationId, status: .microphoneDenied)
      return voiceAck(request.operationId, accepted: false, status: .microphoneDenied)
    }

    emit(request.operationId, phase: .starting, status: .startingMicrophone)
    do {
      let capture = try makeCapture(request, speechAllowed: speechAllowed)
      guard isCurrent(request.operationId) else {
        capture.recorder?.stop()
        NativeVoiceTemporaryFiles.remove(capture.fileURL)
        audioSession.releaseVoiceCapture(owner: request.operationId)
        return voiceAck(request.operationId, accepted: false, status: .cancelled)
      }
      active = capture
      emit(request.operationId, phase: .recording, status: .recording)
      return voiceAck(request.operationId, accepted: true, status: .recording)
    } catch {
      audioSession.releaseVoiceCapture(owner: request.operationId)
      finishFailure(
        request.operationId,
        status: .microphoneFailure,
        diagnostic: error.localizedDescription
      )
      return voiceAck(
        request.operationId,
        accepted: false,
        status: .microphoneFailure,
        diagnostic: error.localizedDescription
      )
    }
  }

  func stop(_ requestedOperationId: String) -> VoiceCaptureAckDto {
    guard isCurrent(requestedOperationId), active?.recorder != nil else {
      return voiceAck(requestedOperationId, accepted: false, status: .noRecording)
    }
    beginFinishing(
      operationId: requestedOperationId,
      terminalPhase: .completed,
      terminalStatus: nil
    )
    return voiceAck(requestedOperationId, accepted: true, status: .finishingTranscription)
  }

  func cancel(_ requestedOperationId: String) -> VoiceCaptureAckDto {
    guard isCurrent(requestedOperationId) else {
      return voiceAck(requestedOperationId, accepted: false, status: .cancelled)
    }
    terminateCurrent(phase: .cancelled, status: .cancelled)
    return voiceAck(requestedOperationId, accepted: true, status: .cancelled)
  }

  func interrupt(status: VoiceCaptureStatusCodeDto) {
    guard let operationId else { return }
    if active?.recorder != nil {
      beginFinishing(
        operationId: operationId,
        terminalPhase: .interrupted,
        terminalStatus: status
      )
    } else if let active {
      active.terminalPhase = .interrupted
      active.terminalStatus = status
      recognition.cancel()
    } else {
      terminateCurrent(phase: .interrupted, status: status)
    }
  }

  func releaseResult(_ resultId: String) {
    NativeVoiceTemporaryFiles.remove(retainedResults.removeValue(forKey: resultId))
  }

  private func makeCapture(
    _ request: VoiceCaptureStartRequestDto,
    speechAllowed: Bool
  ) throws -> ActiveNativeVoiceCapture {
    try audioSession.acquireVoiceCapture(owner: request.operationId)
    let url = NativeVoiceTemporaryFiles.makeURL()
    let settings: [String: Any] = [
      AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
      AVSampleRateKey: 44_100,
      AVNumberOfChannelsKey: 1,
      AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
    ]
    do {
      let recorder = try AVAudioRecorder(url: url, settings: settings)
      guard recorder.record() else {
        throw NSError(
          domain: "VoiceCapture",
          code: 1,
          userInfo: [NSLocalizedDescriptionKey: "Не удалось запустить запись"]
        )
      }
      return ActiveNativeVoiceCapture(
        request: request,
        createdAt: Date(),
        fileURL: url,
        recorder: recorder,
        speechAllowed: speechAllowed
      )
    } catch {
      NativeVoiceTemporaryFiles.remove(url)
      throw error
    }
  }

  private func beginFinishing(
    operationId: String,
    terminalPhase: VoiceCapturePhaseDto,
    terminalStatus: VoiceCaptureStatusCodeDto?
  ) {
    guard let active else { return }
    active.terminalPhase = terminalPhase
    active.terminalStatus = terminalStatus
    active.durationMs = Int((active.recorder?.currentTime ?? 0) * 1_000)
    active.recorder?.stop()
    active.recorder = nil
    audioSession.releaseVoiceCapture(owner: operationId)
    emit(operationId, phase: .finishing, status: .finishingTranscription)
    Task { @MainActor [weak self] in
      guard let self else { return }
      let outcome: NativeVoiceRecognitionOutcome = if active.speechAllowed {
        await recognition.recognize(
          fileURL: active.fileURL,
          localeIdentifier: active.localeIdentifier,
          addsPunctuation: active.addsPunctuation
        )
      } else {
        .unavailable
      }
      complete(active, outcome: outcome)
    }
  }

  private func complete(
    _ capture: ActiveNativeVoiceCapture,
    outcome: NativeVoiceRecognitionOutcome
  ) {
    guard isCurrent(capture.operationId) else { return }
    let resultId = UUID().uuidString
    retainedResults[resultId] = capture.fileURL
    let recognizedText: String?
    switch outcome {
    case .recognized(let text): recognizedText = text
    case .unavailable: recognizedText = nil
    }
    let cleanText = recognizedText?.trimmingCharacters(
      in: CharacterSet.whitespacesAndNewlines
    )
    let result = VoiceCaptureResultDto(
      contractVersion: Self.contractVersion,
      operationId: capture.operationId,
      resultId: resultId,
      temporaryFilePath: capture.fileURL.path,
      originDeviceId: UIDevice.current.identifierForVendor?.uuidString ?? "ios",
      createdAtMicros: Int64(capture.createdAt.timeIntervalSince1970 * 1_000_000),
      durationMs: Int64(capture.durationMs),
      byteLength: NativeVoiceTemporaryFiles.byteLength(capture.fileURL),
      mimeType: "audio/mp4",
      codec: "aac",
      sampleRateHz: 44_100,
      channelCount: 1,
      recognizedText: cleanText
    )
    let completionStatus: VoiceCaptureStatusCodeDto = switch outcome {
    case .unavailable: .speechUnavailable
    case .recognized where cleanText?.isEmpty == false: .completed
    case .recognized: .noRecognizedText
    }
    let status = capture.terminalStatus ?? completionStatus
    active = nil
    operationId = nil
    emit(
      capture.operationId,
      phase: capture.terminalPhase,
      status: status,
      result: result
    )
  }

  private func terminateCurrent(
    phase: VoiceCapturePhaseDto,
    status: VoiceCaptureStatusCodeDto
  ) {
    guard let current = operationId else { return }
    recognition.cancel()
    active?.recorder?.stop()
    NativeVoiceTemporaryFiles.remove(active?.fileURL)
    active = nil
    operationId = nil
    audioSession.releaseVoiceCapture(owner: current)
    emit(current, phase: phase, status: status)
  }

  private func finishFailure(
    _ failedOperationId: String,
    status: VoiceCaptureStatusCodeDto,
    diagnostic: String? = nil
  ) {
    active = nil
    operationId = nil
    emit(
      failedOperationId,
      phase: .failed,
      status: status,
      diagnostic: diagnostic
    )
  }

  private func emit(
    _ operationId: String,
    phase: VoiceCapturePhaseDto,
    status: VoiceCaptureStatusCodeDto,
    diagnostic: String? = nil,
    result: VoiceCaptureResultDto? = nil
  ) {
    sequence += 1
    onEvent(VoiceCaptureEventDto(
      contractVersion: Self.contractVersion,
      operationId: operationId,
      sequence: sequence,
      phase: phase,
      statusCode: status,
      diagnosticMessage: diagnostic,
      result: result
    ))
  }

  private func isCurrent(_ id: String) -> Bool { operationId == id }
}
