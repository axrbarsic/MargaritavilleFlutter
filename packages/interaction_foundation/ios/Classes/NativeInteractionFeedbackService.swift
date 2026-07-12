import Flutter
import UIKit

final class NativeInteractionFeedbackService: NativeInteractionFeedbackHostApi {
  init(soundPlayer: NativeInteractionSoundPlayer) {
    self.soundPlayer = soundPlayer
    onMain(prepare)
  }

  private let soundPlayer: NativeInteractionSoundPlayer
  private let selection = UISelectionFeedbackGenerator()
  private let light = UIImpactFeedbackGenerator(style: .light)
  private let medium = UIImpactFeedbackGenerator(style: .medium)
  private let heavy = UIImpactFeedbackGenerator(style: .heavy)
  private let notification = UINotificationFeedbackGenerator()
  private var audioContext = NativeInteractionAudioContext.interactive
  private var coalescingWindow = 0.045
  private var queuedSound: QueuedSound?
  private var soundWorkItem: DispatchWorkItem?
  private var recentRequestIDs: Set<String> = []
  private var recentRequestOrder: [String] = []
  private let requestIDCapacity = 256

  func configure(configuration: NativeFeedbackConfiguration) throws {
    onMain {
      self.coalescingWindow = max(
        0,
        TimeInterval(configuration.soundCoalescingWindowMs) / 1_000
      )
      self.soundPlayer.configure(
        registrations: configuration.sounds,
        poolSize: Int(configuration.playerPoolSize),
        respectSilentMode: configuration.respectSilentMode,
        mixWithOthers: configuration.mixWithOthers
      )
    }
  }

  func emit(request: NativeFeedbackRequest) throws {
    onMain {
      guard self.audioContext != .background else { return }
      guard self.remember(request.requestId) else { return }
      self.performHaptic(request.cue)
      guard self.audioContext != .voiceCapture, let soundId = request.soundId else {
        return
      }
      self.queueSound(id: soundId, priority: request.soundPriority)
    }
  }

  private func remember(_ requestID: String) -> Bool {
    guard recentRequestIDs.insert(requestID).inserted else { return false }
    recentRequestOrder.append(requestID)
    if recentRequestOrder.count > requestIDCapacity {
      recentRequestIDs.remove(recentRequestOrder.removeFirst())
    }
    return true
  }

  func previewSound(soundId: String) throws {
    onMain {
      guard self.audioContext != .background, self.audioContext != .voiceCapture else {
        return
      }
      self.cancelQueuedSound()
      self.soundPlayer.play(soundId: soundId)
    }
  }

  func setAudioContext(context: NativeInteractionAudioContext) throws {
    onMain {
      self.audioContext = context
      if context == .background || context == .voiceCapture {
        self.cancelQueuedSound()
      }
      self.soundPlayer.setAudioContext(context)
    }
  }

  func clearPending() throws {
    onMain(cancelQueuedSound)
  }

  private func performHaptic(_ cue: NativeFeedbackCue) {
    switch cue {
    case .none:
      return
    case .tap:
      light.impactOccurred(intensity: 0.42)
    case .confirm:
      notification.notificationOccurred(.success)
    case .longPress:
      heavy.impactOccurred(intensity: 1)
    case .holdStart:
      selection.selectionChanged()
    case .holdWarning:
      notification.notificationOccurred(.warning)
    case .holdCommit:
      heavy.impactOccurred(intensity: 1)
    case .select:
      medium.impactOccurred(intensity: 0.86)
    case .deselect:
      light.impactOccurred(intensity: 0.36)
    case .invalid:
      notification.notificationOccurred(.error)
    case .detent:
      selection.selectionChanged()
    }
    DispatchQueue.main.async { [weak self] in self?.prepare() }
  }

  private func queueSound(id: String, priority: Int64) {
    let next = QueuedSound(id: id, priority: priority)
    if let queuedSound, queuedSound.priority > next.priority { return }
    queuedSound = next
    guard soundWorkItem == nil else { return }
    let item = DispatchWorkItem { [weak self] in self?.flushQueuedSound() }
    soundWorkItem = item
    DispatchQueue.main.asyncAfter(deadline: .now() + coalescingWindow, execute: item)
  }

  private func flushQueuedSound() {
    soundWorkItem = nil
    guard let queuedSound else { return }
    self.queuedSound = nil
    soundPlayer.play(soundId: queuedSound.id)
  }

  private func cancelQueuedSound() {
    soundWorkItem?.cancel()
    soundWorkItem = nil
    queuedSound = nil
  }

  private func prepare() {
    selection.prepare()
    light.prepare()
    medium.prepare()
    heavy.prepare()
    notification.prepare()
  }

  private func onMain(_ operation: @escaping () -> Void) {
    if Thread.isMainThread {
      operation()
    } else {
      DispatchQueue.main.sync(execute: operation)
    }
  }

  private struct QueuedSound {
    let id: String
    let priority: Int64
  }
}
