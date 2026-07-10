import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/room_schedule_selection.dart';

void main() {
  test('default selection advances to the next quarter hour', () {
    final selection = RoomScheduleSelection.defaultSelection(
      DateTime(2027, 2, 10, 10, 7),
    );
    final exactQuarter = RoomScheduleSelection.defaultSelection(
      DateTime(2027, 2, 10, 10, 15),
    );

    expect(selection.displayLabel, '10:15 AM');
    expect(exactQuarter.displayLabel, '10:30 AM');
  });

  test('selection maps 12 AM and PM to the correct local hour', () {
    final now = DateTime(2027, 2, 10, 9);
    const midnight = RoomScheduleSelection(
      hour: 12,
      minute: 0,
      period: RoomSchedulePeriod.am,
    );
    const noon = RoomScheduleSelection(
      hour: 12,
      minute: 0,
      period: RoomSchedulePeriod.pm,
    );

    expect(midnight.dateToday(now).hour, 0);
    expect(noon.dateToday(now).hour, 12);
  });

  test('existing date rounds to the closest supported quarter minute', () {
    final selection = RoomScheduleSelection.fromDate(
      DateTime(2027, 2, 10, 14, 52),
    );

    expect(selection.hour, 2);
    expect(selection.minute, 45);
    expect(selection.period, RoomSchedulePeriod.pm);
  });
}
