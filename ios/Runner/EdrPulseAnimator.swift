import QuartzCore

enum EdrPulseAnimator {
  static let totalDuration: TimeInterval = 2.58
  private static let riseDuration: TimeInterval = 0.42
  private static let peakTime: TimeInterval = 0.58
  private static let fadeDuration: TimeInterval = 2.0
  private static let rubberMultiplier: CGFloat = 1.7
  private static let samplesPerSecond = 120.0

  static func animate(
    tileLayer: CALayer,
    pulseLayer: CALayer,
    startedAt: Date,
    springIntensity: CGFloat
  ) {
    let elapsed = max(0, Date().timeIntervalSince(startedAt))
    let remaining = totalDuration - elapsed
    tileLayer.removeAnimation(forKey: "margaritaville.edr.transform")
    pulseLayer.removeAnimation(forKey: "margaritaville.edr.opacity")
    pulseLayer.opacity = 0
    tileLayer.transform = CATransform3DIdentity
    guard remaining > 0 else { return }

    let sampleCount = max(2, Int(ceil(remaining * samplesPerSecond)) + 1)
    var times = [NSNumber]()
    var opacities = [NSNumber]()
    var transforms = [NSValue]()
    times.reserveCapacity(sampleCount)
    opacities.reserveCapacity(sampleCount)
    transforms.reserveCapacity(sampleCount)

    for index in 0..<sampleCount {
      let progress = Double(index) / Double(sampleCount - 1)
      let heat = heatAt(elapsed + remaining * progress)
      let rubber = CGFloat(heat) * rubberMultiplier
      let scale = 1 + 0.10 * springIntensity * rubber
      let offsetY = -7.5 * springIntensity * rubber
      var transform = CATransform3DMakeTranslation(0, offsetY, 0)
      transform = CATransform3DScale(transform, scale, scale, 1)
      times.append(NSNumber(value: progress))
      opacities.append(NSNumber(value: heat))
      transforms.append(NSValue(caTransform3D: transform))
    }

    let opacity = CAKeyframeAnimation(keyPath: "opacity")
    opacity.values = opacities
    opacity.keyTimes = times
    opacity.duration = remaining
    opacity.calculationMode = .linear
    pulseLayer.add(opacity, forKey: "margaritaville.edr.opacity")

    let transform = CAKeyframeAnimation(keyPath: "transform")
    transform.values = transforms
    transform.keyTimes = times
    transform.duration = remaining
    transform.calculationMode = .linear
    tileLayer.add(transform, forKey: "margaritaville.edr.transform")
  }

  static func heatAt(_ elapsed: TimeInterval) -> Double {
    guard elapsed > 0 else { return 0 }
    if elapsed < riseDuration {
      return smootherStep(elapsed / riseDuration)
    }
    if elapsed <= peakTime { return 1 }
    guard elapsed < totalDuration else { return 0 }
    let cooling = (elapsed - peakTime) / fadeDuration
    return pow(max(1 - smootherStep(cooling), 0), 0.7)
  }

  private static func smootherStep(_ rawValue: Double) -> Double {
    let value = min(max(rawValue, 0), 1)
    return value * value * value * (value * (value * 6 - 15) + 10)
  }
}
