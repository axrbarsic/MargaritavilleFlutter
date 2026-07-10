import QuartzCore
import UIKit

final class EdrJellyMaskLayer: CALayer {
  @NSManaged var phase: CGFloat

  var tileRect: CGRect = .zero
  var jellySpeed = 0.75
  var jellySeed = 0.0
  var jellyCornerRadius: CGFloat = 16
  private var timeOrigin = Date().timeIntervalSince1970

  override init() {
    super.init()
    contentsScale = UIScreen.main.scale
    drawsAsynchronously = true
    phase = 0
  }

  override init(layer: Any) {
    super.init(layer: layer)
    guard let source = layer as? EdrJellyMaskLayer else { return }
    tileRect = source.tileRect
    jellySpeed = source.jellySpeed
    jellySeed = source.jellySeed
    jellyCornerRadius = source.jellyCornerRadius
    timeOrigin = source.timeOrigin
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    nil
  }

  override class func needsDisplay(forKey key: String) -> Bool {
    key == "phase" || super.needsDisplay(forKey: key)
  }

  override func draw(in context: CGContext) {
    guard !tileRect.isEmpty else { return }
    let time = timeOrigin + TimeInterval(phase)
    let path = EdrJellyGeometry.path(
      in: tileRect,
      at: time,
      speed: jellySpeed,
      seed: jellySeed,
      cornerRadius: jellyCornerRadius
    )
    context.clear(bounds)
    context.addPath(path)
    context.setFillColor(UIColor.white.cgColor)
    context.fillPath()
  }

  func synchronize() {
    removeAnimation(forKey: "margaritaville.edr.jelly.phase")
    timeOrigin = Date().timeIntervalSince1970
    phase = Self.cycleDuration
    let animation = CABasicAnimation(keyPath: "phase")
    animation.fromValue = CGFloat.zero
    animation.toValue = Self.cycleDuration
    animation.duration = CFTimeInterval(Self.cycleDuration)
    animation.repeatCount = .infinity
    animation.timingFunction = CAMediaTimingFunction(name: .linear)
    animation.isRemovedOnCompletion = false
    animation.fillMode = .both
    add(animation, forKey: "margaritaville.edr.jelly.phase")
  }

  func stop() {
    removeAnimation(forKey: "margaritaville.edr.jelly.phase")
    phase = 0
  }

  private static let cycleDuration: CGFloat = 86_400
}
