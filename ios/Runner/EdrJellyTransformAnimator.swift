import QuartzCore
import UIKit

enum EdrJellyTransformAnimator {
  static func synchronize(
    layer: CALayer,
    basePosition: CGPoint,
    speed: Double,
    seed: Double,
    at time: TimeInterval = Date().timeIntervalSince1970
  ) {
    stop(layer: layer)
    let normalizedSpeed = min(max(speed, 0.2), 2.5)
    let current = EdrJellyGeometry.transform(
      at: time,
      speed: normalizedSpeed,
      seed: seed
    )
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    layer.position = CGPoint(
      x: basePosition.x + current.offsetX,
      y: basePosition.y + current.offsetY
    )
    layer.setAffineTransform(
      CGAffineTransform(scaleX: current.scaleX, y: current.scaleY)
    )
    CATransaction.commit()

    addWave(
      to: layer,
      keyPath: "transform.scale.x",
      key: "margaritaville.edr.jelly.scale-x",
      base: 1,
      amplitude: 0.012,
      frequency: 1.7,
      usesCosine: false,
      speed: normalizedSpeed,
      seed: seed,
      time: time
    )
    addWave(
      to: layer,
      keyPath: "transform.scale.y",
      key: "margaritaville.edr.jelly.scale-y",
      base: 1,
      amplitude: 0.018,
      frequency: 1.4,
      usesCosine: true,
      speed: normalizedSpeed,
      seed: seed,
      time: time
    )
    addWave(
      to: layer,
      keyPath: "position.x",
      key: "margaritaville.edr.jelly.position-x",
      base: basePosition.x,
      amplitude: 1.2,
      frequency: 1.1,
      usesCosine: false,
      speed: normalizedSpeed,
      seed: seed,
      time: time
    )
    addWave(
      to: layer,
      keyPath: "position.y",
      key: "margaritaville.edr.jelly.position-y",
      base: basePosition.y,
      amplitude: 0.8,
      frequency: 1.3,
      usesCosine: true,
      speed: normalizedSpeed,
      seed: seed,
      time: time
    )
  }

  static func stop(layer: CALayer, basePosition: CGPoint? = nil) {
    animationKeys.forEach { layer.removeAnimation(forKey: $0) }
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    layer.setAffineTransform(.identity)
    if let basePosition { layer.position = basePosition }
    CATransaction.commit()
  }

  private static func addWave(
    to layer: CALayer,
    keyPath: String,
    key: String,
    base: CGFloat,
    amplitude: CGFloat,
    frequency: Double,
    usesCosine: Bool,
    speed: Double,
    seed: Double,
    time: TimeInterval
  ) {
    let period = 2 * Double.pi / (speed * frequency)
    let startAngle = (time * speed + seed * 11) * frequency
    let animation = CAKeyframeAnimation(keyPath: keyPath)
    animation.values = (0 ... sampleCount).map { index in
      let angle = startAngle + 2 * Double.pi * Double(index) / Double(sampleCount)
      let wave = usesCosine ? cos(angle) : sin(angle)
      return base + amplitude * CGFloat(wave)
    }
    animation.duration = period
    animation.repeatCount = .infinity
    animation.calculationMode = .linear
    animation.isRemovedOnCompletion = false
    animation.fillMode = .both
    layer.add(animation, forKey: key)
  }

  private static let sampleCount = 240
  private static let animationKeys = [
    "margaritaville.edr.jelly.scale-x",
    "margaritaville.edr.jelly.scale-y",
    "margaritaville.edr.jelly.position-x",
    "margaritaville.edr.jelly.position-y",
  ]
}
