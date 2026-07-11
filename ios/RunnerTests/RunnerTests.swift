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

  func testPresentationFenceReleasesOnlyExactCommittedLease() {
    var fence = EdrPresentationFence()
    XCTAssertTrue(
      fence.acceptConfiguration(
        surfaceSessionID: 7,
        activationID: 11,
        contentRevision: 3,
        presentationRevision: 5
      )
    )
    XCTAssertTrue(fence.suppressed)
    XCTAssertNil(fence.commitFrame(contentRevision: 2))
    XCTAssertTrue(fence.suppressed)

    XCTAssertEqual(
      fence.commitFrame(contentRevision: 3),
      EdrPresentationLease(
        surfaceSessionID: 7,
        activationID: 11,
        contentRevision: 3,
        presentationRevision: 5
      )
    )
    XCTAssertFalse(fence.suppressed)
  }

  func testStaleSuspensionCannotHideNewActivation() {
    var fence = EdrPresentationFence()
    XCTAssertTrue(
      fence.acceptConfiguration(
        surfaceSessionID: 1,
        activationID: 1,
        contentRevision: 1,
        presentationRevision: 1
      )
    )
    XCTAssertNotNil(fence.commitFrame(contentRevision: 1))
    XCTAssertTrue(
      fence.acceptConfiguration(
        surfaceSessionID: 2,
        activationID: 2,
        contentRevision: 1,
        presentationRevision: 1
      )
    )

    XCTAssertFalse(
      fence.suspend(
        surfaceSessionID: 1,
        activationID: 1,
        presentationRevision: 99
      )
    )
    XCTAssertEqual(fence.activeActivationID, 2)
    XCTAssertEqual(fence.activePresentationRevision, 1)
  }

  func testSuspensionInvalidatesPendingFrameCommit() {
    var fence = EdrPresentationFence()
    XCTAssertTrue(
      fence.acceptConfiguration(
        surfaceSessionID: 4,
        activationID: 8,
        contentRevision: 10,
        presentationRevision: 2
      )
    )
    XCTAssertTrue(
      fence.suspend(
        surfaceSessionID: 4,
        activationID: 8,
        presentationRevision: 3
      )
    )

    XCTAssertNil(fence.commitFrame(contentRevision: 10))
    XCTAssertTrue(fence.suppressed)
  }

}
