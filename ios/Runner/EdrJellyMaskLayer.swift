import QuartzCore
import UIKit

private final class EdrJellyPathFrames: NSObject {
  init(values: [CGPath]) {
    self.values = values
  }

  let values: [CGPath]
}

final class EdrJellyMaskLayer: CAShapeLayer {

  var tileRect: CGRect = .zero
  var jellySpeed = 0.75
  var jellySeed = 0.0
  var jellyCornerRadius: CGFloat = 16
  private(set) var synchronizationCount = 0

  override init() {
    super.init()
    contentsScale = UIScreen.main.scale
    fillColor = UIColor.white.cgColor
    strokeColor = nil
  }

  override init(layer: Any) {
    super.init(layer: layer)
    guard let source = layer as? EdrJellyMaskLayer else { return }
    tileRect = source.tileRect
    jellySpeed = source.jellySpeed
    jellySeed = source.jellySeed
    jellyCornerRadius = source.jellyCornerRadius
    synchronizationCount = source.synchronizationCount
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    nil
  }

  func synchronize() {
    synchronizationCount += 1
    removeAnimation(forKey: Self.animationKey)
    guard !tileRect.isEmpty else {
      path = nil
      return
    }
    let paths = keyframePaths()
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    path = paths[0]
    CATransaction.commit()

    let animation = CAKeyframeAnimation(keyPath: "path")
    animation.values = paths
    animation.duration = Self.forwardDuration
    animation.calculationMode = .linear
    animation.autoreverses = true
    animation.repeatCount = .infinity
    animation.isRemovedOnCompletion = false
    animation.fillMode = .both
    let layerTime = convertTime(CACurrentMediaTime(), from: nil)
    let cycleDuration = Self.forwardDuration * 2
    animation.beginTime = layerTime
      - layerTime.truncatingRemainder(dividingBy: cycleDuration)
    add(animation, forKey: Self.animationKey)
  }

  func stop() {
    removeAnimation(forKey: Self.animationKey)
    path = nil
  }

  private func keyframePaths() -> [CGPath] {
    let sampleCount = Self.sampleCount(for: jellySpeed)
    let cacheKey = Self.cacheKey(
      rect: tileRect,
      speed: jellySpeed,
      seed: jellySeed,
      cornerRadius: jellyCornerRadius,
      sampleCount: sampleCount
    )
    if let cached = Self.pathCache.object(forKey: cacheKey) {
      return cached.values
    }
    let values = (0 ... sampleCount).map { index in
      let progress = Double(index) / Double(sampleCount)
      return EdrJellyGeometry.path(
        in: tileRect,
        at: Self.forwardDuration * progress,
        speed: jellySpeed,
        seed: jellySeed,
        cornerRadius: jellyCornerRadius
      )
    }
    Self.pathCache.setObject(
      EdrJellyPathFrames(values: values),
      forKey: cacheKey,
      cost: values.count * 4_096
    )
    return values
  }

  static func sampleCount(for speed: Double) -> Int {
    let normalizedSpeed = min(max(speed, 0.2), 2.5)
    let minimum = ceil(
      forwardDuration
        * 2
        * maximumTemporalCoefficient
        * normalizedSpeed
        * nyquistSafetyFactor
    )
    return max(12, Int(minimum))
  }

  private static func cacheKey(
    rect: CGRect,
    speed: Double,
    seed: Double,
    cornerRadius: CGFloat,
    sampleCount: Int
  ) -> NSString {
    let values: [UInt64] = [
      Double(rect.origin.x).bitPattern,
      Double(rect.origin.y).bitPattern,
      Double(rect.width).bitPattern,
      Double(rect.height).bitPattern,
      speed.bitPattern,
      seed.bitPattern,
      Double(cornerRadius).bitPattern,
      UInt64(sampleCount),
    ]
    return values.map(String.init).joined(separator: ":") as NSString
  }

  private static let pathCache: NSCache<NSString, EdrJellyPathFrames> = {
    let cache = NSCache<NSString, EdrJellyPathFrames>()
    cache.countLimit = 256
    cache.totalCostLimit = 32 * 1_024 * 1_024
    return cache
  }()

  static let forwardDuration: CFTimeInterval = 12
  static let animationKey = "margaritaville.edr.jelly.path"
  // The fastest term in EdrJellyGeometry.offset is
  // 0.61 + edge(7) * 0.017 = 0.729 cycles per normalized second.
  private static let maximumTemporalCoefficient = 0.729
  // Sample at 1.5 times the strict Nyquist minimum; Core Animation then
  // interpolates the equally structured CGPaths at the device refresh rate.
  private static let nyquistSafetyFactor = 1.5
}
