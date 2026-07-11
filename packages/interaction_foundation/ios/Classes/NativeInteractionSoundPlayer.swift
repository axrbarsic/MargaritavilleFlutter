import AVFoundation
import Foundation

final class NativeInteractionSoundPlayer: @unchecked Sendable {
  typealias AssetLookup = (String) -> URL?

  init(assetLookup: @escaping AssetLookup) {
    self.assetLookup = assetLookup
    observeAudioSessionChanges()
  }

  private let queue = DispatchQueue(
    label: "com.axr.interaction-foundation.sound",
    qos: .userInteractive
  )
  private let assetLookup: AssetLookup
  private var pools: [String: [AVAudioPlayer]] = [:]
  private var registrations: [String: NativeSoundRegistration] = [:]
  private var cursors: [String: Int] = [:]
  private var observers: [NSObjectProtocol] = []
  private var audioSessionNeedsRefresh = true
  private var respectSilentMode = true
  private var mixWithOthers = true
  private let audioSession = NativeAudioSessionCoordinator.shared

  deinit {
    observers.forEach(NotificationCenter.default.removeObserver)
  }

  func configure(
    registrations: [NativeSoundRegistration],
    poolSize: Int,
    respectSilentMode: Bool,
    mixWithOthers: Bool
  ) {
    queue.sync {
      stopAllPlayers()
      self.registrations = Dictionary(
        uniqueKeysWithValues: registrations.map { ($0.id, $0) }
      )
      self.respectSilentMode = respectSilentMode
      self.mixWithOthers = mixWithOthers
      pools = [:]
      cursors = [:]
      configureAudioSession()
      let count = min(max(poolSize, 1), 8)
      for registration in registrations {
        pools[registration.id] = (0 ..< count).compactMap { _ in
          makePlayer(registration)
        }
      }
    }
  }

  func play(soundId: String) {
    queue.async { [weak self] in self?.playNow(soundId) }
  }

  func setAudioContext(_ context: NativeInteractionAudioContext) {
    queue.async { [weak self] in
      guard let self else { return }
      switch context {
      case .interactive, .voicePlayback:
        configureAudioSession()
      case .voiceCapture, .background:
        stopAllPlayers()
        audioSession.suspendInteractive()
        audioSessionNeedsRefresh = true
      }
    }
  }

  private func playNow(_ soundId: String) {
    guard
      let registration = registrations[soundId],
      let players = pools[soundId],
      !players.isEmpty
    else { return }
    guard activateAudioSession() else { return }
    stopAllPlayers()
    var cursor = cursors[soundId] ?? 0
    let player = players.first(where: { !$0.isPlaying }) ?? players[cursor % players.count]
    cursor = (cursor + 1) % players.count
    cursors[soundId] = cursor
    player.currentTime = 0
    player.volume = Float(registration.volume)
    player.rate = Float(registration.rate)
    player.pan = Float(registration.pan)
    if !player.play() {
      configureAudioSession()
      player.prepareToPlay()
      player.currentTime = 0
      _ = player.play()
    }
  }

  private func makePlayer(_ registration: NativeSoundRegistration) -> AVAudioPlayer? {
    guard let url = assetLookup(registration.packageAssetPath) else {
      NSLog("Missing interaction sound %@", registration.id)
      return nil
    }
    do {
      let player = try AVAudioPlayer(contentsOf: url)
      player.enableRate = true
      player.volume = Float(registration.volume)
      player.rate = Float(registration.rate)
      player.pan = Float(registration.pan)
      player.prepareToPlay()
      return player
    } catch {
      NSLog(
        "Failed to load %@: %@",
        registration.id,
        error.localizedDescription
      )
      return nil
    }
  }

  private func activateAudioSession() -> Bool {
    if audioSessionNeedsRefresh {
      return configureAudioSession()
    }
    let activated = audioSession.activateInteractive()
    if !activated {
      audioSessionNeedsRefresh = true
    }
    return activated
  }

  @discardableResult
  private func configureAudioSession() -> Bool {
    let configured = audioSession.configureInteractive(
      respectSilentMode: respectSilentMode,
      mixWithOthers: mixWithOthers
    )
    audioSessionNeedsRefresh = !configured
    return configured
  }

  private func stopAllPlayers() {
    for player in pools.values.flatMap({ $0 }) where player.isPlaying {
      player.stop()
      player.currentTime = 0
    }
  }

  private func observeAudioSessionChanges() {
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
        self?.audioSession.invalidate()
        self?.queue.async { [weak self] in self?.audioSessionNeedsRefresh = true }
      }
    }
  }
}
