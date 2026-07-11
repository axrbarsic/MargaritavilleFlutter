import AVFoundation
import Foundation

public enum NativeAudioSessionCoordinatorError: LocalizedError {
  case captureBusy

  public var errorDescription: String? {
    switch self {
    case .captureBusy:
      return "Другая голосовая запись уже активна"
    }
  }
}

public final class NativeAudioSessionCoordinator: @unchecked Sendable {
  public static let shared = NativeAudioSessionCoordinator()

  private init() {
    observeSessionChanges()
  }

  private let queue = DispatchQueue(
    label: "com.axr.audio-session-coordinator",
    qos: .userInitiated
  )
  private var captureOwner: String?
  private var interactiveCategory = AVAudioSession.Category.ambient
  private var interactiveOptions: AVAudioSession.CategoryOptions = [.mixWithOthers]
  private var interactiveNeedsRefresh = true
  private var observers: [NSObjectProtocol] = []

  deinit {
    observers.forEach(NotificationCenter.default.removeObserver)
  }

  @discardableResult
  public func configureInteractive(
    respectSilentMode: Bool,
    mixWithOthers: Bool
  ) -> Bool {
    queue.sync {
      interactiveCategory = respectSilentMode ? .ambient : .playback
      interactiveOptions = mixWithOthers ? [.mixWithOthers] : []
      interactiveNeedsRefresh = true
      return activateInteractiveLocked()
    }
  }

  @discardableResult
  public func activateInteractive() -> Bool {
    queue.sync { activateInteractiveLocked() }
  }

  public func suspendInteractive() {
    queue.sync {
      guard captureOwner == nil else { return }
      deactivateLocked()
      interactiveNeedsRefresh = true
    }
  }

  public func acquireVoiceCapture(owner: String) throws {
    try queue.sync {
      if let captureOwner, captureOwner != owner {
        throw NativeAudioSessionCoordinatorError.captureBusy
      }
      let session = AVAudioSession.sharedInstance()
      try session.setCategory(.record, mode: .default, options: [])
      try session.setActive(true)
      captureOwner = owner
      interactiveNeedsRefresh = true
    }
  }

  public func releaseVoiceCapture(owner: String) {
    queue.sync {
      guard captureOwner == owner else { return }
      captureOwner = nil
      deactivateLocked()
      interactiveNeedsRefresh = true
    }
  }

  public func invalidate() {
    queue.async { [weak self] in
      self?.interactiveNeedsRefresh = true
    }
  }

  private func activateInteractiveLocked() -> Bool {
    guard captureOwner == nil else { return false }
    do {
      let session = AVAudioSession.sharedInstance()
      if interactiveNeedsRefresh {
        try session.setCategory(
          interactiveCategory,
          mode: .default,
          options: interactiveOptions
        )
      }
      try session.setActive(true)
      interactiveNeedsRefresh = false
      return true
    } catch {
      interactiveNeedsRefresh = true
      return false
    }
  }

  private func deactivateLocked() {
    try? AVAudioSession.sharedInstance().setActive(
      false,
      options: .notifyOthersOnDeactivation
    )
  }

  private func observeSessionChanges() {
    let names: [Notification.Name] = [
      AVAudioSession.interruptionNotification,
      AVAudioSession.routeChangeNotification,
      AVAudioSession.mediaServicesWereResetNotification,
    ]
    observers = names.map { name in
      NotificationCenter.default.addObserver(
        forName: name,
        object: AVAudioSession.sharedInstance(),
        queue: nil
      ) { [weak self] _ in
        self?.invalidate()
      }
    }
  }
}
