enum RoomMediaKind { voice, photo, video }

final class RoomMediaItem {
  const RoomMediaItem({
    required this.id,
    required this.sessionId,
    required this.roomNumber,
    required this.kind,
    required this.relativePath,
    required this.checksumSha256,
    required this.originDeviceId,
    required this.createdAt,
    required this.updatedAt,
    this.assignmentId,
    this.mimeType,
    this.duration,
    this.transcript,
    this.deletedAt,
  });

  final String id;
  final String sessionId;
  final String roomNumber;
  final String? assignmentId;
  final RoomMediaKind kind;
  final String relativePath;
  final String checksumSha256;
  final String originDeviceId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? mimeType;
  final Duration? duration;
  final String? transcript;
  final DateTime? deletedAt;
}
