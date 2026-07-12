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
    XCTAssertNil(fence.prepareFrameCommit(contentRevision: 2))
    XCTAssertTrue(fence.suppressed)

    XCTAssertEqual(
      fence.prepareFrameCommit(contentRevision: 3),
      EdrPresentationLease(
        surfaceSessionID: 7,
        activationID: 11,
        contentRevision: 3,
        presentationRevision: 5
      )
    )
    XCTAssertTrue(fence.suppressed)
    XCTAssertTrue(
      fence.acknowledgeFlutterReady(
        EdrPresentationLease(
          surfaceSessionID: 7,
          activationID: 11,
          contentRevision: 3,
          presentationRevision: 5
        )
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
    let committed = fence.prepareFrameCommit(contentRevision: 1)
    XCTAssertNotNil(committed)
    XCTAssertTrue(fence.acknowledgeFlutterReady(committed!))
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

    XCTAssertNil(fence.prepareFrameCommit(contentRevision: 10))
    XCTAssertTrue(fence.suppressed)
  }

  func testLateFlutterReadyCannotRevealAfterSuspension() {
    var fence = EdrPresentationFence()
    XCTAssertTrue(
      fence.acceptConfiguration(
        surfaceSessionID: 9,
        activationID: 12,
        contentRevision: 4,
        presentationRevision: 6
      )
    )
    let ready = fence.prepareFrameCommit(contentRevision: 4)
    XCTAssertNotNil(ready)
    XCTAssertTrue(
      fence.suspend(
        surfaceSessionID: 9,
        activationID: 12,
        presentationRevision: 7
      )
    )
    XCTAssertFalse(fence.acknowledgeFlutterReady(ready!))
    XCTAssertTrue(fence.suppressed)
  }

  func testAcceptedOldSuspensionCannotMutateNewActivation() {
    var fence = EdrPresentationFence()
    XCTAssertTrue(
      fence.acceptConfiguration(
        surfaceSessionID: 10,
        activationID: 20,
        contentRevision: 30,
        presentationRevision: 40
      )
    )
    XCTAssertTrue(
      fence.suspend(
        surfaceSessionID: 10,
        activationID: 20,
        presentationRevision: 41
      )
    )
    let oldSuspension = EdrPresentationLease(
      surfaceSessionID: 10,
      activationID: 20,
      contentRevision: 30,
      presentationRevision: 41
    )
    XCTAssertTrue(fence.confirmsSuppression(oldSuspension))

    XCTAssertTrue(
      fence.acceptConfiguration(
        surfaceSessionID: 11,
        activationID: 21,
        contentRevision: 1,
        presentationRevision: 1
      )
    )
    XCTAssertFalse(fence.confirmsSuppression(oldSuspension))
  }

  @MainActor
  func testStructuralSuppressionDetachesOverlayExactlyOnce() {
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
    let root = UIView(frame: window.bounds)
    window.addSubview(root)
    let overlay = VisualRuntimeWindowOverlayView(frame: window.bounds)
    overlay.install(in: window, above: root)
    let plane = EdrStructuralOverlayPlane(overlay: overlay)

    XCTAssertTrue(overlay.superview === window)
    XCTAssertEqual(plane.detachIfCurrent { true }, 1)
    XCTAssertNil(overlay.superview)
    XCTAssertNil(plane.detachIfCurrent { false })
    XCTAssertEqual(plane.generation, 1)
  }

}
