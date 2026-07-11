import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/room_details/application/media/room_media_promotion_recovery.dart';
import 'package:margaritaville_flutter/features/room_details/application/media/room_photo_capture_save.dart';
import 'package:margaritaville_flutter/features/room_details/data/repositories/drift_room_details_repository.dart';
import 'package:margaritaville_flutter/features/room_details/domain/models/pending_room_media_promotion.dart';
import 'package:margaritaville_flutter/features/room_details/domain/models/room_media_item.dart';
import 'package:margaritaville_flutter/features/room_details/domain/repositories/room_details_repository.dart';
import 'package:margaritaville_flutter/features/room_details/domain/repositories/room_media_promotion_repository.dart';
import 'package:margaritaville_flutter/features/work_session/data/repositories/drift_work_session_repository.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_session.dart';
import 'package:margaritaville_flutter/shared/media/capture/captured_photo_artifact.dart';
import 'package:margaritaville_flutter/shared/media/local_media_artifact_store.dart';
import 'package:margaritaville_flutter/shared/persistence/app_database.dart';

void main() {
  late Directory sourceDirectory;
  late Directory supportDirectory;
  late AppDatabase database;
  late DriftRoomDetailsRepository detailsRepository;
  late DriftRoomMediaPromotionRepository promotionRepository;
  late LocalMediaArtifactStore artifactStore;

  setUp(() async {
    sourceDirectory = await Directory.systemTemp.createTemp('photo-capture-');
    supportDirectory = await Directory.systemTemp.createTemp('photo-support-');
    database = AppDatabase.inMemory();
    detailsRepository = DriftRoomDetailsRepository(database);
    promotionRepository = DriftRoomMediaPromotionRepository(database);
    artifactStore = LocalMediaArtifactStore(() async => supportDirectory);
    await DriftWorkSessionRepository(database).replaceSession(_session());
  });

  tearDown(() async {
    await database.close();
    await sourceDirectory.delete(recursive: true);
    await supportDirectory.delete(recursive: true);
  });

  test(
    'save publishes only verified immutable bytes then releases cache',
    () async {
      final source = await _source(sourceDirectory, [1, 3, 3, 7]);
      var released = false;
      final save = RoomPhotoCaptureSave(
        artifactStore: artifactStore,
        promotionRepository: promotionRepository,
        releaseCapture: (path) async {
          expect(path, source.path);
          released = true;
        },
      );

      final media = await save(
        capture: _capture(source),
        originDeviceId: 'device-1',
        operationId: 'operation-save',
        mediaId: 'photo-save',
        sessionId: _sessionId,
        roomNumber: '101',
        issuedAt: DateTime.utc(2027, 2, 10, 12, 46),
      );

      expect(released, isTrue);
      expect(await promotionRepository.pendingMediaPromotions(), isEmpty);
      expect(
        await File(
          '${supportDirectory.path}/${media.relativePath}',
        ).readAsBytes(),
        [1, 3, 3, 7],
      );
      final stored = (await detailsRepository.load(
        sessionId: _sessionId,
        roomNumber: '101',
      )).media.single;
      expect(stored, media);
      expect(stored.byteLength, 4);
      expect(stored.widthPixels, 4032);
      expect(stored.colorSpace, 'Display P3');
    },
  );

  test(
    'verified final recovers after v6 sentinel replaces missing transient',
    () async {
      final source = await _source(sourceDirectory, [2, 4, 6, 8]);
      final failing = _FailOncePromotionRepository(promotionRepository);
      final save = RoomPhotoCaptureSave(
        artifactStore: artifactStore,
        promotionRepository: failing,
        releaseCapture: (_) async =>
            fail('cache must not be released on failure'),
      );

      await expectLater(
        save(
          capture: _capture(source),
          originDeviceId: 'device-1',
          operationId: 'operation-recover',
          mediaId: 'photo-recover',
          sessionId: _sessionId,
          roomNumber: '101',
          issuedAt: DateTime.utc(2027, 2, 10, 12, 47),
        ),
        throwsStateError,
      );
      expect(await promotionRepository.pendingMediaPromotions(), hasLength(1));
      expect(
        File('${supportDirectory.path}/Media/photo-recover.jpg').existsSync(),
        isTrue,
      );
      await source.delete();
      await database.customStatement(
        'UPDATE media_promotion_records '
        'SET transient_file_path = ? WHERE operation_id = ?',
        ['/tmp/margaritaville-recovery-missing-source', 'operation-recover'],
      );

      await RoomMediaPromotionRecovery(
        artifactStore: artifactStore,
        repository: promotionRepository,
      ).recoverAll();

      expect(await promotionRepository.pendingMediaPromotions(), isEmpty);
      expect(
        await File(
          '${supportDirectory.path}/Media/photo-recover.jpg',
        ).readAsBytes(),
        [2, 4, 6, 8],
      );
      expect(
        (await detailsRepository.load(
          sessionId: _sessionId,
          roomNumber: '101',
        )).media.single.id,
        'photo-recover',
      );
    },
  );

  test('recovery quarantines a journal whose bytes no longer exist', () async {
    final source = await _source(sourceDirectory, [9, 9]);
    final staged = await artifactStore.stage(
      MediaArtifactInput(
        mediaId: 'photo-missing',
        transientFilePath: source.path,
        expectedByteLength: 2,
        originalExtension: 'jpg',
        mimeType: 'image/jpeg',
      ),
    );
    final capture = _capture(source);
    final promotion = PendingRoomMediaPromotion(
      operationId: 'operation-missing',
      commandId: 'room-photo:photo-missing',
      stagedRelativePath: staged.stagedRelativePath,
      transientFilePath: source.path,
      byteLength: staged.byteLength,
      media: _mediaFrom(capture, staged),
    );
    await promotionRepository.stageMediaPromotion(promotion);
    await artifactStore.discardStage(staged);
    await source.delete();

    final report = await RoomMediaPromotionRecovery(
      artifactStore: artifactStore,
      repository: promotionRepository,
    ).recoverAll();

    expect(report.quarantined, 1);
    expect(await promotionRepository.pendingMediaPromotions(), isEmpty);
    final journal = await database
        .select(database.mediaPromotionRecords)
        .getSingle();
    expect(journal.quarantinedAt, isNotNull);
    expect(journal.failureReason, contains(source.path));
    expect(
      (await detailsRepository.load(
        sessionId: _sessionId,
        roomNumber: '101',
      )).media,
      isEmpty,
    );
  });
}

const _sessionId = 'session-2027-02-10';

Future<File> _source(Directory directory, List<int> bytes) async {
  final file = File('${directory.path}/capture.jpg');
  await file.writeAsBytes(bytes, flush: true);
  return file;
}

CapturedPhotoArtifact _capture(File source) => CapturedPhotoArtifact(
  transientFilePath: source.path,
  byteLength: source.lengthSync(),
  mimeType: 'image/jpeg',
  fileExtension: 'jpg',
  createdAt: DateTime.utc(2027, 2, 10, 12, 45),
  widthPixels: 4032,
  heightPixels: 3024,
  orientation: 1,
  colorSpace: 'Display P3',
  isHdr: false,
);

RoomMediaItem _mediaFrom(
  CapturedPhotoArtifact capture,
  StagedMediaArtifact artifact,
) => RoomMediaItem(
  id: artifact.mediaId,
  sessionId: _sessionId,
  roomNumber: '101',
  kind: RoomMediaKind.photo,
  relativePath: artifact.finalRelativePath,
  checksumSha256: artifact.checksumSha256,
  originDeviceId: 'device-1',
  createdAt: capture.createdAt,
  updatedAt: capture.createdAt,
  mimeType: artifact.mimeType,
  byteLength: artifact.byteLength,
  widthPixels: capture.widthPixels,
  heightPixels: capture.heightPixels,
  originalExtension: artifact.originalExtension,
  orientation: capture.orientation,
  colorSpace: capture.colorSpace,
  isHdr: capture.isHdr,
);

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

final class _FailOncePromotionRepository
    implements RoomMediaPromotionRepository {
  _FailOncePromotionRepository(this.delegate);

  final RoomMediaPromotionRepository delegate;
  bool _failed = false;

  @override
  Future<RoomDetailsCommitStatus> completeMediaPromotion(String operationId) {
    if (!_failed) {
      _failed = true;
      throw StateError('simulated process loss after file promotion');
    }
    return delegate.completeMediaPromotion(operationId);
  }

  @override
  Future<void> discardMediaPromotion(String operationId) =>
      delegate.discardMediaPromotion(operationId);

  @override
  Future<List<PendingRoomMediaPromotion>> pendingMediaPromotions() =>
      delegate.pendingMediaPromotions();

  @override
  Future<void> quarantineMediaPromotion(
    String operationId, {
    required String reason,
    required DateTime detectedAt,
  }) => delegate.quarantineMediaPromotion(
    operationId,
    reason: reason,
    detectedAt: detectedAt,
  );

  @override
  Future<void> stageMediaPromotion(PendingRoomMediaPromotion promotion) =>
      delegate.stageMediaPromotion(promotion);
}
