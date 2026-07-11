import 'room_media_item.dart';

final class RoomDetailsSnapshot {
  const RoomDetailsSnapshot({
    required this.sessionId,
    required this.roomNumber,
    required this.media,
    this.note,
    this.updatedAt,
  });

  final String sessionId;
  final String roomNumber;
  final String? note;
  final DateTime? updatedAt;
  final List<RoomMediaItem> media;
}
