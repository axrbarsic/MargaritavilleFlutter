import AVFoundation
import Flutter
import Foundation

@MainActor
final class NativeVoiceCaptureService: VoiceCaptureHostApi {
  init(binaryMessenger: FlutterBinaryMessenger) {
    flutterApi = VoiceCaptureFlutterApi(binaryMessenger: binaryMessenger)
    runtime = NativeVoiceCaptureRuntime { [weak flutterApi] event in
      flutterApi?.onCaptureEvent(event: event) { _ in }
    }
    observeAudioSession()
  }

  private let flutterApi: VoiceCaptureFlutterApi
  private let runtime: NativeVoiceCaptureRuntime
  private var observers: [NSObjectProtocol] = []

  deinit {
    observers.forEach(NotificationCenter.default.removeObserver)
  }

  func getCapabilities(
    localeIdentifier: String,
    completion: @escaping (Result<VoiceCaptureCapabilitiesDto, Error>) -> Void
  ) {
    completion(.success(runtime.capabilities(localeIdentifier: localeIdentifier)))
  }

  func startCapture(
    request: VoiceCaptureStartRequestDto,
    completion: @escaping (Result<VoiceCaptureAckDto, Error>) -> Void
  ) {
    Task { @MainActor in
      completion(.success(await runtime.start(request)))
    }
  }

  func stopCapture(
    operationId: String,
    completion: @escaping (Result<VoiceCaptureAckDto, Error>) -> Void
  ) {
    completion(.success(runtime.stop(operationId)))
  }

  func cancelCapture(
    operationId: String,
    completion: @escaping (Result<VoiceCaptureAckDto, Error>) -> Void
  ) {
    completion(.success(runtime.cancel(operationId)))
  }

  func releaseResult(
    resultId: String,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    runtime.releaseResult(resultId)
    completion(.success(()))
  }

  func applicationDidEnterBackground() {
    runtime.interrupt(status: .interrupted)
  }

  func mediaServicesWereReset() {
    runtime.interrupt(status: .mediaServicesReset)
  }

  private func observeAudioSession() {
    let center = NotificationCenter.default
    observers.append(
      center.addObserver(
        forName: UIApplication.didEnterBackgroundNotification,
        object: nil,
        queue: nil
      ) { [weak self] _ in
        Task { @MainActor [weak self] in
          self?.applicationDidEnterBackground()
        }
      }
    )
    observers.append(
      center.addObserver(
        forName: AVAudioSession.interruptionNotification,
        object: AVAudioSession.sharedInstance(),
        queue: nil
      ) { [weak self] notification in
        let rawValue = notification.userInfo?[
          AVAudioSessionInterruptionTypeKey
        ] as? UInt
        guard rawValue == AVAudioSession.InterruptionType.began.rawValue else {
          return
        }
        Task { @MainActor [weak self] in
          self?.runtime.interrupt(status: .interrupted)
        }
      }
    )
    observers.append(
      center.addObserver(
        forName: AVAudioSession.mediaServicesWereResetNotification,
        object: AVAudioSession.sharedInstance(),
        queue: nil
      ) { [weak self] _ in
        Task { @MainActor [weak self] in
          self?.mediaServicesWereReset()
        }
      }
    )
  }
}
