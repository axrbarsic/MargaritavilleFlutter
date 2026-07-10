import QuartzCore
import UIKit

struct EdrRGB: Equatable {
  let red: CGFloat
  let green: CGFloat
  let blue: CGFloat

  init(argb: Int64) {
    let value = UInt64(bitPattern: argb)
    red = CGFloat((value >> 16) & 0xFF) / 255
    green = CGFloat((value >> 8) & 0xFF) / 255
    blue = CGFloat(value & 0xFF) / 255
  }

  var uiColor: UIColor {
    UIColor(red: red, green: green, blue: blue, alpha: 1)
  }
}

final class EdrFillView: UIView {
  var intensity: CGFloat = 1 {
    didSet { if oldValue != intensity { setNeedsDisplay() } }
  }

  var statusComponents = EdrRGB(argb: 0xFF00E524) {
    didSet { if oldValue != statusComponents { setNeedsDisplay() } }
  }

  var seed: Double = 0 {
    didSet { if oldValue != seed { setNeedsDisplay() } }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    isOpaque = false
    isUserInteractionEnabled = false
    backgroundColor = .clear
    contentMode = .redraw
    layer.contentsScale = UIScreen.main.scale
    layer.contentsFormat = .RGBA16Float
    layer.drawsAsynchronously = true
    configureDynamicRange()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    nil
  }

  override func draw(_ rect: CGRect) {
    guard let context = UIGraphicsGetCurrentContext(), !bounds.isEmpty else { return }
    configureDynamicRange()
    if #available(iOS 18.0, *) {
      _ = context.setEDRTargetHeadroom(Float(targetHeadroom))
    }
    context.clear(rect)
    context.setFillColor(extendedStatusColor(alpha: 1))
    context.fill(rect)
    drawSameColorLift(in: rect, context: context)
  }

  private var targetHeadroom: CGFloat {
    let base = min(max(UIScreen.main.potentialEDRHeadroom, 1.65), 4)
    return min(base * max(intensity, 1), 8)
  }

  private func configureDynamicRange() {
    if #available(iOS 26.0, *) {
      layer.preferredDynamicRange = .high
      layer.contentsHeadroom = targetHeadroom
    } else if #available(iOS 17.0, *) {
      layer.wantsExtendedDynamicRangeContent = true
    }
  }

  private func drawSameColorLift(in rect: CGRect, context: CGContext) {
    guard let gradient = CGGradient(
      colorsSpace: edrExtendedP3ColorSpace,
      colors: [
        extendedStatusColor(alpha: 0.34),
        extendedStatusColor(alpha: 0.10),
        extendedStatusColor(alpha: 0),
      ] as CFArray,
      locations: [0, 0.46, 1]
    ) else { return }

    let center = CGPoint(
      x: rect.minX + rect.width * CGFloat(0.30 + 0.08 * sin(seed * .pi * 2)),
      y: rect.minY + rect.height * 0.22
    )
    context.saveGState()
    context.setBlendMode(.plusLighter)
    context.drawRadialGradient(
      gradient,
      startCenter: center,
      startRadius: 0,
      endCenter: center,
      endRadius: max(rect.width, rect.height) * 0.90,
      options: [.drawsAfterEndLocation]
    )
    context.restoreGState()
  }

  private func extendedStatusColor(alpha: CGFloat) -> CGColor {
    let maximum = max(
      statusComponents.red,
      statusComponents.green,
      statusComponents.blue,
      0.001
    )
    let scale = targetHeadroom / maximum
    return CGColor(
      colorSpace: edrExtendedP3ColorSpace,
      components: [
        statusComponents.red * scale,
        statusComponents.green * scale,
        statusComponents.blue * scale,
        alpha,
      ]
    ) ?? UIColor.white.withAlphaComponent(alpha).cgColor
  }
}

private let edrExtendedP3ColorSpace =
  CGColorSpace(name: CGColorSpace.extendedLinearDisplayP3)
    ?? CGColorSpaceCreateDeviceRGB()
