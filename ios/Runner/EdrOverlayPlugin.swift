import Flutter
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

@MainActor
private final class EdrWindowRuntimeAdapter: @preconcurrency EdrOverlayHostApi {
  init(binaryMessenger: FlutterBinaryMessenger) {
    flutterApi = EdrOverlayFlutterApi(binaryMessenger: binaryMessenger)
    overlay.onFirstFrameReady = { [weak self] readiness in
      guard let self,
        let sessionID = self.activeSessionID,
        let activationID = self.activeActivationID,
        self.activeContentRevision == Int64(readiness.revision)
      else { return }
      self.flutterApi.windowReady(
        surfaceSessionId: Int64(sessionID),
        activationId: Int64(activationID),
        contentRevision: Int64(readiness.revision)
      ) { _ in }
    }
  }

  private let flutterApi: EdrOverlayFlutterApi
  private let overlay = VisualRuntimeWindowOverlayView(frame: .zero)
  private let viewportMask = CAShapeLayer()
  private var activeSessionID: UInt64?
  private var activeActivationID: UInt64?
  private var highestActivationID: UInt64 = 0
  private var activeLayoutGeneration: Int64 = -1
  private var activeContentRevision: Int64 = -1
  private var pendingGeometry: WindowGeometry?

  func configureWindow(
    surfaceSessionId: Int64,
    activationId: Int64,
    layoutGeneration: Int64,
    contentRevision: Int64,
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
      geometryRevision >= 0
    else { return }
    try installOverlayIfNeeded()
    let sessionID = UInt64(surfaceSessionId)
    let activationID = UInt64(activationId)
    guard activateSession(sessionID, activationID: activationID) else {
      return
    }
    guard layoutGeneration >= activeLayoutGeneration,
      contentRevision >= activeContentRevision
    else { return }
    activeLayoutGeneration = layoutGeneration
    activeContentRevision = contentRevision
    let suppliedGeometry = WindowGeometry(
      sessionID: sessionID,
      activationID: activationID,
      layoutGeneration: layoutGeneration,
      revision: UInt64(geometryRevision),
      viewport: CGRect(
        x: viewportLeft, y: viewportTop,
        width: viewportWidth, height: viewportHeight
      ),
      scrollOffset: CGPoint(x: scrollOffsetX, y: scrollOffsetY)
    )
    let matchingPendingGeometry = pendingGeometry.flatMap {
        $0.sessionID == sessionID
          && $0.activationID == activationID
          && $0.layoutGeneration == layoutGeneration
          && $0.revision > suppliedGeometry.revision ? $0 : nil
      }
    let geometry = matchingPendingGeometry ?? suppliedGeometry
    if pendingGeometry?.sessionID == sessionID,
      pendingGeometry?.activationID == activationID,
      pendingGeometry?.layoutGeneration == layoutGeneration
    {
      pendingGeometry = nil
    }
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
      geometryRevision >= 0
    else { return }
    let geometry = WindowGeometry(
      sessionID: UInt64(surfaceSessionId),
      activationID: UInt64(activationId),
      layoutGeneration: layoutGeneration,
      revision: UInt64(geometryRevision),
      viewport: CGRect(
        x: viewportLeft, y: viewportTop,
        width: viewportWidth, height: viewportHeight
      ),
      scrollOffset: CGPoint(x: scrollOffsetX, y: scrollOffsetY)
    )
    guard geometry.sessionID == activeSessionID,
      geometry.activationID == activeActivationID,
      geometry.layoutGeneration == activeLayoutGeneration
    else {
      storePendingGeometry(geometry)
      return
    }
    try installOverlayIfNeeded()
    applyGeometry(geometry)
  }

  func clearWindow(
    surfaceSessionId: Int64,
    activationId: Int64,
    contentRevision: Int64
  ) throws {
    guard surfaceSessionId >= 0,
      activationId > 0,
      contentRevision >= 0,
      UInt64(surfaceSessionId) == activeSessionID,
      UInt64(activationId) == activeActivationID,
      contentRevision >= activeContentRevision
    else { return }
    overlay.clear(revision: UInt64(contentRevision))
    viewportMask.path = nil
    if pendingGeometry?.activationID == activeActivationID {
      pendingGeometry = nil
    }
    activeSessionID = nil
    activeActivationID = nil
    activeLayoutGeneration = -1
    activeContentRevision = -1
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

    return VisualTileDescriptor(
      stableID: snapshot.roomId,
      frame: frame,
      cornerRadius: snapshot.cornerRadius,
      baseColor: VisualRuntimeColor(
        argb: UInt32(truncatingIfNeeded: snapshot.baseColorArgb)
      ),
      labels: VisualRuntimeLabels(
        primaryText: snapshot.roomId,
        secondaryText: snapshot.timeText
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

  private func activateSession(
    _ sessionID: UInt64,
    activationID: UInt64
  ) -> Bool {
    guard activationID >= highestActivationID else { return false }
    if activationID == highestActivationID {
      return activeSessionID == sessionID
        && activeActivationID == activationID
    }
    highestActivationID = activationID
    activeSessionID = sessionID
    activeActivationID = activationID
    activeLayoutGeneration = -1
    activeContentRevision = -1
    overlay.beginSession(activationID)
    return true
  }

  private func storePendingGeometry(_ geometry: WindowGeometry) {
    let belongsToActiveLease =
      geometry.sessionID == activeSessionID
      && geometry.activationID == activeActivationID
      && geometry.layoutGeneration > activeLayoutGeneration
    guard geometry.activationID > highestActivationID
      || belongsToActiveLease
    else { return }
    if let pendingGeometry {
      let existingOrder = (
        pendingGeometry.activationID,
        pendingGeometry.layoutGeneration,
        pendingGeometry.revision
      )
      let nextOrder = (
        geometry.activationID,
        geometry.layoutGeneration,
        geometry.revision
      )
      guard nextOrder > existingOrder else { return }
    }
    pendingGeometry = geometry
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
  let revision: UInt64
  let viewport: CGRect
  let scrollOffset: CGPoint
}

private enum EdrWindowRuntimeError: LocalizedError {
  case windowUnavailable

  var errorDescription: String? {
    "Оконный EDR runtime пока не получил активное UIWindow"
  }
}
