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

  test('concurrent duplicate is claimed once by a durable receipt', () async {
    final media = _media(session.id, 'concurrent');
    final command = _add(media, 'same-command', media.updatedAt);
    final results = await Future.wait([
      repository.commit(command),
      DriftRoomDetailsRepository(database).commit(command),
    ]);

    expect(
      results,
      containsAll([
        RoomDetailsCommitStatus.applied,
        RoomDetailsCommitStatus.duplicate,
      ]),
    );
    expect(
      await database.select(database.commandReceiptRecords).get(),
      hasLength(1),
    );
    expect(
      await database.select(database.historyEventRecords).get(),
      hasLength(1),
    );
    expect(
      await database.select(database.syncOutboxRecords).get(),
      hasLength(1),
    );
    expect(
      await database.select(database.mediaManifestRecords).get(),
      hasLength(1),
    );
  });

  test('ignored command stores a receipt and replay is duplicate', () async {
    final command = DeleteRoomMediaCommand(
      commandId: 'missing-delete',
      sessionId: session.id,
      roomNumber: '101',
      issuedAt: DateTime.utc(2027, 2, 10, 13),
      mediaId: 'missing',
    );

    expect(await repository.commit(command), RoomDetailsCommitStatus.ignored);
    expect(await repository.commit(command), RoomDetailsCommitStatus.duplicate);
    final receipts = await database
        .select(database.commandReceiptRecords)
        .get();
    expect(receipts.single.outcome, 'ignored');
    expect(await database.select(database.historyEventRecords).get(), isEmpty);
    expect(await database.select(database.syncOutboxRecords).get(), isEmpty);
  });

  test('older note cannot overwrite a newer value or tombstone', () async {
    final newerAt = DateTime.utc(2027, 2, 10, 14);
    await repository.commit(
      SaveRoomNoteCommand(
        commandId: 'new-note',
        sessionId: session.id,
        roomNumber: '101',
        issuedAt: newerAt,
        text: 'Секретный новый текст',
      ),
    );
    expect(
      await repository.commit(
        SaveRoomNoteCommand(
          commandId: 'old-note',
          sessionId: session.id,
          roomNumber: '101',
          issuedAt: newerAt.subtract(const Duration(minutes: 1)),
          text: 'Старое значение',
        ),
      ),
      RoomDetailsCommitStatus.ignored,
    );
    expect(
      (await repository.load(sessionId: session.id, roomNumber: '101')).note,
      'Секретный новый текст',
    );

    await repository.commit(
      SaveRoomNoteCommand(
        commandId: 'new-delete',
        sessionId: session.id,
        roomNumber: '101',
        issuedAt: newerAt.add(const Duration(minutes: 1)),
        text: '',
      ),
    );
    expect(
      await repository.commit(
        SaveRoomNoteCommand(
          commandId: 'old-resurrection',
          sessionId: session.id,
          roomNumber: '101',
          issuedAt: newerAt,
          text: 'Не воскресить',
        ),
      ),
      RoomDetailsCommitStatus.ignored,
    );
    expect(
      (await repository.load(sessionId: session.id, roomNumber: '101')).note,
      isNull,
    );
  });

  test(
    'older media update and delete cannot replace newer projection',
    () async {
      final original = _media(session.id, 'lww');
      final newerAt = original.updatedAt.add(const Duration(minutes: 2));
      await repository.commit(
        _add(original, 'media-first', original.updatedAt),
      );
      final newer = _copyMedia(
        original,
        updatedAt: newerAt,
        transcript: 'Новая расшифровка',
      );
      await repository.commit(_add(newer, 'media-newer', newerAt));

      expect(
        await repository.commit(
          _add(original, 'media-stale', original.updatedAt),
        ),
        RoomDetailsCommitStatus.ignored,
      );
      expect(
        await repository.commit(
          DeleteRoomMediaCommand(
            commandId: 'delete-stale',
            sessionId: session.id,
            roomNumber: '101',
            issuedAt: original.updatedAt,
            mediaId: original.id,
          ),
        ),
        RoomDetailsCommitStatus.ignored,
      );
      final snapshot = await repository.load(
        sessionId: session.id,
        roomNumber: '101',
      );
      expect(snapshot.media.single.transcript, 'Новая расшифровка');
    },
  );

  test('media identity cannot change its local path', () async {
    final original = _media(session.id, 'immutable');
    await repository.commit(
      _add(original, 'immutable-first', original.updatedAt),
    );
    final conflict = _copyMedia(
      original,
      relativePath: 'rooms/101/other.m4a',
      updatedAt: original.updatedAt.add(const Duration(minutes: 1)),
    );

    await expectLater(
      repository.commit(
        _add(conflict, 'immutable-conflict', conflict.updatedAt),
      ),
      throwsStateError,
    );
    final stored =
        (await database.select(database.mediaManifestRecords).get()).single;
    expect(stored.relativePath, original.relativePath);
    expect(
      await database.select(database.commandReceiptRecords).get(),
      hasLength(1),
    );
  });

  test('sync event payload is an allow-listed private envelope', () async {
    const secret = 'PRIVATE-NOTE-SENTINEL';
    await repository.commit(
      SaveRoomNoteCommand(
        commandId: 'private-note',
        sessionId: session.id,
        roomNumber: '101',
        issuedAt: DateTime.utc(2027, 2, 10, 15),
        text: secret,
      ),
    );
    final media = _copyMedia(
      _media(session.id, 'private-media'),
      transcript: 'PRIVATE-TRANSCRIPT-SENTINEL',
    );
    await repository.commit(_add(media, 'private-media', media.updatedAt));

    final history = await database.select(database.historyEventRecords).get();
    final payloads = history
        .map((row) => jsonDecode(row.payloadJson) as Map<String, Object?>)
        .toList();
    expect(payloads.first.keys, unorderedEquals(['roomNumber']));
    expect(
      payloads.last.keys,
      unorderedEquals(['roomNumber', 'mediaId', 'kind', 'checksumSha256']),
    );
    final encoded = history.map((row) => row.payloadJson).join();
    expect(encoded, isNot(contains(secret)));
    expect(encoded, isNot(contains(media.relativePath)));
    expect(encoded, isNot(contains(media.transcript!)));
  });
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

AddRoomMediaCommand _add(
  RoomMediaItem media,
  String commandId,
  DateTime issuedAt,
) => AddRoomMediaCommand(
  commandId: commandId,
  sessionId: media.sessionId,
  roomNumber: media.roomNumber,
  issuedAt: issuedAt,
  media: media,
);

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
    transcript: 'Комната готова.',
  );
}

RoomMediaItem _copyMedia(
  RoomMediaItem value, {
  DateTime? updatedAt,
  String? transcript,
  String? relativePath,
}) => RoomMediaItem(
  id: value.id,
  sessionId: value.sessionId,
  roomNumber: value.roomNumber,
  assignmentId: value.assignmentId,
  kind: value.kind,
  relativePath: relativePath ?? value.relativePath,
  checksumSha256: value.checksumSha256,
  originDeviceId: value.originDeviceId,
  createdAt: value.createdAt,
  updatedAt: updatedAt ?? value.updatedAt,
  mimeType: value.mimeType,
  duration: value.duration,
  transcript: transcript ?? value.transcript,
  deletedAt: value.deletedAt,
);
