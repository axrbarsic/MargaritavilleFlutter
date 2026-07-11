import 'room_media_item.dart';

final class PendingRoomMediaPromotion {
  const PendingRoomMediaPromotion({
    required this.operationId,
    required this.commandId,
    required this.media,
    required this.stagedRelativePath,
    required this.transientFilePath,
    required this.byteLength,
  });

  final String operationId;
  final String commandId;
  final RoomMediaItem media;
  final String stagedRelativePath;
  final String transientFilePath;
  final int byteLength;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingRoomMediaPromotion &&
          operationId == other.operationId &&
          commandId == other.commandId &&
          media == other.media &&
          stagedRelativePath == other.stagedRelativePath &&
          transientFilePath == other.transientFilePath &&
          byteLength == other.byteLength;

  @override
  int get hashCode => Object.hash(
    operationId,
    commandId,
    media,
    stagedRelativePath,
    transientFilePath,
    byteLength,
  );
}
