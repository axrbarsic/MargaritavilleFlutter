enum RoomSchedulePeriod { am, pm }

extension RoomSchedulePeriodLabel on RoomSchedulePeriod {
  String get label => name.toUpperCase();
}

final class RoomScheduleSelection {
  const RoomScheduleSelection({
    required this.hour,
    required this.minute,
    required this.period,
  });

  factory RoomScheduleSelection.fromDate(DateTime date) {
    final local = date.toLocal();
    final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
    return RoomScheduleSelection(
      hour: hours.contains(hour12) ? hour12 : 11,
      minute: _closestQuarterMinute(local.minute),
      period: local.hour >= 12 ? RoomSchedulePeriod.pm : RoomSchedulePeriod.am,
    );
  }

  factory RoomScheduleSelection.defaultSelection(DateTime now) {
    final local = now.toLocal();
    final minutesToNextQuarter = 15 - (local.minute % 15);
    return RoomScheduleSelection.fromDate(
      local.add(Duration(minutes: minutesToNextQuarter)),
    );
  }

  static const hours = [8, 9, 10, 11, 12, 1, 2, 3, 4];
  static const minutes = [0, 15, 30, 45];

  final int hour;
  final int minute;
  final RoomSchedulePeriod period;

  String get displayLabel {
    final paddedMinute = minute.toString().padLeft(2, '0');
    return '$hour:$paddedMinute ${period.label}';
  }

  DateTime dateToday(DateTime now) {
    final local = now.toLocal();
    var hour24 = hour % 12;
    if (period == RoomSchedulePeriod.pm) hour24 += 12;
    return DateTime(local.year, local.month, local.day, hour24, minute);
  }

  RoomScheduleSelection copyWith({
    int? hour,
    int? minute,
    RoomSchedulePeriod? period,
  }) {
    return RoomScheduleSelection(
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      period: period ?? this.period,
    );
  }

  static int _closestQuarterMinute(int minute) {
    return minutes.reduce((first, second) {
      return (first - minute).abs() < (second - minute).abs() ? first : second;
    });
  }

  @override
  bool operator ==(Object other) {
    return other is RoomScheduleSelection &&
        other.hour == hour &&
        other.minute == minute &&
        other.period == period;
  }

  @override
  int get hashCode => Object.hash(hour, minute, period);
}
