import QuartzCore
import UIKit

final class EdrTileView: UIView {
  init(frame: CGRect, seed: Double) {
    self.seed = seed
    super.init(frame: frame)
    isOpaque = false
    isUserInteractionEnabled = false
    layer.cornerCurve = .continuous
    backgroundColor = .clear
    clipsToBounds = false
    contentView.isUserInteractionEnabled = false
    contentView.layer.cornerCurve = .continuous
    vipFill.seed = seed
    pulseFill.seed = seed
    contentView.addSubview(vipFill)
    contentView.addSubview(pulseFill)
    addSubview(contentView)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    nil
  }

  private let seed: Double
  private let contentView = UIView(frame: .zero)
  private let vipFill = EdrFillView(frame: .zero)
  private let pulseFill = EdrFillView(frame: .zero)
  private let jellyMask = EdrJellyMaskLayer()
  private var snapshot: EdrTileSnapshot?
  private var pulseGeneration: Int64?
  private var jellyConfiguration: JellyConfiguration?

  override func layoutSubviews() {
    super.layoutSubviews()
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    contentView.layer.bounds = bounds
    contentView.layer.position = basePosition
    vipFill.frame = contentView.bounds
    pulseFill.frame = contentView.bounds
    jellyMask.frame = contentView.bounds
    jellyMask.tileRect = contentView.bounds
    CATransaction.commit()
    if let snapshot, snapshot.vipJellyEnabled {
      synchronizeJelly(snapshot, force: true)
    }
  }

  func apply(_ snapshot: EdrTileSnapshot, forcePulse: Bool = false) {
    self.snapshot = snapshot
    contentView.backgroundColor = EdrRGB(argb: snapshot.baseColorArgb).uiColor
    vipFill.statusComponents = EdrRGB(argb: snapshot.baseColorArgb)
    vipFill.intensity = 1
    vipFill.isHidden = !snapshot.vipHdrEnabled
    synchronizeJelly(snapshot, force: forcePulse)

    guard
      let generation = snapshot.pulseGeneration,
      let startedAtMicros = snapshot.pulseStartedAtMicros
    else {
      stopPulse()
      return
    }
    if let pulseColor = snapshot.pulseColorArgb {
      pulseFill.statusComponents = EdrRGB(argb: pulseColor)
      pulseFill.intensity = 2
      pulseFill.isHidden = false
    } else {
      pulseFill.isHidden = true
    }
    guard forcePulse || pulseGeneration != generation else { return }
    pulseGeneration = generation
    let startedAt = Date(
      timeIntervalSince1970: TimeInterval(startedAtMicros) / 1_000_000
    )
    EdrPulseAnimator.animate(
      tileLayer: layer,
      pulseLayer: pulseFill.layer,
      startedAt: startedAt,
      springIntensity: snapshot.springIntensity
    )
  }

  func resynchronizeEffects() {
    if let snapshot { apply(snapshot, forcePulse: true) }
  }

  private var basePosition: CGPoint {
    CGPoint(x: bounds.midX, y: bounds.midY)
  }

  private func synchronizeJelly(
    _ snapshot: EdrTileSnapshot,
    force: Bool
  ) {
    let next = JellyConfiguration(
      enabled: snapshot.vipJellyEnabled,
      speed: min(max(snapshot.vipJellySpeed, 0.2), 2.5),
      cornerRadius: snapshot.cornerRadius,
      size: bounds.size
    )
    guard force || jellyConfiguration != next else { return }
    jellyConfiguration = next

    guard next.enabled, !bounds.isEmpty else {
      jellyMask.stop()
      contentView.layer.mask = nil
      EdrJellyTransformAnimator.stop(
        layer: contentView.layer,
        basePosition: basePosition
      )
      contentView.layer.cornerRadius = snapshot.cornerRadius
      contentView.clipsToBounds = true
      return
    }

    clipsToBounds = false
    layer.cornerRadius = 0
    contentView.clipsToBounds = false
    contentView.layer.cornerRadius = 0
    jellyMask.frame = contentView.bounds
    jellyMask.tileRect = contentView.bounds
    jellyMask.jellySpeed = next.speed
    jellyMask.jellySeed = seed
    jellyMask.jellyCornerRadius = next.cornerRadius
    contentView.layer.mask = jellyMask
    jellyMask.synchronize()
    EdrJellyTransformAnimator.synchronize(
      layer: contentView.layer,
      basePosition: basePosition,
      speed: next.speed,
      seed: seed
    )
  }

  private func stopPulse() {
    pulseGeneration = nil
    layer.removeAnimation(forKey: "margaritaville.edr.transform")
    pulseFill.layer.removeAnimation(forKey: "margaritaville.edr.opacity")
    layer.transform = CATransform3DIdentity
    pulseFill.layer.opacity = 0
    pulseFill.isHidden = true
  }

  private struct JellyConfiguration: Equatable {
    let enabled: Bool
    let speed: Double
    let cornerRadius: CGFloat
    let size: CGSize
  }
}
