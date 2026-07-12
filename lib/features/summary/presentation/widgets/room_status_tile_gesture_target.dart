import 'package:flutter/widgets.dart';

import 'room_gesture_arena_target.dart';

final class RoomStatusTileGestureTarget extends StatelessWidget {
  const RoomStatusTileGestureTarget({
    required this.roomNumber,
    required this.onHoldCommit,
    required this.onSwipeStart,
    required this.onSwipeWarning,
    required this.onSwipeCommit,
    required this.onOpenActions,
    required this.child,
    this.calibrationGesture,
    super.key,
  });

  final String roomNumber;
  final VoidCallback onHoldCommit;
  final VoidCallback onSwipeStart;
  final VoidCallback onSwipeWarning;
  final VoidCallback onSwipeCommit;
  final VoidCallback onOpenActions;
  final Widget child;
  final RoomCellCalibrationGesture? calibrationGesture;

  @override
  Widget build(BuildContext context) {
    final calibration = calibrationGesture;
    if (calibration != null) {
      return KeyedSubtree(
        key: Key('summary-room-$roomNumber'),
        child: RawGestureDetector(
          behavior: HitTestBehavior.opaque,
          gestures: calibration.gestures,
          child: child,
        ),
      );
    }
    return RoomGestureArenaTarget(
      key: Key('summary-room-$roomNumber'),
      onHoldCommit: onHoldCommit,
      onSwipeStart: onSwipeStart,
      onSwipeWarning: onSwipeWarning,
      onSwipeCommit: onSwipeCommit,
      onOpenActions: onOpenActions,
      child: child,
    );
  }
}

final class RoomCellCalibrationGesture {
  const RoomCellCalibrationGesture(this.gestures);

  final Map<Type, GestureRecognizerFactory> gestures;
}
