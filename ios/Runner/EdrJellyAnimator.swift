import QuartzCore
import UIKit

struct EdrJellyTransform: Equatable {
  let scaleX: CGFloat
  let scaleY: CGFloat
  let offsetX: CGFloat
  let offsetY: CGFloat
}

enum EdrJellyGeometry {
  static func transform(
    at time: TimeInterval,
    speed: Double,
    seed: Double
  ) -> EdrJellyTransform {
    let normalizedSpeed = min(max(speed, 0.2), 2.5)
    let phase = time * normalizedSpeed + seed * 11
    return EdrJellyTransform(
      scaleX: 1 + 0.012 * sin(phase * 1.7),
      scaleY: 1 + 0.018 * cos(phase * 1.4),
      offsetX: 1.2 * sin(phase * 1.1),
      offsetY: 0.8 * cos(phase * 1.3)
    )
  }

  static func path(
    in rect: CGRect,
    at time: TimeInterval,
    speed: Double,
    seed: Double,
    cornerRadius: CGFloat
  ) -> CGPath {
    let normalizedSpeed = min(max(speed, 0.2), 2.5)
    let phase = time * normalizedSpeed
    let amplitude = min(rect.height * 0.22, 18)
    let radius = min(cornerRadius, rect.height * 0.46, rect.width * 0.12)
    let left = rect.minX
    let right = rect.maxX
    let top = rect.minY
    let bottom = rect.maxY
    let path = UIBezierPath()

    path.move(
      to: CGPoint(
        x: left + radius,
        y: top + offset(
          edge: 0,
          unit: 0,
          time: phase,
          amplitude: amplitude,
          seed: seed
        )
      )
    )
    addHorizontalEdge(
      to: path,
      y: top,
      fromX: left + radius,
      toX: right - radius,
      edge: 0,
      time: phase,
      amplitude: amplitude,
      seed: seed
    )
    path.addQuadCurve(
      to: CGPoint(x: right, y: top + radius),
      controlPoint: CGPoint(
        x: right + offset(
          edge: 4,
          unit: 0.25,
          time: phase,
          amplitude: amplitude * 0.55,
          seed: seed
        ),
        y: top
      )
    )
    addVerticalEdge(
      to: path,
      x: right,
      fromY: top + radius,
      toY: bottom - radius,
      edge: 1,
      time: phase,
      amplitude: amplitude,
      seed: seed
    )
    path.addQuadCurve(
      to: CGPoint(x: right - radius, y: bottom),
      controlPoint: CGPoint(
        x: right,
        y: bottom + offset(
          edge: 5,
          unit: 0.75,
          time: phase,
          amplitude: amplitude * 0.55,
          seed: seed
        )
      )
    )
    addHorizontalEdge(
      to: path,
      y: bottom,
      fromX: right - radius,
      toX: left + radius,
      edge: 2,
      time: phase,
      amplitude: amplitude,
      seed: seed
    )
    path.addQuadCurve(
      to: CGPoint(x: left, y: bottom - radius),
      controlPoint: CGPoint(
        x: left + offset(
          edge: 6,
          unit: 0.35,
          time: phase,
          amplitude: amplitude * 0.55,
          seed: seed
        ),
        y: bottom
      )
    )
    addVerticalEdge(
      to: path,
      x: left,
      fromY: bottom - radius,
      toY: top + radius,
      edge: 3,
      time: phase,
      amplitude: amplitude,
      seed: seed
    )
    path.addQuadCurve(
      to: CGPoint(x: left + radius, y: top),
      controlPoint: CGPoint(
        x: left,
        y: top + offset(
          edge: 7,
          unit: 0.9,
          time: phase,
          amplitude: amplitude * 0.55,
          seed: seed
        )
      )
    )
    path.close()
    return path.cgPath
  }

  private static func addHorizontalEdge(
    to path: UIBezierPath,
    y: CGFloat,
    fromX: CGFloat,
    toX: CGFloat,
    edge: Int,
    time: Double,
    amplitude: CGFloat,
    seed: Double
  ) {
    let steps = 28
    let points = (0 ... steps).map { index in
      let unit = Double(index) / Double(steps)
      return CGPoint(
        x: fromX + (toX - fromX) * CGFloat(unit),
        y: y + offset(
          edge: edge,
          unit: unit,
          time: time,
          amplitude: amplitude,
          seed: seed
        )
      )
    }
    addSmoothEdge(to: path, points: points)
  }

  private static func addVerticalEdge(
    to path: UIBezierPath,
    x: CGFloat,
    fromY: CGFloat,
    toY: CGFloat,
    edge: Int,
    time: Double,
    amplitude: CGFloat,
    seed: Double
  ) {
    let steps = 12
    let points = (0 ... steps).map { index in
      let unit = Double(index) / Double(steps)
      return CGPoint(
        x: x + offset(
          edge: edge,
          unit: unit,
          time: time,
          amplitude: amplitude * 0.55,
          seed: seed
        ),
        y: fromY + (toY - fromY) * CGFloat(unit)
      )
    }
    addSmoothEdge(to: path, points: points)
  }

  private static func addSmoothEdge(
    to path: UIBezierPath,
    points: [CGPoint]
  ) {
    guard points.count > 1 else { return }
    for index in 0 ..< points.count - 1 {
      let previous = points[max(index - 1, 0)]
      let current = points[index]
      let next = points[index + 1]
      let afterNext = points[min(index + 2, points.count - 1)]
      path.addCurve(
        to: next,
        controlPoint1: CGPoint(
          x: current.x + (next.x - previous.x) / 6,
          y: current.y + (next.y - previous.y) / 6
        ),
        controlPoint2: CGPoint(
          x: next.x - (afterNext.x - current.x) / 6,
          y: next.y - (afterNext.y - current.y) / 6
        )
      )
    }
  }

  private static func offset(
    edge: Int,
    unit: Double,
    time: Double,
    amplitude: CGFloat,
    seed: Double
  ) -> CGFloat {
    let edgeSeed = seed * 19.37 + Double(edge) * 0.731
    let slow = sin(
      (unit * (1.7 + edgeSeed.truncatingRemainder(dividingBy: 1.9))
        + time * (0.31 + edgeSeed * 0.017) + edgeSeed) * .pi * 2
    )
    let medium = sin(
      (unit * (3.1 + edgeSeed.truncatingRemainder(dividingBy: 2.4))
        - time * (0.47 + seed * 0.09) + edgeSeed * 1.41) * .pi * 2
    )
    let fast = sin(
      (unit * (4.6 + seed * 1.7)
        + time * (0.61 + Double(edge) * 0.017) + edgeSeed * 2.17) * .pi * 2
    )
    let drift = sin((time * 0.113 + seed * 8 + Double(edge)) * .pi * 2)
    return CGFloat(slow * 0.52 + medium * 0.31 + fast * 0.11 + drift * 0.06)
      * amplitude
  }
}
