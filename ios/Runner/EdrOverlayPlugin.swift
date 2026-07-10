import Flutter
import UIKit

enum EdrOverlayPlugin {
  static let viewType = "margaritaville/edr-overlay"

  static func register(with registrar: FlutterPluginRegistrar) {
    let registry = EdrOverlayViewRegistry.shared
    registrar.register(
      EdrOverlayViewFactory(registry: registry),
      withId: viewType
    )
    EdrOverlayHostApiSetup.setUp(
      binaryMessenger: registrar.messenger(),
      api: EdrOverlayHostApiImplementation(registry: registry)
    )
  }
}

private final class EdrOverlayHostApiImplementation: EdrOverlayHostApi {
  init(registry: EdrOverlayViewRegistry) {
    self.registry = registry
  }

  private let registry: EdrOverlayViewRegistry

  func updateTiles(viewId: Int64, tiles: [EdrTileSnapshot]) throws {
    onMain { self.registry.view(viewId)?.apply(tiles) }
  }

  func clearTiles(viewId: Int64) throws {
    onMain { self.registry.view(viewId)?.clear() }
  }

  private func onMain(_ operation: @escaping () -> Void) {
    if Thread.isMainThread {
      operation()
    } else {
      DispatchQueue.main.sync(execute: operation)
    }
  }
}

private final class EdrOverlayViewFactory: NSObject, FlutterPlatformViewFactory {
  init(registry: EdrOverlayViewRegistry) {
    self.registry = registry
  }

  private let registry: EdrOverlayViewRegistry

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    EdrOverlayPlatformView(frame: frame, viewId: viewId, registry: registry)
  }
}

private final class EdrOverlayPlatformView: NSObject, FlutterPlatformView {
  init(frame: CGRect, viewId: Int64, registry: EdrOverlayViewRegistry) {
    self.rootView = EdrOverlayRootView(frame: frame)
    self.viewId = viewId
    self.registry = registry
    super.init()
    registry.insert(rootView, for: viewId)
  }

  private let rootView: EdrOverlayRootView
  private let viewId: Int64
  private let registry: EdrOverlayViewRegistry

  func view() -> UIView { rootView }

  deinit {
    registry.remove(viewId)
  }
}

private final class WeakEdrOverlayView {
  weak var value: EdrOverlayRootView?

  init(_ value: EdrOverlayRootView) {
    self.value = value
  }
}

private final class EdrOverlayViewRegistry {
  static let shared = EdrOverlayViewRegistry()

  private var views: [Int64: WeakEdrOverlayView] = [:]

  func insert(_ view: EdrOverlayRootView, for viewId: Int64) {
    views[viewId] = WeakEdrOverlayView(view)
  }

  func view(_ viewId: Int64) -> EdrOverlayRootView? {
    views[viewId]?.value
  }

  func remove(_ viewId: Int64) {
    views.removeValue(forKey: viewId)
  }
}

private final class EdrOverlayRootView: UIView {
  private var tiles: [String: EdrTileView] = [:]
  private var activationObserver: NSObjectProtocol?

  override init(frame: CGRect) {
    super.init(frame: frame)
    isOpaque = false
    isUserInteractionEnabled = false
    backgroundColor = .clear
    clipsToBounds = false
    activationObserver = NotificationCenter.default.addObserver(
      forName: UIApplication.didBecomeActiveNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      self?.tiles.values.forEach { $0.resynchronizeEffects() }
    }
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    nil
  }

  deinit {
    if let activationObserver {
      NotificationCenter.default.removeObserver(activationObserver)
    }
  }

  func apply(_ snapshots: [EdrTileSnapshot]) {
    let activeIds = Set(snapshots.map(\.roomId))
    let staleIds = tiles.keys.filter { !activeIds.contains($0) }
    for roomId in staleIds {
      tiles.removeValue(forKey: roomId)?.removeFromSuperview()
    }
    for snapshot in snapshots {
      let tile = tiles[snapshot.roomId] ?? makeTile(snapshot.roomId)
      CATransaction.begin()
      CATransaction.setDisableActions(true)
      tile.frame = CGRect(
        x: snapshot.left,
        y: snapshot.top,
        width: snapshot.width,
        height: snapshot.height
      )
      CATransaction.commit()
      tile.apply(snapshot)
    }
  }

  func clear() {
    tiles.values.forEach { $0.removeFromSuperview() }
    tiles.removeAll()
  }

  private func makeTile(_ roomId: String) -> EdrTileView {
    let tile = EdrTileView(frame: .zero, seed: stableSeed(roomId))
    addSubview(tile)
    tiles[roomId] = tile
    return tile
  }

  private func stableSeed(_ value: String) -> Double {
    var hash: UInt32 = 2_166_136_261
    for byte in value.utf8 {
      hash ^= UInt32(byte)
      hash = hash &* 16_777_619
    }
    return Double(hash & 0xFFFF) / Double(0xFFFF)
  }
}
