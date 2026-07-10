import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../work_session/domain/models/room_state.dart';

@immutable
final class SummaryVisualPulseEvent {
  const SummaryVisualPulseEvent({
    required this.generation,
    required this.status,
    required this.startedAt,
  });

  final int generation;
  final RoomDisplayStatus status;
  final DateTime startedAt;
}

abstract final class SummaryStatusPulseTiming {
  static const riseDuration = Duration(milliseconds: 420);
  static const peakTime = Duration(milliseconds: 580);
  static const fadeDuration = Duration(seconds: 2);
  static const totalDuration = Duration(milliseconds: 2580);
  static const cleanupDuration = Duration(milliseconds: 2730);
  static const brightnessMultiplier = 2.0;
  static const rubberAmplitudeMultiplier = 1.7;

  static double heat(Duration elapsed) {
    final milliseconds = elapsed.inMicroseconds / 1000;
    if (milliseconds <= 0) return 0;
    if (milliseconds < riseDuration.inMilliseconds) {
      return _smootherStep(milliseconds / riseDuration.inMilliseconds);
    }
    if (milliseconds <= peakTime.inMilliseconds) return 1;
    if (milliseconds >= totalDuration.inMilliseconds) return 0;

    final coolingProgress =
        (milliseconds - peakTime.inMilliseconds) / fadeDuration.inMilliseconds;
    final remainingHeat = 1 - _smootherStep(coolingProgress);
    return math.pow(math.max(remainingHeat, 0), 0.7).toDouble();
  }

  static double _smootherStep(double rawValue) {
    final value = rawValue.clamp(0.0, 1.0);
    return value * value * value * (value * (value * 6 - 15) + 10);
  }
}

final class SummaryVisualPulseCoordinator extends ChangeNotifier {
  SummaryVisualPulseCoordinator({
    this.cleanupDuration = SummaryStatusPulseTiming.cleanupDuration,
  });

  final Duration cleanupDuration;
  final _events = <String, SummaryVisualPulseEvent>{};
  final _cleanupTimers = <String, Timer>{};
  var _generation = 0;

  bool get hasEvents => _events.isNotEmpty;

  SummaryVisualPulseEvent? eventFor(String roomNumber) {
    return _events[roomNumber];
  }

  void record({
    required String roomNumber,
    required RoomDisplayStatus status,
    required DateTime startedAt,
  }) {
    _cleanupTimers.remove(roomNumber)?.cancel();
    final event = SummaryVisualPulseEvent(
      generation: ++_generation,
      status: status,
      startedAt: startedAt,
    );
    _events[roomNumber] = event;
    _cleanupTimers[roomNumber] = Timer(cleanupDuration, () {
      if (_events[roomNumber]?.generation != event.generation) return;
      _events.remove(roomNumber);
      _cleanupTimers.remove(roomNumber);
      notifyListeners();
    });
    notifyListeners();
  }

  @override
  void dispose() {
    for (final timer in _cleanupTimers.values) {
      timer.cancel();
    }
    _cleanupTimers.clear();
    _events.clear();
    super.dispose();
  }
}
