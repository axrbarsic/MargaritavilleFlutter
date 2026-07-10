import 'dart:math' as math;

import 'package:flutter/gestures.dart';

abstract final class SummaryRoomGesturePolicy {
  static const holdDuration = Duration(milliseconds: 460);
  static const maximumHoldMovement = 8.0;
  static const minimumDragDistance = 28.0;
  static const maximumVerticalNoise = 10.0;
  static const minimumRightIntent = 38.0;
  static const leftResetDistance = -12.0;
  static const updateDominanceRatio = 2.8;
  static const finishDominanceRatio = 2.5;
  static const startFeedbackFraction = 0.86;
  static const warningFeedbackFraction = 0.94;

  static bool canRecognizeHorizontalDrag(Offset translation) {
    final absX = translation.dx.abs();
    final absY = translation.dy.abs();
    return translation.distance >= minimumDragDistance &&
        translation.dx > 0 &&
        absX > absY * updateDominanceRatio;
  }

  static bool shouldResetForAxis(Offset translation) {
    final absX = translation.dx.abs();
    final absY = translation.dy.abs();
    return absY > maximumVerticalNoise && absX <= absY * updateDominanceRatio;
  }

  static bool hasRightIntent(Offset translation) {
    final absX = translation.dx.abs();
    final absY = translation.dy.abs();
    return translation.dx > 0 &&
        absX >= minimumRightIntent &&
        absX > absY * updateDominanceRatio;
  }

  static bool canFinish(Offset translation) {
    return translation.dx > 0 &&
        translation.dx >
            math.max(translation.dy.abs() * finishDominanceRatio, 0);
  }
}
