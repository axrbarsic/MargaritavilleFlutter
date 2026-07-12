import Flutter
import OSLog
import QuartzCore
import SharedAppFoundation
import UIKit

/// Keeps the historical plugin registration name while routing every visual
/// tile through one window-level runtime outside Flutter Platform Views.
enum EdrViewportPlugin {
  @MainActor
  static func register(with registrar: FlutterPluginRegistrar) {
    let adapter = EdrWindowRuntimeAdapter(
      binaryMessenger: registrar.messenger()
    )
    EdrOverlayHostApiSetup.setUp(
      binaryMessenger: registrar.messenger(),
      api: adapter
    )
  }
}

/// Structural presentation fence for the one window-level native surface.
/// Removing the overlay from the window hierarchy before Flutter starts a
/// route makes z-order safety deterministic; no transparent compositor frame
/// is used as a proxy for visibility.
@MainActor
final class EdrStructuralOverlayPlane {
  init(overlay: VisualRuntimeWindowOverlayView) {
    self.overlay = overlay
  }

  private let overlay: VisualRuntimeWindowOverlayView
  private(set) var generation: Int64 = 0

  func detachIfCurrent(_ isCurrent: () -> Bool) -> Int64? {
    guard isCurrent() else { return nil }
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    overlay.layer.opacity = 0
    overlay.removeFromSuperview()
    CATransaction.commit()
    guard overlay.superview == nil, isCurrent() else { return nil }
    generation &+= 1
    return generation
  }
}

@MainActor
private final class EdrWindowRuntimeAdapter: @preconcurrency EdrOverlayHostApi {
  init(binaryMessenger: FlutterBinaryMessenger) {
    flutterApi = EdrOverlayFlutterApi(binaryMessenger: binaryMessenger)
    overlay.onFirstFrameReady = { [weak self] readiness in
      guard let self,
        let committed = self.presentationFence.prepareFrameCommit(
          contentRevision: Int64(readiness.revision)
        )
      else { return }
      self.logger.debug(
        "EDR frame ready prepared session=\(committed.surfaceSessionID, privacy: .public) activation=\(committed.activationID, privacy: .public) content=\(committed.contentRevision, privacy: .public) presentation=\(committed.presentationRevision, privacy: .public)"
      )
      self.flutterApi.windowReady(
        surfaceSessionId: Int64(committed.surfaceSessionID),
        activationId: Int64(committed.activationID),
        contentRevision: committed.contentRevision,
        presentationRevision: committed.presentationRevision
      ) { [weak self] result in
        guard case .success(let acknowledgement) = result,
          let self,
          acknowledgement.accepted,
          acknowledgement.surfaceSessionId == Int64(committed.surfaceSessionID),
          acknowledgement.activationId == Int64(committed.activationID),
          acknowledgement.contentRevision == committed.contentRevision,
          acknowledgement.presentationRevision == committed.presentationRevision,
          self.presentationFence.acknowledgeFlutterReady(committed)
        else {
          self?.logger.debug(
            "EDR stale Flutter-ready acknowledgement ignored presentation=\(committed.presentationRevision, privacy: .public)"
          )
          return
        }
        self.setOverlaySuppressed(false)
        self.nativeMayPaint = true
        self.logger.debug(
          "EDR overlay revealed after Flutter-ready presentation=\(committed.presentationRevision, privacy: .public)"
        )
      }
    }
  }

  private let flutterApi: EdrOverlayFlutterApi
  private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "MargaritavilleFlutter",
    category: "EdrPresentation"
  )
  private let overlay = VisualRuntimeWindowOverlayView(frame: .zero)
  private let viewportMask = CAShapeLayer()
  private lazy var structuralPlane = EdrStructuralOverlayPlane(overlay: overlay)
  private var presentationFence = EdrPresentationFence()
  private var activeLayoutGeneration: Int64 = -1
  private var nativeMayPaint = false

  func configureWindow(
    surfaceSessionId: Int64,
    activationId: Int64,
    layoutGeneration: Int64,
    contentRevision: Int64,
    presentationRevision: Int64,
    geometryRevision: Int64,
    viewportLeft: Double,
    viewportTop: Double,
    viewportWidth: Double,
    viewportHeight: Double,
    scrollOffsetX: Double,
    scrollOffsetY: Double,
    tiles: [EdrTileSnapshot]
  ) throws {
    guard surfaceSessionId >= 0,
      activationId > 0,
      layoutGeneration >= 0,
      contentRevision >= 0,
      presentationRevision >= 0,
      geometryRevision >= 0
    else { return }
    let sessionID = UInt64(surfaceSessionId)
    let activationID = UInt64(activationId)
    let isNewActivation = activationID > presentationFence.highestActivationID
    guard isNewActivation || layoutGeneration >= activeLayoutGeneration else {
      return
    }
    guard presentationFence.acceptConfiguration(
      surfaceSessionID: sessionID,
      activationID: activationID,
      contentRevision: contentRevision,
      presentationRevision: presentationRevision
    ) else { return }
    setOverlaySuppressed(true)
    try installOverlayIfNeeded()
    if isNewActivation {
      activeLayoutGeneration = -1
      overlay.beginSession(activationID)
    }
    activeLayoutGeneration = layoutGeneration
    let geometry = WindowGeometry(
      sessionID: sessionID,
      activationID: activationID,
      layoutGeneration: layoutGeneration,
      presentationRevision: presentationRevision,
      revision: UInt64(geometryRevision),
      viewport: CGRect(
        x: viewportLeft, y: viewportTop,
        width: viewportWidth, height: viewportHeight
      ),
      scrollOffset: CGPoint(x: scrollOffsetX, y: scrollOffsetY)
    )
    applyGeometry(geometry)
    let descriptors = tiles.compactMap {
      descriptor(snapshot: $0)
    }
    overlay.apply(
      revision: UInt64(contentRevision),
      descriptors: descriptors
    )
  }

  func updateWindowGeometry(
    surfaceSessionId: Int64,
    activationId: Int64,
    layoutGeneration: Int64,
    presentationRevision: Int64,
    geometryRevision: Int64,
    viewportLeft: Double,
    viewportTop: Double,
    viewportWidth: Double,
    viewportHeight: Double,
    scrollOffsetX: Double,
    scrollOffsetY: Double
  ) throws {
    guard surfaceSessionId >= 0,
      activationId > 0,
      layoutGeneration >= 0,
      presentationRevision >= 0,
      geometryRevision >= 0
    else { return }
    let geometry = WindowGeometry(
      sessionID: UInt64(surfaceSessionId),
      activationID: UInt64(activationId),
      layoutGeneration: layoutGeneration,
      presentationRevision: presentationRevision,
      revision: UInt64(geometryRevision),
      viewport: CGRect(
        x: viewportLeft, y: viewportTop,
        width: viewportWidth, height: viewportHeight
      ),
      scrollOffset: CGPoint(x: scrollOffsetX, y: scrollOffsetY)
    )
    guard presentationFence.acceptsGeometry(
      surfaceSessionID: geometry.sessionID,
      activationID: geometry.activationID,
      presentationRevision: geometry.presentationRevision
    ), geometry.layoutGeneration == activeLayoutGeneration else { return }
    try installOverlayIfNeeded()
    applyGeometry(geometry)
  }

  func suspendWindow(
    surfaceSessionId: Int64,
    activationId: Int64,
    presentationRevision: Int64,
    completion: @escaping (Result<EdrPresentationAck, Error>) -> Void
  ) {
    let rejected = EdrPresentationAck(
      surfaceSessionId: surfaceSessionId,
      activationId: activationId,
      presentationRevision: presentationRevision,
      suppressed: false,
      outcome: .staleRejected,
      nativeGeneration: 0,
      presentedAtNanos: 0
    )
    guard surfaceSessionId >= 0,
      activationId > 0,
      presentationRevision >= 0,
      presentationFence.suspend(
        surfaceSessionID: UInt64(surfaceSessionId),
        activationID: UInt64(activationId),
        presentationRevision: presentationRevision
      )
    else {
      logger.debug(
        "EDR exact suspend rejected session=\(surfaceSessionId, privacy: .public) activation=\(activationId, privacy: .public) presentation=\(presentationRevision, privacy: .public)"
      )
      completion(.success(rejected))
      return
    }
    let lease = EdrPresentationLease(
      surfaceSessionID: UInt64(surfaceSessionId),
      activationID: UInt64(activationId),
      contentRevision: presentationFence.activeContentRevision,
      presentationRevision: presentationRevision
    )
    if !nativeMayPaint {
      setOverlaySuppressed(true)
      completion(
        .success(
          EdrPresentationAck(
            surfaceSessionId: surfaceSessionId,
            activationId: activationId,
            presentationRevision: presentationRevision,
            suppressed: true,
            outcome: .neverPresentedFlutterOnly,
            nativeGeneration: 0,
            presentedAtNanos: 0
          )
        )
      )
      return
    }
    setOverlaySuppressed(true)
    let generation = structuralPlane.detachIfCurrent { [weak self] in
      self?.presentationFence.confirmsSuppression(lease) == true
    }
    let confirmed = generation != nil
      && presentationFence.confirmsSuppression(lease)
    if confirmed { nativeMayPaint = false }
    logger.notice(
      "EDR exact structural suspend session=\(surfaceSessionId, privacy: .public) activation=\(activationId, privacy: .public) presentation=\(presentationRevision, privacy: .public) generation=\(generation ?? 0, privacy: .public) confirmed=\(confirmed, privacy: .public)"
    )
    completion(
      .success(
        EdrPresentationAck(
          surfaceSessionId: surfaceSessionId,
          activationId: activationId,
          presentationRevision: presentationRevision,
          suppressed: confirmed,
          outcome: confirmed ? .structurallyDetached : .failed,
          nativeGeneration: generation ?? 0,
          presentedAtNanos: 0
        )
      )
    )
  }

  func clearWindow(
    surfaceSessionId: Int64,
    activationId: Int64,
    contentRevision: Int64
  ) throws {
    guard surfaceSessionId >= 0,
      activationId > 0,
      contentRevision >= 0,
      presentationFence.clear(
        surfaceSessionID: UInt64(surfaceSessionId),
        activationID: UInt64(activationId),
        contentRevision: contentRevision
      )
    else { return }
    setOverlaySuppressed(true)
    overlay.clear(revision: UInt64(contentRevision))
    viewportMask.path = nil
    activeLayoutGeneration = -1
  }

  private func installOverlayIfNeeded() throws {
    guard let window = activeWindow else {
      throw EdrWindowRuntimeError.windowUnavailable
    }
    guard overlay.superview !== window else { return }
    overlay.install(in: window)
    viewportMask.frame = overlay.bounds
    overlay.layer.mask = viewportMask
  }

  private func updateViewportMask(_ viewport: CGRect) {
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    viewportMask.frame = overlay.bounds
    viewportMask.path = CGPath(rect: viewport, transform: nil)
    CATransaction.commit()
  }

  private func descriptor(snapshot: EdrTileSnapshot) -> VisualTileDescriptor? {
    let frame = CGRect(
      x: snapshot.left,
      y: snapshot.top,
      width: snapshot.width,
      height: snapshot.height
    )
    guard frame.origin.x.isFinite,
      frame.origin.y.isFinite,
      frame.width.isFinite,
      frame.height.isFinite,
      frame.width > 0,
      frame.height > 0
    else { return nil }

    let contentScale = min(1, max(0, CGFloat(snapshot.height) / 98))
    return VisualTileDescriptor(
      stableID: snapshot.roomId,
      frame: frame,
      cornerRadius: snapshot.cornerRadius,
      baseColor: VisualRuntimeColor(
        argb: UInt32(truncatingIfNeeded: snapshot.baseColorArgb)
      ),
      labels: VisualRuntimeLabels(
        primaryText: snapshot.roomId,
        secondaryText: snapshot.timeText,
        verticalGap: 6 * contentScale,
        contentInsets: VisualRuntimeInsets(
          top: 10 * contentScale,
          leading: 4,
          bottom: 10 * contentScale,
          trailing: 4
        )
      ),
      effectSeed: stableSeed(snapshot.roomId),
      highDynamicRangeEnabled: snapshot.vipHdrEnabled,
      jelly: snapshot.vipJellyEnabled
        ? VisualRuntimeJelly(speed: snapshot.vipJellySpeed)
        : nil,
      pulse: pulse(snapshot),
      lod: .full
    )
  }

  private func applyGeometry(_ geometry: WindowGeometry) {
    updateViewportMask(geometry.viewport)
    overlay.updateGeometry(
      revision: geometry.revision,
      translation: CGPoint(
        x: geometry.viewport.minX - geometry.scrollOffset.x,
        y: geometry.viewport.minY - geometry.scrollOffset.y
      )
    )
  }

  private func setOverlaySuppressed(
    _ suppressed: Bool
  ) {
    let updates = { [viewportMask = self.viewportMask, overlay = self.overlay] in
      if suppressed {
        viewportMask.path = nil
      }
      overlay.layer.opacity = suppressed ? 0 : 1
    }
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    updates()
    CATransaction.commit()
  }

  private func pulse(_ snapshot: EdrTileSnapshot) -> VisualRuntimePulse? {
    guard let generation = snapshot.pulseGeneration,
      generation >= 0,
      let color = snapshot.pulseColorArgb,
      let additiveColor = snapshot.pulseBoostColorArgb,
      let startedAtMicros = snapshot.pulseStartedAtMicros
    else { return nil }
    return VisualRuntimePulse(
      generation: UInt64(generation),
      startedAt: Date(
        timeIntervalSince1970: Double(startedAtMicros) / 1_000_000
      ),
      color: VisualRuntimeColor(argb: UInt32(truncatingIfNeeded: color)),
      additiveColor: VisualRuntimeColor(
        argb: UInt32(truncatingIfNeeded: additiveColor)
      ),
      springIntensity: snapshot.springIntensity
    )
  }

  private func stableSeed(_ value: String) -> Double {
    var hash: UInt32 = 2_166_136_261
    for byte in value.utf8 {
      hash ^= UInt32(byte)
      hash = hash &* 16_777_619
    }
    return Double(hash & 0xFFFF) / Double(0xFFFF)
  }

  private var activeWindow: UIWindow? {
    UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap(\.windows)
      .first { $0.isKeyWindow }
  }
}

private struct WindowGeometry {
  let sessionID: UInt64
  let activationID: UInt64
  let layoutGeneration: Int64
  let presentationRevision: Int64
  let revision: UInt64
  let viewport: CGRect
  let scrollOffset: CGPoint
}

struct EdrPresentationLease: Equatable {
  let surfaceSessionID: UInt64
  let activationID: UInt64
  let contentRevision: Int64
  let presentationRevision: Int64
}

struct EdrPresentationFence {
  private(set) var activeSessionID: UInt64?
  private(set) var activeActivationID: UInt64?
  private(set) var activeContentRevision: Int64 = -1
  private(set) var activePresentationRevision: Int64 = -1
  private(set) var highestActivationID: UInt64 = 0
  private(set) var suppressed = true
  private var awaitingCommit: EdrPresentationLease?
  private var awaitingFlutterReady: EdrPresentationLease?

  mutating func acceptConfiguration(
    surfaceSessionID: UInt64,
    activationID: UInt64,
    contentRevision: Int64,
    presentationRevision: Int64
  ) -> Bool {
    guard activationID > 0,
      contentRevision >= 0,
      presentationRevision >= 0,
      activationID >= highestActivationID
    else { return false }
    if activationID == highestActivationID {
      guard activeSessionID == surfaceSessionID,
        activeActivationID == activationID
      else { return false }
      if contentRevision == activeContentRevision,
        presentationRevision == activePresentationRevision
      {
        return suppressed
      }
    } else {
      highestActivationID = activationID
      activeSessionID = surfaceSessionID
      activeActivationID = activationID
      activeContentRevision = -1
      activePresentationRevision = -1
      awaitingCommit = nil
      awaitingFlutterReady = nil
    }
    guard contentRevision >= activeContentRevision,
      presentationRevision >= activePresentationRevision
    else { return false }
    activeContentRevision = contentRevision
    activePresentationRevision = presentationRevision
    suppressed = true
    awaitingCommit = currentLease
    awaitingFlutterReady = nil
    return true
  }

  mutating func suspend(
    surfaceSessionID: UInt64,
    activationID: UInt64,
    presentationRevision: Int64
  ) -> Bool {
    guard activeSessionID == surfaceSessionID,
      activeActivationID == activationID,
      presentationRevision >= activePresentationRevision
    else { return false }
    activePresentationRevision = presentationRevision
    awaitingCommit = nil
    awaitingFlutterReady = nil
    suppressed = true
    return true
  }

  func acceptsGeometry(
    surfaceSessionID: UInt64,
    activationID: UInt64,
    presentationRevision: Int64
  ) -> Bool {
    activeSessionID == surfaceSessionID
      && activeActivationID == activationID
      && activePresentationRevision == presentationRevision
  }

  mutating func prepareFrameCommit(
    contentRevision: Int64
  ) -> EdrPresentationLease? {
    guard let lease = awaitingCommit,
      lease == currentLease,
      lease.contentRevision == contentRevision
    else { return nil }
    self.awaitingCommit = nil
    awaitingFlutterReady = lease
    return lease
  }

  mutating func acknowledgeFlutterReady(
    _ lease: EdrPresentationLease
  ) -> Bool {
    guard suppressed,
      awaitingFlutterReady == lease,
      currentLease == lease
    else { return false }
    awaitingFlutterReady = nil
    suppressed = false
    return true
  }

  func confirmsSuppression(_ lease: EdrPresentationLease) -> Bool {
    suppressed && currentLease == lease
  }

  mutating func clear(
    surfaceSessionID: UInt64,
    activationID: UInt64,
    contentRevision: Int64
  ) -> Bool {
    guard activeSessionID == surfaceSessionID,
      activeActivationID == activationID,
      contentRevision >= activeContentRevision
    else { return false }
    activeSessionID = nil
    activeActivationID = nil
    activeContentRevision = -1
    activePresentationRevision = -1
    awaitingCommit = nil
    awaitingFlutterReady = nil
    suppressed = true
    return true
  }

  private var currentLease: EdrPresentationLease? {
    guard let activeSessionID, let activeActivationID else { return nil }
    return EdrPresentationLease(
      surfaceSessionID: activeSessionID,
      activationID: activeActivationID,
      contentRevision: activeContentRevision,
      presentationRevision: activePresentationRevision
    )
  }
}

private enum EdrWindowRuntimeError: LocalizedError {
  case windowUnavailable

  var errorDescription: String? {
    "Оконный EDR runtime пока не получил активное UIWindow"
  }
}
