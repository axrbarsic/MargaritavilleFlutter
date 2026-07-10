import SharedAppFoundation
@testable import Runner
import XCTest

final class RunnerTests: XCTestCase {
  func testRunnerLinksTheSharedBuild37VisualRuntimeContract() {
    XCTAssertEqual(VisualRuntimePulseTiming.heat(elapsed: 0), 0)
    XCTAssertEqual(
      VisualRuntimePulseTiming.heat(elapsed: 0.42),
      1,
      accuracy: 0.000_001
    )
    XCTAssertEqual(
      VisualRuntimePulseTiming.heat(elapsed: 0.58),
      1,
      accuracy: 0.000_001
    )
    XCTAssertEqual(VisualRuntimePulseTiming.heat(elapsed: 2.58), 0)
    XCTAssertEqual(VisualRuntimePulseTiming.scaleCoefficient, 0.09)
    XCTAssertEqual(VisualRuntimePulseTiming.verticalOffsetCoefficient, 7)
  }
}
