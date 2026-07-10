import 'package:flutter/foundation.dart';

@immutable
final class VisualFramePolicy {
  const VisualFramePolicy({
    required this.maxFramesPerSecond,
    this.enabled = true,
  }) : assert(maxFramesPerSecond > 0);

  final int maxFramesPerSecond;
  final bool enabled;

  Duration get minimumFrameInterval {
    return Duration(microseconds: 1000000 ~/ maxFramesPerSecond);
  }
}

final class VisualFrameClock extends ChangeNotifier {
  VisualFrameClock({required VisualFramePolicy policy, DateTime? startedAt})
    : _policy = policy,
      _now = startedAt ?? DateTime.now(),
      _lastPublishedAt = startedAt ?? DateTime.now();

  VisualFramePolicy _policy;
  DateTime _now;
  DateTime _lastPublishedAt;

  VisualFramePolicy get policy => _policy;
  DateTime get now => _now;
  double get seconds => _now.microsecondsSinceEpoch / 1000000;

  void updatePolicy(VisualFramePolicy policy) {
    _policy = policy;
  }

  bool publish(DateTime nextFrameAt) {
    if (!_policy.enabled) return false;
    final elapsed = nextFrameAt.difference(_lastPublishedAt);
    if (!elapsed.isNegative && elapsed < _policy.minimumFrameInterval) {
      return false;
    }
    _now = nextFrameAt;
    _lastPublishedAt = nextFrameAt;
    notifyListeners();
    return true;
  }
}
