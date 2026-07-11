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
    this.byteLength,
    this.widthPixels,
    this.heightPixels,
    this.originalExtension,
    this.orientation,
    this.colorSpace,
    this.isHdr,
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
  final int? byteLength;
  final int? widthPixels;
  final int? heightPixels;
  final String? originalExtension;
  final int? orientation;
  final String? colorSpace;
  final bool? isHdr;
  final DateTime? deletedAt;

  RoomMediaItem copyWith({
    String? checksumSha256,
    DateTime? updatedAt,
    String? transcript,
    String? relativePath,
  }) => RoomMediaItem(
    id: id,
    sessionId: sessionId,
    roomNumber: roomNumber,
    assignmentId: assignmentId,
    kind: kind,
    relativePath: relativePath ?? this.relativePath,
    checksumSha256: checksumSha256 ?? this.checksumSha256,
    originDeviceId: originDeviceId,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    mimeType: mimeType,
    duration: duration,
    transcript: transcript ?? this.transcript,
    byteLength: byteLength,
    widthPixels: widthPixels,
    heightPixels: heightPixels,
    originalExtension: originalExtension,
    orientation: orientation,
    colorSpace: colorSpace,
    isHdr: isHdr,
    deletedAt: deletedAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomMediaItem &&
          id == other.id &&
          sessionId == other.sessionId &&
          roomNumber == other.roomNumber &&
          assignmentId == other.assignmentId &&
          kind == other.kind &&
          relativePath == other.relativePath &&
          checksumSha256 == other.checksumSha256 &&
          originDeviceId == other.originDeviceId &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          mimeType == other.mimeType &&
          duration == other.duration &&
          transcript == other.transcript &&
          byteLength == other.byteLength &&
          widthPixels == other.widthPixels &&
          heightPixels == other.heightPixels &&
          originalExtension == other.originalExtension &&
          orientation == other.orientation &&
          colorSpace == other.colorSpace &&
          isHdr == other.isHdr &&
          deletedAt == other.deletedAt;

  @override
  int get hashCode => Object.hashAll([
    id,
    sessionId,
    roomNumber,
    assignmentId,
    kind,
    relativePath,
    checksumSha256,
    originDeviceId,
    createdAt,
    updatedAt,
    mimeType,
    duration,
    transcript,
    byteLength,
    widthPixels,
    heightPixels,
    originalExtension,
    orientation,
    colorSpace,
    isHdr,
    deletedAt,
  ]);
}
