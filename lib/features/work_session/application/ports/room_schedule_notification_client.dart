abstract interface class RoomScheduleNotificationClient {
  Future<void> scheduleRoom({
    required String roomNumber,
    required DateTime dueAt,
  });

  Future<void> cancelRoom(String roomNumber);
}

final class NoopRoomScheduleNotificationClient
    implements RoomScheduleNotificationClient {
  const NoopRoomScheduleNotificationClient();

  @override
  Future<void> cancelRoom(String roomNumber) async {}

  @override
  Future<void> scheduleRoom({
    required String roomNumber,
    required DateTime dueAt,
  }) async {}
}

String roomScheduleNotificationId(String roomNumber) {
  return 'margaritaville.room.schedule.$roomNumber';
}
