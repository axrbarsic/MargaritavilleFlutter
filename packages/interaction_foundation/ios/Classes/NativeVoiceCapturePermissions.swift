import AVFoundation
import Foundation
import Speech

enum NativeVoiceCapturePermissions {
  nonisolated static func requestSpeech() async -> Bool {
    if SFSpeechRecognizer.authorizationStatus() == .authorized { return true }
    return await withCheckedContinuation { continuation in
      SFSpeechRecognizer.requestAuthorization { status in
        continuation.resume(returning: status == .authorized)
      }
    }
  }

  nonisolated static func requestMicrophone() async -> Bool {
    await withCheckedContinuation { continuation in
      if #available(iOS 17.0, *) {
        AVAudioApplication.requestRecordPermission { allowed in
          continuation.resume(returning: allowed)
        }
      } else {
        AVAudioSession.sharedInstance().requestRecordPermission { allowed in
          continuation.resume(returning: allowed)
        }
      }
    }
  }

  static func speechState() -> VoicePermissionStateDto {
    switch SFSpeechRecognizer.authorizationStatus() {
    case .notDetermined: .notDetermined
    case .denied: .denied
    case .restricted: .restricted
    case .authorized: .granted
    @unknown default: .unsupported
    }
  }

  static func microphoneState() -> VoicePermissionStateDto {
    switch AVAudioSession.sharedInstance().recordPermission {
    case .undetermined: .notDetermined
    case .denied: .denied
    case .granted: .granted
    @unknown default: .unsupported
    }
  }

  static func recognizerAvailable(localeIdentifier: String) -> Bool {
    SFSpeechRecognizer(
      locale: Locale(identifier: localeIdentifier)
    )?.isAvailable == true
  }
}
