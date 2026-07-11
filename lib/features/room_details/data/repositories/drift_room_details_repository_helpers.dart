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
  byteLength: row.byteLength,
  widthPixels: row.widthPixels,
  heightPixels: row.heightPixels,
  originalExtension: row.originalExtension,
  orientation: row.orientation,
  colorSpace: row.colorSpace,
  isHdr: row.isHdr,
  deletedAt: row.deletedAt,
);

PendingRoomMediaPromotion _mapPromotion(MediaPromotionRow row) =>
    PendingRoomMediaPromotion(
      operationId: row.operationId,
      commandId: row.commandId,
      stagedRelativePath: row.stagedRelativePath,
      transientFilePath: row.transientFilePath,
      byteLength: row.byteLength,
      media: RoomMediaItem(
        id: row.mediaId,
        sessionId: row.sessionId,
        roomNumber: row.roomNumber!,
        assignmentId: row.assignmentId,
        kind: RoomMediaKind.values.byName(row.kind),
        relativePath: row.finalRelativePath,
        checksumSha256: row.checksumSha256,
        originDeviceId: row.originDeviceId,
        createdAt: row.createdAt,
        updatedAt: row.issuedAt,
        mimeType: row.mimeType,
        duration: row.durationMs == null
            ? null
            : Duration(milliseconds: row.durationMs!),
        transcript: row.transcript,
        byteLength: row.byteLength,
        widthPixels: row.widthPixels,
        heightPixels: row.heightPixels,
        originalExtension: row.originalExtension,
        orientation: row.orientation,
        colorSpace: row.colorSpace,
        isHdr: row.isHdr,
      ),
    );

MediaPromotionRecordsCompanion _promotionCompanion(
  PendingRoomMediaPromotion promotion,
) {
  final media = promotion.media;
  return MediaPromotionRecordsCompanion.insert(
    operationId: promotion.operationId,
    commandId: promotion.commandId,
    mediaId: media.id,
    sessionId: media.sessionId,
    roomNumber: Value(media.roomNumber),
    assignmentId: Value(media.assignmentId),
    kind: media.kind.name,
    stagedRelativePath: promotion.stagedRelativePath,
    transientFilePath: promotion.transientFilePath,
    finalRelativePath: media.relativePath,
    checksumSha256: media.checksumSha256,
    byteLength: promotion.byteLength,
    originDeviceId: media.originDeviceId,
    createdAt: media.createdAt,
    issuedAt: media.updatedAt,
    mimeType: Value(media.mimeType),
    durationMs: Value(media.duration?.inMilliseconds),
    transcript: Value(media.transcript),
    widthPixels: Value(media.widthPixels),
    heightPixels: Value(media.heightPixels),
    originalExtension: Value(media.originalExtension),
    orientation: Value(media.orientation),
    colorSpace: Value(media.colorSpace),
    isHdr: Value(media.isHdr),
  );
}

void _validatePromotion(PendingRoomMediaPromotion promotion) {
  final media = promotion.media;
  if (media.kind == RoomMediaKind.voice ||
      promotion.operationId.isEmpty ||
      promotion.commandId.isEmpty ||
      promotion.byteLength <= 0 ||
      promotion.byteLength != media.byteLength ||
      !promotion.stagedRelativePath.startsWith('Media/.staging/') ||
      !promotion.transientFilePath.startsWith('/') ||
      media.relativePath.startsWith('Media/.staging/') ||
      promotion.stagedRelativePath.contains('..') ||
      promotion.transientFilePath.contains('\u0000') ||
      media.relativePath.contains('..')) {
    throw ArgumentError('Invalid room media promotion');
  }
}

String _eventId(RoomDetailsCommand command) =>
    'room:${command.sessionId}:${command.commandId}';

CommandLedgerEnvelope _ledgerEnvelope(RoomDetailsCommand command) {
  return CommandLedgerEnvelope(
    sessionId: command.sessionId,
    commandId: command.commandId,
    commandVersion: command.commandVersion,
    commandType: _eventType(command),
    commandFingerprint: CommandLedgerEnvelope.fingerprint(
      _commandFingerprintPayload(command),
    ),
    issuedAt: command.issuedAt,
    eventId: _eventId(command),
    eventType: _eventType(command),
    eventPayload: _eventPayload(command),
  );
}

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

Map<String, Object?> _commandFingerprintPayload(RoomDetailsCommand command) => {
  'roomNumber': command.roomNumber,
  if (command case SaveRoomNoteCommand(:final text)) 'text': text,
  if (command case AddRoomMediaCommand(:final media)) ...{
    'mediaId': media.id,
    'kind': media.kind.name,
    'relativePath': media.relativePath,
    'checksumSha256': media.checksumSha256,
    'originDeviceId': media.originDeviceId,
    'createdAtMicros': media.createdAt.microsecondsSinceEpoch,
    'transcript': media.transcript,
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
      existing.createdAt == incoming.createdAt &&
      existing.byteLength == incoming.byteLength &&
      existing.widthPixels == incoming.widthPixels &&
      existing.heightPixels == incoming.heightPixels &&
      existing.originalExtension == incoming.originalExtension &&
      existing.orientation == incoming.orientation &&
      existing.colorSpace == incoming.colorSpace &&
      existing.isHdr == incoming.isHdr;
  if (!matches) {
    throw StateError('Media ${incoming.id} has immutable identity conflict');
  }
}
