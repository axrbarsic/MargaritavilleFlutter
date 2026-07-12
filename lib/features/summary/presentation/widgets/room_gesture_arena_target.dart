import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../summary_room_gesture_policy.dart';
import '../summary_swipe_commit_policy.dart';

final class RoomGestureArenaTarget extends StatefulWidget {
  const RoomGestureArenaTarget({
    required this.onHoldCommit,
    required this.onSwipeStart,
    required this.onSwipeWarning,
    required this.onSwipeCommit,
    required this.onOpenActions,
    required this.child,
    super.key,
  });

  final VoidCallback onHoldCommit;
  final VoidCallback onSwipeStart;
  final VoidCallback onSwipeWarning;
  final VoidCallback onSwipeCommit;
  final VoidCallback onOpenActions;
  final Widget child;

  @override
  State<RoomGestureArenaTarget> createState() => _RoomGestureArenaTargetState();
}

final class _RoomGestureArenaTargetState extends State<RoomGestureArenaTarget> {
  Offset? _swipeOrigin;
  var _translation = Offset.zero;
  var _armed = false;
  var _feedbackStarted = false;
  var _warningSent = false;
  var _commitSent = false;

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      behavior: HitTestBehavior.opaque,
      gestures: <Type, GestureRecognizerFactory>{
        LongPressGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
              () => LongPressGestureRecognizer(
                duration: SummaryRoomGesturePolicy.holdDuration,
                postAcceptSlopTolerance:
                    SummaryRoomGesturePolicy.maximumHoldMovement,
              ),
              (recognizer) {
                recognizer
                  ..gestureSettings = const DeviceGestureSettings(
                    touchSlop: SummaryRoomGesturePolicy.maximumHoldMovement,
                  )
                  ..onLongPress = widget.onHoldCommit;
              },
            ),
        _DonorHorizontalDragGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<
              _DonorHorizontalDragGestureRecognizer
            >(_DonorHorizontalDragGestureRecognizer.new, (recognizer) {
              recognizer
                ..gestureSettings = const DeviceGestureSettings(
                  touchSlop: SummaryRoomGesturePolicy.minimumDragDistance,
                )
                ..onlyAcceptDragOnThreshold = true
                ..dragStartBehavior = DragStartBehavior.down
                ..onStart = _startSwipe
                ..onUpdate = _updateSwipe
                ..onEnd = _finishSwipe
                ..onCancel = _cancelSwipe;
            }),
      },
      child: widget.child,
    );
  }

  void _startSwipe(DragStartDetails details) {
    _swipeOrigin = details.localPosition;
    _translation = Offset.zero;
    _resetFeedback();
  }

  void _updateSwipe(DragUpdateDetails details) {
    final origin = _swipeOrigin;
    if (origin == null) return;
    _translation = details.localPosition - origin;

    if (SummaryRoomGesturePolicy.shouldResetForAxis(_translation)) {
      _armed = false;
      return;
    }
    if (!SummaryRoomGesturePolicy.hasRightIntent(_translation)) {
      if (_translation.dx < SummaryRoomGesturePolicy.leftResetDistance) {
        _armed = false;
      }
      return;
    }

    final threshold = SummarySwipeCommitPolicy.compactThreshold(_cellWidth);
    final nextArmed = _translation.dx >= threshold;
    if (_translation.dx >=
            threshold * SummaryRoomGesturePolicy.startFeedbackFraction &&
        !_feedbackStarted) {
      _feedbackStarted = true;
      widget.onSwipeStart();
    }
    if (nextArmed && !_armed && !_commitSent) {
      _commitSent = true;
      widget.onSwipeCommit();
    } else if (!nextArmed &&
        _translation.dx >=
            threshold * SummaryRoomGesturePolicy.warningFeedbackFraction &&
        !_warningSent) {
      _warningSent = true;
      widget.onSwipeWarning();
    }
    _armed = nextArmed;
  }

  void _finishSwipe(DragEndDetails details) {
    final translation = _translation;
    final velocity = details.primaryVelocity ?? 0;
    final shouldOpen =
        SummaryRoomGesturePolicy.canFinish(translation) &&
        (_armed ||
            SummarySwipeCommitPolicy.compactArmed(
              translation: translation.dx,
              velocity: velocity,
              cellWidth: _cellWidth,
            ));
    _resetSwipe();
    if (shouldOpen) widget.onOpenActions();
  }

  void _cancelSwipe() => _resetSwipe();

  void _resetSwipe() {
    _swipeOrigin = null;
    _translation = Offset.zero;
    _resetFeedback();
  }

  void _resetFeedback() {
    _armed = false;
    _feedbackStarted = false;
    _warningSent = false;
    _commitSent = false;
  }

  double get _cellWidth => context.size?.width ?? 88;
}

final class _DonorHorizontalDragGestureRecognizer
    extends HorizontalDragGestureRecognizer {
  Offset? _origin;
  var _translation = Offset.zero;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    _origin ??= event.position;
    super.addAllowedPointer(event);
  }

  @override
  void handleEvent(PointerEvent event) {
    final origin = _origin;
    if (origin != null && event is PointerMoveEvent) {
      _translation = event.position - origin;
    }
    super.handleEvent(event);
  }

  @override
  bool hasSufficientGlobalDistanceToAccept(
    PointerDeviceKind pointerDeviceKind,
    double? deviceTouchSlop,
  ) {
    return SummaryRoomGesturePolicy.canRecognizeHorizontalDrag(_translation);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    super.didStopTrackingLastPointer(pointer);
    _origin = null;
    _translation = Offset.zero;
  }

  @override
  String get debugDescription => 'donor room horizontal drag';
}
