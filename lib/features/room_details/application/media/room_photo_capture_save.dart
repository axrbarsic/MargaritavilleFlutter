import '../../../../shared/media/capture/captured_photo_artifact.dart';
import '../../../../shared/media/local_media_artifact_store.dart';
import '../../domain/models/pending_room_media_promotion.dart';
import '../../domain/models/room_media_item.dart';
import '../../domain/repositories/room_details_repository.dart';
import '../../domain/repositories/room_media_promotion_repository.dart';

typedef ReleaseCapturedPhoto = Future<void> Function(String transientFilePath);

final class RoomPhotoCaptureSave {
  const RoomPhotoCaptureSave({
    required MediaArtifactStore artifactStore,
    required RoomMediaPromotionRepository promotionRepository,
    required ReleaseCapturedPhoto releaseCapture,
  }) : _artifactStore = artifactStore,
       _promotionRepository = promotionRepository,
       _releaseCapture = releaseCapture;

  final MediaArtifactStore _artifactStore;
  final RoomMediaPromotionRepository _promotionRepository;
  final ReleaseCapturedPhoto _releaseCapture;

  Future<RoomMediaItem> call({
    required CapturedPhotoArtifact capture,
    required String originDeviceId,
    required String operationId,
    required String mediaId,
    required String sessionId,
    required String roomNumber,
    required DateTime issuedAt,
  }) async {
    final prepared = await _artifactStore.prepare(
      MediaArtifactInput(
        mediaId: mediaId,
        transientFilePath: capture.transientFilePath,
        expectedByteLength: capture.byteLength,
        originalExtension: capture.fileExtension,
        mimeType: capture.mimeType,
      ),
    );
    final media = RoomMediaItem(
      id: mediaId,
      sessionId: sessionId,
      roomNumber: roomNumber,
      kind: RoomMediaKind.photo,
      relativePath: prepared.finalRelativePath,
      checksumSha256: prepared.checksumSha256,
      originDeviceId: originDeviceId,
      createdAt: capture.createdAt,
      updatedAt: issuedAt,
      mimeType: prepared.mimeType,
      byteLength: prepared.byteLength,
      widthPixels: capture.widthPixels,
      heightPixels: capture.heightPixels,
      originalExtension: prepared.originalExtension,
      orientation: capture.orientation,
      colorSpace: capture.colorSpace,
      isHdr: capture.isHdr,
    );
    final promotion = PendingRoomMediaPromotion(
      operationId: operationId,
      commandId: 'room-photo:$mediaId',
      media: media,
      stagedRelativePath: prepared.stagedRelativePath,
      transientFilePath: prepared.transientFilePath,
      byteLength: prepared.byteLength,
    );
    await _promotionRepository.stageMediaPromotion(promotion);
    final staged = await _artifactStore.stagePrepared(prepared);
    await _artifactStore.promote(staged);
    final status = await _promotionRepository.completeMediaPromotion(
      operationId,
    );
    if (status == RoomDetailsCommitStatus.ignored) {
      throw StateError('Фото не было принято локальным хранилищем');
    }
    try {
      await _releaseCapture(capture.transientFilePath);
    } catch (_) {
      // Durable app media must survive cleanup failures in plugin cache.
    }
    return media;
  }
}
