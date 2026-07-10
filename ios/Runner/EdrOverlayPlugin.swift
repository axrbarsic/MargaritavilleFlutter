import Flutter
import UIKit

enum EdrViewportPlugin {
  static let viewType = "margaritaville/edr-viewport"

  static func register(with registrar: FlutterPluginRegistrar) {
    let registry = EdrViewportViewRegistry.shared
    registrar.register(
      EdrViewportViewFactory(registry: registry),
      withId: viewType
    )
    EdrOverlayHostApiSetup.setUp(
      binaryMessenger: registrar.messenger(),
      api: EdrOverlayHostApiImplementation(registry: registry)
    )
  }
}

private final class EdrOverlayHostApiImplementation: EdrOverlayHostApi {
  init(registry: EdrViewportViewRegistry) {
    self.registry = registry
  }

  private let registry: EdrViewportViewRegistry

  func configureViewport(
    viewId: Int64,
    revision: Int64,
    scrollOffset: Double,
    tiles: [EdrTileSnapshot]
  ) throws {
    onMain {
      self.registry.view(viewId)?.configure(
        revision: revision,
        scrollOffset: scrollOffset,
        snapshots: tiles
      )
    }
  }

  func updateScrollOffset(
    viewId: Int64,
    revision: Int64,
    sequence: Int64,
    scrollOffset: Double
  ) throws {
    onMain {
      self.registry.view(viewId)?.updateScrollOffset(
        revision: revision,
        sequence: sequence,
        scrollOffset: scrollOffset
      )
    }
  }

  func clearViewport(viewId: Int64, revision: Int64) throws {
    onMain { self.registry.view(viewId)?.clear(revision: revision) }
  }

  private func onMain(_ operation: @escaping () -> Void) {
    if Thread.isMainThread {
      operation()
    } else {
      DispatchQueue.main.sync(execute: operation)
    }
  }
}

private final class EdrViewportViewFactory: NSObject, FlutterPlatformViewFactory {
  init(registry: EdrViewportViewRegistry) {
    self.registry = registry
  }

  private let registry: EdrViewportViewRegistry

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    EdrViewportPlatformView(frame: frame, viewId: viewId, registry: registry)
  }
}

private final class EdrViewportPlatformView: NSObject, FlutterPlatformView {
  init(frame: CGRect, viewId: Int64, registry: EdrViewportViewRegistry) {
    self.rootView = EdrViewportRootView(frame: frame)
    self.viewId = viewId
    self.registry = registry
    super.init()
    registry.insert(rootView, for: viewId)
  }

  private let rootView: EdrViewportRootView
  private let viewId: Int64
  private let registry: EdrViewportViewRegistry

  func view() -> UIView { rootView }

  deinit {
    registry.remove(viewId)
  }
}

private final class WeakEdrViewportView {
  weak var value: EdrViewportRootView?

  init(_ value: EdrViewportRootView) {
    self.value = value
  }
}

private final class EdrViewportViewRegistry {
  static let shared = EdrViewportViewRegistry()

  private var views: [Int64: WeakEdrViewportView] = [:]

  func insert(_ view: EdrViewportRootView, for viewId: Int64) {
    views[viewId] = WeakEdrViewportView(view)
  }

  func view(_ viewId: Int64) -> EdrViewportRootView? {
    views[viewId]?.value
  }

  func remove(_ viewId: Int64) {
    views.removeValue(forKey: viewId)
  }
}

private final class EdrViewportRootView: UIView {
  private struct PendingScroll {
    let revision: Int64
    let sequence: Int64
    let offset: Double
  }

  private var tiles: [String: EdrTileView] = [:]
  private let tileContainer = UIView(frame: .zero)
  private var activationObserver: NSObjectProtocol?
  private var layoutRevision: Int64 = -1
  private var scrollSequence: Int64 = -1
  private var anchorScrollOffset = 0.0
  private var currentScrollOffset = 0.0
  private var pendingScroll: PendingScroll?

  override init(frame: CGRect) {
    super.init(frame: frame)
    isOpaque = false
    isUserInteractionEnabled = false
    backgroundColor = .clear
    clipsToBounds = true
    tileContainer.isOpaque = false
    tileContainer.isUserInteractionEnabled = false
    tileContainer.backgroundColor = .clear
    tileContainer.clipsToBounds = false
    addSubview(tileContainer)
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

  override func layoutSubviews() {
    super.layoutSubviews()
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    tileContainer.layer.bounds = bounds
    tileContainer.layer.position = CGPoint(x: bounds.midX, y: bounds.midY)
    applyScrollTransform()
    CATransaction.commit()
  }

  func configure(
    revision: Int64,
    scrollOffset: Double,
    snapshots: [EdrTileSnapshot]
  ) {
    guard revision >= layoutRevision else { return }
    layoutRevision = revision
    anchorScrollOffset = scrollOffset
    currentScrollOffset = scrollOffset
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
      tileContainer.bringSubviewToFront(tile)
    }
    if let pendingScroll, pendingScroll.revision == revision {
      self.pendingScroll = nil
      applyScroll(
        sequence: pendingScroll.sequence,
        scrollOffset: pendingScroll.offset
      )
    } else {
      if let pendingScroll, pendingScroll.revision < revision {
        self.pendingScroll = nil
      }
      CATransaction.begin()
      CATransaction.setDisableActions(true)
      applyScrollTransform()
      CATransaction.commit()
    }
  }

  func updateScrollOffset(
    revision: Int64,
    sequence: Int64,
    scrollOffset: Double
  ) {
    guard revision >= layoutRevision, sequence > scrollSequence else { return }
    guard revision == layoutRevision else {
      if pendingScroll == nil || sequence > pendingScroll!.sequence {
        pendingScroll = PendingScroll(
          revision: revision,
          sequence: sequence,
          offset: scrollOffset
        )
      }
      return
    }
    applyScroll(sequence: sequence, scrollOffset: scrollOffset)
  }

  func clear(revision: Int64) {
    guard revision >= layoutRevision else { return }
    layoutRevision = revision
    tiles.values.forEach { $0.removeFromSuperview() }
    tiles.removeAll()
    pendingScroll = nil
  }

  private func makeTile(_ roomId: String) -> EdrTileView {
    let tile = EdrTileView(frame: .zero, seed: stableSeed(roomId))
    tileContainer.addSubview(tile)
    tiles[roomId] = tile
    return tile
  }

  private func applyScroll(sequence: Int64, scrollOffset: Double) {
    scrollSequence = sequence
    currentScrollOffset = scrollOffset
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    applyScrollTransform()
    CATransaction.commit()
  }

  private func applyScrollTransform() {
    let translation = anchorScrollOffset - currentScrollOffset
    tileContainer.layer.setAffineTransform(
      CGAffineTransform(translationX: 0, y: translation)
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
}
