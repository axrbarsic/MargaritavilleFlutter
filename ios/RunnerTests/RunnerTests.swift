import Flutter
@testable import Runner
import UIKit
import XCTest

class RunnerTests: XCTestCase {
  func testNativeEDRPulseUsesTheDonorTimeline() {
    XCTAssertEqual(EdrPulseAnimator.heatAt(0), 0, accuracy: 0.000_001)
    XCTAssertEqual(EdrPulseAnimator.heatAt(0.42), 1, accuracy: 0.000_001)
    XCTAssertEqual(EdrPulseAnimator.heatAt(0.58), 1, accuracy: 0.000_001)
    XCTAssertGreaterThan(EdrPulseAnimator.heatAt(1.58), 0)
    XCTAssertLessThan(EdrPulseAnimator.heatAt(1.58), 1)
    XCTAssertEqual(EdrPulseAnimator.heatAt(2.58), 0, accuracy: 0.000_001)
  }

  func testNativeVIPJellyMatchesBuild37GeometryVector() {
    let seed = 0.836_667_429_617_762
    let transform = EdrJellyGeometry.transform(
      at: 12.345,
      speed: 0.75,
      seed: seed
    )
    XCTAssertEqual(transform.scaleX, 0.999_635_608_798_942, accuracy: 0.000_000_001)
    XCTAssertEqual(transform.scaleY, 1.013_601_265_944_787, accuracy: 0.000_000_001)
    XCTAssertEqual(transform.offsetX, 1.192_474_575_720_754, accuracy: 0.000_000_001)
    XCTAssertEqual(transform.offsetY, 0.339_864_183_156_763, accuracy: 0.000_000_001)

    let path = EdrJellyGeometry.path(
      in: CGRect(x: 0, y: 0, width: 96, height: 98),
      at: 12.345,
      speed: 0.75,
      seed: seed,
      cornerRadius: 16
    )
    var firstPoint: CGPoint?
    path.applyWithBlock { elementPointer in
      let element = elementPointer.pointee
      if element.type == .moveToPoint {
        firstPoint = element.points[0]
      }
    }
    XCTAssertEqual(firstPoint?.x ?? 0, 11.52, accuracy: 0.000_000_001)
    XCTAssertEqual(firstPoint?.y ?? 0, -14.891_169_436_377_766, accuracy: 0.000_000_001)
  }
}
