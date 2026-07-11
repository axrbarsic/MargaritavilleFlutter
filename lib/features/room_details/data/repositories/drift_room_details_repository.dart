import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../shared/persistence/app_database.dart';
import '../../application/commands/room_details_command.dart';
import '../../domain/models/pending_room_media_promotion.dart';
import '../../domain/models/room_details_snapshot.dart';
import '../../domain/models/room_media_item.dart';
import '../../domain/repositories/room_details_repository.dart';
import '../../domain/repositories/room_media_garbage_repository.dart';
import '../../domain/repositories/room_media_promotion_repository.dart';

part 'drift_room_details_repository_helpers.dart';
part 'drift_room_media_garbage_repository.dart';
part 'drift_room_media_promotion_repository.dart';

final class DriftRoomDetailsRepository implements RoomDetailsRepository {
  const DriftRoomDetailsRepository(this._database);

  final AppDatabase _database;

  @override
  Future<RoomDetailsSnapshot> load({
    required String sessionId,
    required String roomNumber,
  }) async {
    final noteQuery = _database.select(_database.roomNoteRecords)
      ..where(
        (row) =>
            row.sessionId.equals(sessionId) & row.roomNumber.equals(roomNumber),
      );
    final mediaQuery = _database.select(_database.mediaManifestRecords)
      ..where(
        (row) =>
            row.sessionId.equals(sessionId) &
            row.roomNumber.equals(roomNumber) &
            row.deletedAt.isNull(),
      )
      ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]);
    final note = await noteQuery.getSingleOrNull();
    final media = await mediaQuery.get();
    final newestMediaAt = media.fold<DateTime?>(
      null,
      (latest, row) => _latest(latest, row.updatedAt),
    );
    final updatedAt = _latest(note?.updatedAt, newestMediaAt);
    return RoomDetailsSnapshot(
      sessionId: sessionId,
      roomNumber: roomNumber,
      note: note?.deletedAt == null ? note?.textValue : null,
      updatedAt: updatedAt,
      media: media.map(_mapMedia).toList(growable: false),
    );
  }

  @override
  Future<RoomDetailsCommitStatus> commit(RoomDetailsCommand command) =>
      _database.transaction(() => _commit(command));

  Future<RoomDetailsCommitStatus> _commit(RoomDetailsCommand command) async {
    if (!await _claim(command)) {
      return RoomDetailsCommitStatus.duplicate;
    }
    final changed = switch (command) {
      final SaveRoomNoteCommand value => await _saveNote(value),
      final AddRoomMediaCommand value => await _addMedia(value),
      final DeleteRoomMediaCommand value => await _deleteMedia(value),
    };
    if (!changed) {
      await _finishReceipt(command, RoomDetailsCommitStatus.ignored);
      return RoomDetailsCommitStatus.ignored;
    }
    final eventId = _eventId(command);
    await _database
        .into(_database.historyEventRecords)
        .insert(
          HistoryEventRecordsCompanion.insert(
            id: eventId,
            sessionId: command.sessionId,
            commandId: command.commandId,
            eventType: _eventType(command),
            payloadJson: jsonEncode(_eventPayload(command)),
            happenedAt: command.issuedAt,
          ),
        );
    await _database
        .into(_database.syncOutboxRecords)
        .insert(
          SyncOutboxRecordsCompanion.insert(
            eventId: eventId,
            sessionId: command.sessionId,
          ),
        );
    await _finishReceipt(command, RoomDetailsCommitStatus.applied);
    return RoomDetailsCommitStatus.applied;
  }

  Future<bool> _claim(RoomDetailsCommand command) async {
    final inserted = await _database
        .into(_database.commandReceiptRecords)
        .insertReturningOrNull(
          CommandReceiptRecordsCompanion.insert(
            sessionId: command.sessionId,
            commandId: command.commandId,
            commandVersion: Value(command.commandVersion),
            outcome: 'processing',
            processedAt: command.issuedAt,
          ),
          mode: InsertMode.insertOrIgnore,
        );
    if (inserted != null) return true;

    final query = _database.select(_database.commandReceiptRecords)
      ..where(
        (row) =>
            row.sessionId.equals(command.sessionId) &
            row.commandId.equals(command.commandId),
      )
      ..limit(1);
    final existing = await query.getSingle();
    if (existing.commandVersion != command.commandVersion) {
      throw StateError(
        'Command ${command.commandId} version ${command.commandVersion} '
        'conflicts with processed version ${existing.commandVersion}',
      );
    }
    return false;
  }

  Future<void> _finishReceipt(
    RoomDetailsCommand command,
    RoomDetailsCommitStatus status,
  ) {
    final update = _database.update(_database.commandReceiptRecords)
      ..where(
        (row) =>
            row.sessionId.equals(command.sessionId) &
            row.commandId.equals(command.commandId),
      );
    return update.write(
      CommandReceiptRecordsCompanion(
        outcome: Value(status.name),
        processedAt: Value(command.issuedAt),
      ),
    );
  }

  Future<bool> _saveNote(SaveRoomNoteCommand command) async {
    final normalized = command.text.trim();
    final query = _database.select(_database.roomNoteRecords)
      ..where(
        (row) =>
            row.sessionId.equals(command.sessionId) &
            row.roomNumber.equals(command.roomNumber),
      );
    final existing = await query.getSingleOrNull();
    if (existing != null &&
        !_isNewer(
          command.issuedAt,
          command.commandId,
          existing.updatedAt,
          existing.lastCommandId ?? '',
        )) {
      return false;
    }
    await _database
        .into(_database.roomNoteRecords)
        .insertOnConflictUpdate(
          RoomNoteRecordsCompanion.insert(
            sessionId: command.sessionId,
            roomNumber: command.roomNumber,
            textValue: normalized,
            updatedAt: command.issuedAt,
            lastCommandId: Value(command.commandId),
            deletedAt: Value(normalized.isEmpty ? command.issuedAt : null),
          ),
        );
    return true;
  }

  Future<bool> _addMedia(AddRoomMediaCommand command) async {
    final media = command.media;
    if (media.sessionId != command.sessionId ||
        media.roomNumber != command.roomNumber) {
      throw ArgumentError('Media identity does not match room command');
    }
    final existingQuery = _database.select(_database.mediaManifestRecords)
      ..where((row) => row.id.equals(media.id));
    final existing = await existingQuery.getSingleOrNull();
    if (existing != null) {
      _verifyImmutableMediaIdentity(existing, media);
      if (!_isNewer(
        command.issuedAt,
        command.commandId,
        existing.updatedAt,
        existing.lastCommandId ?? '',
      )) {
        return false;
      }
    }
    await _database
        .into(_database.mediaManifestRecords)
        .insertOnConflictUpdate(
          MediaManifestRecordsCompanion.insert(
            id: media.id,
            sessionId: media.sessionId,
            assignmentId: Value(media.assignmentId),
            roomNumber: Value(media.roomNumber),
            kind: media.kind.name,
            relativePath: media.relativePath,
            checksumSha256: media.checksumSha256,
            originDeviceId: media.originDeviceId,
            createdAt: media.createdAt,
            updatedAt: command.issuedAt,
            mimeType: Value(media.mimeType),
            durationMs: Value(media.duration?.inMilliseconds),
            transcript: Value(media.transcript),
            byteLength: Value(media.byteLength),
            widthPixels: Value(media.widthPixels),
            heightPixels: Value(media.heightPixels),
            originalExtension: Value(media.originalExtension),
            orientation: Value(media.orientation),
            colorSpace: Value(media.colorSpace),
            isHdr: Value(media.isHdr),
            lastCommandId: Value(command.commandId),
            deletedAt: Value(media.deletedAt),
          ),
        );
    return true;
  }

  Future<bool> _deleteMedia(DeleteRoomMediaCommand command) async {
    final existingQuery = _database.select(_database.mediaManifestRecords)
      ..where(
        (row) =>
            row.id.equals(command.mediaId) &
            row.sessionId.equals(command.sessionId) &
            row.roomNumber.equals(command.roomNumber),
      );
    final existing = await existingQuery.getSingleOrNull();
    if (existing == null ||
        !_isNewer(
          command.issuedAt,
          command.commandId,
          existing.updatedAt,
          existing.lastCommandId ?? '',
        )) {
      return false;
    }
    final update = _database.update(_database.mediaManifestRecords)
      ..where(
        (row) =>
            row.id.equals(command.mediaId) &
            row.sessionId.equals(command.sessionId) &
            row.roomNumber.equals(command.roomNumber),
      );
    final count = await update.write(
      MediaManifestRecordsCompanion(
        updatedAt: Value(command.issuedAt),
        lastCommandId: Value(command.commandId),
        deletedAt: Value(command.issuedAt),
      ),
    );
    return count > 0;
  }
}
