import 'package:flutter_test/flutter_test.dart';

import '../../integration_test/support/summary_performance_fixture.dart';

void main() {
  test('stress fixture makes the complete 184-room catalog VIP', () {
    final session = summaryPerformanceSession(
      vipRoomCount: summaryPerformanceRoomCount,
    );
    final rooms = session.activeAssignments
        .expand((assignment) => assignment.activeRooms)
        .toList();

    expect(summaryPerformanceRoomCount, 184);
    expect(session.activeAssignments, hasLength(6));
    expect(rooms, hasLength(184));
    expect(rooms.map((room) => room.roomNumber).toSet(), hasLength(184));
    expect(rooms.every((room) => room.isVip), isTrue);
  });

  test('working fixture can stop at 45 rooms without duplicates', () {
    final session = summaryPerformanceSession(roomCount: 45, vipRoomCount: 45);
    final rooms = session.activeAssignments
        .expand((assignment) => assignment.activeRooms)
        .toList();

    expect(rooms, hasLength(45));
    expect(rooms.map((room) => room.roomNumber).toSet(), hasLength(45));
    expect(rooms.every((room) => room.isVip), isTrue);
  });
}
