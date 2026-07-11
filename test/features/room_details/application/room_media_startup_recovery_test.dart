import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/room_details/application/media/room_media_garbage_collector.dart';
import 'package:margaritaville_flutter/features/room_details/application/media/room_media_promotion_recovery.dart';
import 'package:margaritaville_flutter/features/room_details/application/media/room_media_startup_recovery.dart';
import 'package:margaritaville_flutter/features/room_details/domain/models/pending_room_media_promotion.dart';
import 'package:margaritaville_flutter/features/room_details/domain/models/room_media_item.dart';
import 'package:margaritaville_flutter/features/room_details/domain/repositories/room_details_repository.dart';
import 'package:margaritaville_flutter/features/room_details/domain/repositories/room_media_garbage_repository.dart';
import 'package:margaritaville_flutter/features/room_details/domain/repositories/room_media_promotion_repository.dart';
import 'package:margaritaville_flutter/shared/media/local_media_artifact_store.dart';

void main() {
  test(
    'a poison journal does not prevent later promotions from recovery',
    () async {
      final repository = _PromotionRepository([
        _promotion('poison'),
        _promotion('healthy'),
      ]);
      final store = _ArtifactStore(failingMediaId: 'poison');
      final recovery = RoomMediaPromotionRecovery(
        artifactStore: store,
        repository: repository,
      );

      await expectLater(
        recovery.recoverAll(),
        throwsA(
          isA<RoomMediaPromotionRecoveryException>().having(
            (error) => error.failures.single.operationId,
            'failed operation',
            'operation-poison',
          ),
        ),
      );

      expect(repository.completed, ['operation-healthy']);
    },
  );

  test(
    'startup garbage collection still runs after promotion failure',
    () async {
      final store = _ArtifactStore(failingMediaId: 'poison');
      final startup = RoomMediaStartupRecovery(
        promotionRecovery: RoomMediaPromotionRecovery(
          artifactStore: store,
          repository: _PromotionRepository([_promotion('poison')]),
        ),
        garbageCollector: RoomMediaGarbageCollector(
          artifactStore: store,
          repository: _GarbageRepository([_media('garbage')]),
        ),
      );

      await expectLater(
        startup.run(),
        throwsA(isA<RoomMediaPromotionRecoveryException>()),
      );

      expect(store.removedFinalPaths, ['Media/garbage.jpg']);
    },
  );

  test(
    'terminal integrity conflict is quarantined without blocking startup',
    () async {
      final repository = _PromotionRepository([_promotion('poison')]);
      final report = await RoomMediaPromotionRecovery(
        artifactStore: _ArtifactStore(
          failingMediaId: 'poison',
          terminalFailure: true,
        ),
        repository: repository,
      ).recoverAll();

      expect(report.recovered, 0);
      expect(report.quarantined, 1);
      expect(repository.quarantined, ['operation-poison']);
    },
  );
}

PendingRoomMediaPromotion _promotion(String id) => PendingRoomMediaPromotion(
  operationId: 'operation-$id',
  commandId: 'room-photo:$id',
  media: _media(id),
  stagedRelativePath: 'Media/.staging/$id.jpg.partial',
  transientFilePath: '/camera-cache/$id.jpg',
  byteLength: 3,
);

RoomMediaItem _media(String id) {
  final now = DateTime.utc(2027, 2, 10, 12);
  return RoomMediaItem(
    id: id,
    sessionId: 'session-1',
    roomNumber: '101',
    kind: RoomMediaKind.photo,
    relativePath: 'Media/$id.jpg',
    checksumSha256: 'a' * 64,
    originDeviceId: 'device-1',
    createdAt: now,
    updatedAt: now,
    mimeType: 'image/jpeg',
    byteLength: 3,
    originalExtension: 'jpg',
  );
}

final class _PromotionRepository implements RoomMediaPromotionRepository {
  _PromotionRepository(this.promotions);

  final List<PendingRoomMediaPromotion> promotions;
  final List<String> completed = [];
  final List<String> quarantined = [];

  @override
  Future<RoomDetailsCommitStatus> completeMediaPromotion(
    String operationId,
  ) async {
    completed.add(operationId);
    return RoomDetailsCommitStatus.applied;
  }

  @override
  Future<void> discardMediaPromotion(String operationId) async {}

  @override
  Future<List<PendingRoomMediaPromotion>> pendingMediaPromotions() async =>
      promotions;

  @override
  Future<void> quarantineMediaPromotion(
    String operationId, {
    required String reason,
    required DateTime detectedAt,
  }) async {
    quarantined.add(operationId);
  }

  @override
  Future<void> stageMediaPromotion(PendingRoomMediaPromotion promotion) async {}
}

final class _GarbageRepository implements RoomMediaGarbageRepository {
  const _GarbageRepository(this.media);

  final List<RoomMediaItem> media;

  @override
  Future<List<RoomMediaItem>> tombstonedMedia() async => media;
}

final class _ArtifactStore implements MediaArtifactStore {
  _ArtifactStore({required this.failingMediaId, this.terminalFailure = false});

  final String failingMediaId;
  final bool terminalFailure;
  final List<String> removedFinalPaths = [];

  @override
  Future<PreparedMediaArtifact> prepare(MediaArtifactInput input) =>
      throw UnimplementedError();

  @override
  Future<StagedMediaArtifact> stage(MediaArtifactInput input) =>
      throw UnimplementedError();

  @override
  Future<StagedMediaArtifact> stagePrepared(
    PreparedMediaArtifact artifact,
  ) async {
    if (artifact.mediaId == failingMediaId) {
      if (terminalFailure) {
        throw const MediaArtifactIntegrityConflict('checksum conflict');
      }
      throw StateError('simulated corrupt partial');
    }
    return StagedMediaArtifact(
      mediaId: artifact.mediaId,
      stagedRelativePath: artifact.stagedRelativePath,
      finalRelativePath: artifact.finalRelativePath,
      checksumSha256: artifact.checksumSha256,
      byteLength: artifact.byteLength,
      originalExtension: artifact.originalExtension,
      mimeType: artifact.mimeType,
      created: false,
      alreadyPromoted: false,
    );
  }

  @override
  Future<PromotedMediaArtifact> promote(StagedMediaArtifact artifact) async =>
      PromotedMediaArtifact(
        relativePath: artifact.finalRelativePath,
        absolutePath: '/support/${artifact.finalRelativePath}',
        checksumSha256: artifact.checksumSha256,
        byteLength: artifact.byteLength,
        created: false,
      );

  @override
  Future<void> removeFinal(String relativePath) async {
    removedFinalPaths.add(relativePath);
  }

  @override
  Future<void> discardStage(StagedMediaArtifact artifact) async {}

  @override
  Future<MediaArtifactPresence> inspect(StagedMediaArtifact artifact) async =>
      MediaArtifactPresence.missing;

  @override
  Future<String> resolveFinalPath(String relativePath) async =>
      '/support/$relativePath';
}
