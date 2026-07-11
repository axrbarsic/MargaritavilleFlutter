import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/room_details/application/commands/room_details_command.dart';
import 'package:margaritaville_flutter/features/room_details/application/media/room_media_delete.dart';
import 'package:margaritaville_flutter/features/room_details/application/media/room_media_garbage_collector.dart';
import 'package:margaritaville_flutter/features/room_details/data/repositories/drift_room_details_repository.dart';
import 'package:margaritaville_flutter/features/room_details/domain/models/room_media_item.dart';
import 'package:margaritaville_flutter/features/work_session/data/repositories/drift_work_session_repository.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_session.dart';
import 'package:margaritaville_flutter/shared/media/local_media_artifact_store.dart';
import 'package:margaritaville_flutter/shared/persistence/app_database.dart';

void main() {
  late Directory sourceDirectory;
  late Directory supportDirectory;
  late AppDatabase database;
  late DriftRoomDetailsRepository details;
  late DriftRoomMediaGarbageRepository garbage;
  late LocalMediaArtifactStore store;
  late RoomMediaItem media;

  setUp(() async {
    sourceDirectory = await Directory.systemTemp.createTemp('delete-source-');
    supportDirectory = await Directory.systemTemp.createTemp('delete-support-');
    database = AppDatabase.inMemory();
    details = DriftRoomDetailsRepository(database);
    garbage = DriftRoomMediaGarbageRepository(database);
    store = LocalMediaArtifactStore(() async => supportDirectory);
    await DriftWorkSessionRepository(database).replaceSession(_session());
    media = await _seedMedia(sourceDirectory, store, details);
  });

  tearDown(() async {
    await database.close();
    await sourceDirectory.delete(recursive: true);
    await supportDirectory.delete(recursive: true);
  });

  test('tombstone is durable before the physical file is removed', () async {
    final observing = _RemoveObservingStore(
      store,
      onRemove: () async {
        final tombstones = await garbage.tombstonedMedia();
        expect(tombstones.single.id, media.id);
      },
    );

    await RoomMediaDelete(repository: details, artifactStore: observing)(
      media: media,
      commandId: 'delete-photo-1',
      issuedAt: DateTime.utc(2027, 2, 10, 13),
    );

    expect(
      (await details.load(sessionId: _sessionId, roomNumber: '101')).media,
      isEmpty,
    );
    expect(await garbage.tombstonedMedia(), hasLength(1));
    expect(
      File('${supportDirectory.path}/${media.relativePath}').existsSync(),
      isFalse,
    );
    final history = await database.select(database.historyEventRecords).get();
    expect(history.last.eventType, 'room.media.deleted');
  });

  test(
    'failed cleanup is retried idempotently by startup garbage collection',
    () async {
      final failing = _RemoveObservingStore(
        store,
        onRemove: () async => throw const FileSystemException('busy'),
      );

      await RoomMediaDelete(repository: details, artifactStore: failing)(
        media: media,
        commandId: 'delete-photo-retry',
        issuedAt: DateTime.utc(2027, 2, 10, 13),
      );
      expect(
        File('${supportDirectory.path}/${media.relativePath}').existsSync(),
        isTrue,
      );

      await RoomMediaGarbageCollector(
        repository: garbage,
        artifactStore: store,
      ).collect();

      expect(
        File('${supportDirectory.path}/${media.relativePath}').existsSync(),
        isFalse,
      );
    },
  );
}

const _sessionId = 'session-2027-02-10';

Future<RoomMediaItem> _seedMedia(
  Directory sourceDirectory,
  LocalMediaArtifactStore store,
  DriftRoomDetailsRepository details,
) async {
  final source = File('${sourceDirectory.path}/photo.jpg');
  await source.writeAsBytes([1, 2, 3], flush: true);
  final staged = await store.stage(
    MediaArtifactInput(
      mediaId: 'photo-delete',
      transientFilePath: source.path,
      expectedByteLength: 3,
      originalExtension: 'jpg',
      mimeType: 'image/jpeg',
    ),
  );
  await store.promote(staged);
  final createdAt = DateTime.utc(2027, 2, 10, 12, 45);
  final media = RoomMediaItem(
    id: staged.mediaId,
    sessionId: _sessionId,
    roomNumber: '101',
    kind: RoomMediaKind.photo,
    relativePath: staged.finalRelativePath,
    checksumSha256: staged.checksumSha256,
    originDeviceId: 'device-1',
    createdAt: createdAt,
    updatedAt: createdAt,
    mimeType: staged.mimeType,
    byteLength: staged.byteLength,
    originalExtension: staged.originalExtension,
  );
  await details.commit(
    AddRoomMediaCommand(
      commandId: 'add-photo-delete',
      sessionId: _sessionId,
      roomNumber: '101',
      issuedAt: createdAt,
      media: media,
    ),
  );
  return media;
}

WorkSession _session() {
  final fixture =
      jsonDecode(
            File(
              'test/fixtures/canonical_work_session_v2.json',
            ).readAsStringSync(),
          )
          as Map<String, Object?>;
  return WorkSession.fromJson(fixture);
}

final class _RemoveObservingStore implements MediaArtifactStore {
  const _RemoveObservingStore(this.delegate, {required this.onRemove});

  final MediaArtifactStore delegate;
  final Future<void> Function() onRemove;

  @override
  Future<PreparedMediaArtifact> prepare(MediaArtifactInput input) =>
      delegate.prepare(input);

  @override
  Future<void> removeFinal(String relativePath) async {
    await onRemove();
    await delegate.removeFinal(relativePath);
  }

  @override
  Future<void> discardStage(StagedMediaArtifact artifact) =>
      delegate.discardStage(artifact);

  @override
  Future<MediaArtifactPresence> inspect(StagedMediaArtifact artifact) =>
      delegate.inspect(artifact);

  @override
  Future<PromotedMediaArtifact> promote(StagedMediaArtifact artifact) =>
      delegate.promote(artifact);

  @override
  Future<String> resolveFinalPath(String relativePath) =>
      delegate.resolveFinalPath(relativePath);

  @override
  Future<StagedMediaArtifact> stage(MediaArtifactInput input) =>
      delegate.stage(input);

  @override
  Future<StagedMediaArtifact> stagePrepared(PreparedMediaArtifact artifact) =>
      delegate.stagePrepared(artifact);
}
