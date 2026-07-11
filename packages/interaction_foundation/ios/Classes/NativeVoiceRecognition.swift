import Foundation
import Speech

enum NativeVoiceRecognitionOutcome {
  case recognized(String?)
  case unavailable
}

@MainActor
final class NativeVoiceRecognition {
  private var recognitionTask: SFSpeechRecognitionTask?
  private var timeoutTask: Task<Void, Never>?
  private var continuation: CheckedContinuation<
    NativeVoiceRecognitionOutcome,
    Never
  >?

  func recognize(
    fileURL: URL,
    localeIdentifier: String,
    addsPunctuation: Bool
  ) async -> NativeVoiceRecognitionOutcome {
    cancel()
    guard let recognizer = SFSpeechRecognizer(
      locale: Locale(identifier: localeIdentifier)
    ), recognizer.isAvailable else { return .unavailable }

    let request = SFSpeechURLRecognitionRequest(url: fileURL)
    request.shouldReportPartialResults = false
    request.taskHint = .dictation
    if #available(iOS 16.0, *) {
      request.addsPunctuation = addsPunctuation
    }

    return await withTaskCancellationHandler {
      await withCheckedContinuation { continuation in
        self.continuation = continuation
        recognitionTask = recognizer.recognitionTask(with: request) {
          [weak self] result, error in
          let finalText = result?.isFinal == true
            ? result?.bestTranscription.formattedString
            : nil
          guard finalText != nil || error != nil else { return }
          Task { @MainActor [weak self] in
            self?.finish(.recognized(finalText))
          }
        }
        timeoutTask = Task { @MainActor [weak self] in
          try? await Task.sleep(nanoseconds: 30_000_000_000)
          guard !Task.isCancelled else { return }
          self?.finish(.recognized(nil))
        }
      }
    } onCancel: {
      Task { @MainActor [weak self] in self?.cancel() }
    }
  }

  func cancel() {
    recognitionTask?.cancel()
    finish(.recognized(nil))
  }

  private func finish(_ outcome: NativeVoiceRecognitionOutcome) {
    guard let continuation else { return }
    self.continuation = nil
    recognitionTask = nil
    timeoutTask?.cancel()
    timeoutTask = nil
    continuation.resume(returning: outcome)
  }
}
