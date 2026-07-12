import 'package:flutter/gestures.dart';

final class TwoFingerScaleGestureRecognizer extends ScaleGestureRecognizer {
  @override
  void resolve(GestureDisposition disposition) {
    if (disposition == GestureDisposition.accepted && pointerCount < 2) return;
    super.resolve(disposition);
  }

  @override
  String get debugDescription => 'two finger room cell calibration scale';
}
