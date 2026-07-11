import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/room_details/application/commands/room_details_command.dart';
import 'package:margaritaville_flutter/features/room_details/data/repositories/drift_room_details_repository.dart';
import 'package:margaritaville_flutter/features/room_details/domain/models/room_media_item.dart';
import 'package:margaritaville_flutter/features/room_details/domain/repositories/room_details_repository.dart';
import 'package:margaritaville_flutter/features/work_session/data/repositories/drift_work_session_repository.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_session.dart';
import 'package:margaritaville_flutter/shared/persistence/app_database.dart';

void main() {
  late AppDatabase database;
  late DriftRoomDetailsRepository repository;
  late WorkSession session;

  setUp(() async {
    database = AppDatabase.inMemory();
    repository = DriftRoomDetailsRepository(database);
    session = _canonicalSession();
    await DriftWorkSessionRepository(database).replaceSession(session);
  });

  tearDown(() => database.close());

  test('media commit writes manifest history and outbox atomically', () async {
    final media = _media(session.id, 'media-1');
    final command = AddRoomMediaCommand(
      commandId: 'add-media-1',
      sessionId: session.id,
      roomNumber: '101',
      issuedAt: media.updatedAt,
      media: media,
    );

    expect(await repository.commit(command), RoomDetailsCommitStatus.applied);
    expect(await repository.commit(command), RoomDetailsCommitStatus.duplicate);

    final snapshot = await repository.load(
      sessionId: session.id,
      roomNumber: '101',
    );
    final history = await database.select(database.historyEventRecords).get();
    final outbox = await database.select(database.syncOutboxRecords).get();
    expect(snapshot.media.single.id, media.id);
    expect(snapshot.media.single.mimeType, 'audio/mp4');
    expect(snapshot.media.single.duration, const Duration(seconds: 12));
    expect(history, hasLength(1));
    expect(history.single.commandId, command.commandId);
    expect(outbox.single.eventId, history.single.id);
  });

  test('event failure rolls back media mutation', () async {
    final media = _media(session.id, 'media-rollback');
    final issuedAt = media.updatedAt;
    await database.customStatement('''
      INSERT INTO history_event_records (
        id, session_id, command_id, event_type, event_version,
        payload_json, happened_at
      ) VALUES (
        'room:${session.id}:collision', '${session.id}', 'preexisting',
        'sentinel', 1, '{}', '${issuedAt.toIso8601String()}'
      )
    ''');

    await expectLater(
      repository.commit(
        AddRoomMediaCommand(
          commandId: 'collision',
          sessionId: session.id,
          roomNumber: '101',
          issuedAt: issuedAt,
          media: media,
        ),
      ),
      throwsA(anything),
    );

    final snapshot = await repository.load(
      sessionId: session.id,
      roomNumber: '101',
    );
    expect(snapshot.media, isEmpty);
    expect(await database.select(database.syncOutboxRecords).get(), isEmpty);
    expect(
      await database.select(database.commandReceiptRecords).get(),
      isEmpty,
    );
  });

  test('delete command stores tombstone and hides media', () async {
    final media = _media(session.id, 'media-delete');
    await repository.commit(
      AddRoomMediaCommand(
        commandId: 'add-before-delete',
        sessionId: session.id,
        roomNumber: '101',
        issuedAt: media.updatedAt,
        media: media,
      ),
    );

    final deletedAt = media.updatedAt.add(const Duration(minutes: 1));
    final result = await repository.commit(
      DeleteRoomMediaCommand(
        commandId: 'delete-media',
        sessionId: session.id,
        roomNumber: '101',
        issuedAt: deletedAt,
        mediaId: media.id,
      ),
    );

    final snapshot = await repository.load(
      sessionId: session.id,
      roomNumber: '101',
    );
    final stored = await database.select(database.mediaManifestRecords).get();
    expect(result, RoomDetailsCommitStatus.applied);
    expect(snapshot.media, isEmpty);
    expect(stored.single.deletedAt, deletedAt);
    expect(
      await database.select(database.historyEventRecords).get(),
      hasLength(2),
    );
    expect(
      await database.select(database.syncOutboxRecords).get(),
      hasLength(2),
    );
  });

  test('same media ID cannot be rebound to another checksum', () async {
    final original = _media(session.id, 'immutable-checksum');
    await repository.commit(
      AddRoomMediaCommand(
        commandId: 'checksum-first',
        sessionId: session.id,
        roomNumber: '101',
        issuedAt: original.updatedAt,
        media: original,
      ),
    );
    final conflict = RoomMediaItem(
      id: original.id,
      sessionId: original.sessionId,
      roomNumber: original.roomNumber,
      kind: original.kind,
      relativePath: original.relativePath,
      checksumSha256: 'different-file-checksum',
      originDeviceId: original.originDeviceId,
      createdAt: original.createdAt,
      updatedAt: original.updatedAt.add(const Duration(minutes: 1)),
    );

    await expectLater(
      repository.commit(
        AddRoomMediaCommand(
          commandId: 'checksum-conflict',
          sessionId: session.id,
          roomNumber: '101',
          issuedAt: conflict.updatedAt,
          media: conflict,
        ),
      ),
      throwsStateError,
    );
    final stored =
        (await database.select(database.mediaManifestRecords).get()).single;
    expect(stored.checksumSha256, original.checksumSha256);
  });

  test(
    'equal timestamps use command ID as deterministic LWW tie-break',
    () async {
      final issuedAt = DateTime.utc(2027, 2, 10, 16);
      Future<RoomDetailsCommitStatus> save(String commandId, String text) {
        return repository.commit(
          SaveRoomNoteCommand(
            commandId: commandId,
            sessionId: session.id,
            roomNumber: '101',
            issuedAt: issuedAt,
            text: text,
          ),
        );
      }

      expect(await save('a', 'Первое'), RoomDetailsCommitStatus.applied);
      expect(await save('b', 'Победитель'), RoomDetailsCommitStatus.applied);
      expect(await save('aa', 'Опоздавшее'), RoomDetailsCommitStatus.ignored);
      final snapshot = await repository.load(
        sessionId: session.id,
        roomNumber: '101',
      );
      expect(snapshot.note, 'Победитель');
    },
  );
}

WorkSession _canonicalSession() {
  final fixture =
      jsonDecode(
            File(
              'test/fixtures/canonical_work_session_v2.json',
            ).readAsStringSync(),
          )
          as Map<String, Object?>;
  return WorkSession.fromJson(fixture);
}

RoomMediaItem _media(String sessionId, String id) {
  final createdAt = DateTime.utc(2027, 2, 10, 12, 45);
  return RoomMediaItem(
    id: id,
    sessionId: sessionId,
    roomNumber: '101',
    kind: RoomMediaKind.voice,
    relativePath: 'rooms/101/$id.m4a',
    checksumSha256: 'sha256-$id',
    originDeviceId: 'device-1',
    createdAt: createdAt,
    updatedAt: createdAt,
    mimeType: 'audio/mp4',
    duration: const Duration(seconds: 12),
    transcript: 'Комната готова.',
  );
}
