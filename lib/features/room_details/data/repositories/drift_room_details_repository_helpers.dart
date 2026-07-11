part of 'drift_room_details_repository.dart';

RoomMediaItem _mapMedia(MediaManifestRow row) => RoomMediaItem(
  id: row.id,
  sessionId: row.sessionId,
  roomNumber: row.roomNumber!,
  assignmentId: row.assignmentId,
  kind: RoomMediaKind.values.byName(row.kind),
  relativePath: row.relativePath,
  checksumSha256: row.checksumSha256,
  originDeviceId: row.originDeviceId,
  createdAt: row.createdAt,
  updatedAt: row.updatedAt,
  mimeType: row.mimeType,
  duration: row.durationMs == null
      ? null
      : Duration(milliseconds: row.durationMs!),
  transcript: row.transcript,
  deletedAt: row.deletedAt,
);

String _eventId(RoomDetailsCommand command) =>
    'room:${command.sessionId}:${command.commandId}';

String _eventType(RoomDetailsCommand command) => switch (command) {
  SaveRoomNoteCommand() => 'room.note.updated',
  AddRoomMediaCommand() => 'room.media.added',
  DeleteRoomMediaCommand() => 'room.media.deleted',
};

Map<String, Object?> _eventPayload(RoomDetailsCommand command) => {
  'roomNumber': command.roomNumber,
  if (command case AddRoomMediaCommand(:final media)) ...{
    'mediaId': media.id,
    'kind': media.kind.name,
    'checksumSha256': media.checksumSha256,
  },
  if (command case DeleteRoomMediaCommand(:final mediaId)) 'mediaId': mediaId,
};

DateTime? _latest(DateTime? first, DateTime? second) {
  if (first == null) return second;
  if (second == null) return first;
  return first.isAfter(second) ? first : second;
}

bool _isNewer(
  DateTime incomingAt,
  String incomingCommandId,
  DateTime storedAt,
  String storedCommandId,
) {
  final comparison = incomingAt.compareTo(storedAt);
  return comparison > 0 ||
      (comparison == 0 && incomingCommandId.compareTo(storedCommandId) > 0);
}

void _verifyImmutableMediaIdentity(
  MediaManifestRow existing,
  RoomMediaItem incoming,
) {
  final matches =
      existing.sessionId == incoming.sessionId &&
      existing.roomNumber == incoming.roomNumber &&
      existing.assignmentId == incoming.assignmentId &&
      existing.kind == incoming.kind.name &&
      existing.relativePath == incoming.relativePath &&
      existing.checksumSha256 == incoming.checksumSha256 &&
      existing.originDeviceId == incoming.originDeviceId &&
      existing.createdAt == incoming.createdAt;
  if (!matches) {
    throw StateError('Media ${incoming.id} has immutable identity conflict');
  }
}
