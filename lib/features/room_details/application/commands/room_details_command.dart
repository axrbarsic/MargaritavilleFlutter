import '../../domain/models/room_media_item.dart';

sealed class RoomDetailsCommand {
  const RoomDetailsCommand({
    required this.commandId,
    required this.sessionId,
    required this.roomNumber,
    required this.issuedAt,
    this.commandVersion = 1,
  });

  final String commandId;
  final String sessionId;
  final String roomNumber;
  final DateTime issuedAt;
  final int commandVersion;
}

final class SaveRoomNoteCommand extends RoomDetailsCommand {
  const SaveRoomNoteCommand({
    required super.commandId,
    required super.sessionId,
    required super.roomNumber,
    required super.issuedAt,
    required this.text,
  });

  final String text;
}

final class AddRoomMediaCommand extends RoomDetailsCommand {
  const AddRoomMediaCommand({
    required super.commandId,
    required super.sessionId,
    required super.roomNumber,
    required super.issuedAt,
    required this.media,
  });

  final RoomMediaItem media;
}

final class DeleteRoomMediaCommand extends RoomDetailsCommand {
  const DeleteRoomMediaCommand({
    required super.commandId,
    required super.sessionId,
    required super.roomNumber,
    required super.issuedAt,
    required this.mediaId,
  });

  final String mediaId;
}
