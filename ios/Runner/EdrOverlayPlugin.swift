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
      self?.flutterApi.windowReady(revision: Int64(readiness.revision)) { _ in }
    }
  }

  private let flutterApi: EdrOverlayFlutterApi
  private let overlay = VisualRuntimeWindowOverlayView(frame: .zero)
  private let viewportMask = CAShapeLayer()

  func configureWindow(
    revision: Int64,
    viewportLeft: Double,
    viewportTop: Double,
    viewportWidth: Double,
    viewportHeight: Double,
    tiles: [EdrTileSnapshot]
  ) throws {
    guard revision >= 0 else { return }
    try installOverlayIfNeeded()
    let viewportOrigin = CGPoint(x: viewportLeft, y: viewportTop)
    updateViewportMask(
      CGRect(
        x: viewportLeft,
        y: viewportTop,
        width: viewportWidth,
        height: viewportHeight
      )
    )
    let descriptors = tiles.compactMap {
      descriptor(snapshot: $0, viewportOrigin: viewportOrigin)
    }
    overlay.apply(revision: UInt64(revision), descriptors: descriptors)
  }

  func clearWindow(revision: Int64) throws {
    guard revision >= 0 else { return }
    overlay.clear(revision: UInt64(revision))
    viewportMask.path = nil
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

  private func descriptor(
    snapshot: EdrTileSnapshot,
    viewportOrigin: CGPoint
  ) -> VisualTileDescriptor? {
    let frame = CGRect(
      x: viewportOrigin.x + snapshot.left,
      y: viewportOrigin.y + snapshot.top,
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

private enum EdrWindowRuntimeError: LocalizedError {
  case windowUnavailable

  var errorDescription: String? {
    "Оконный EDR runtime пока не получил активное UIWindow"
  }
}
