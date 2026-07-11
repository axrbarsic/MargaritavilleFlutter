import '../models/pending_room_media_promotion.dart';
import 'room_details_repository.dart';

abstract interface class RoomMediaPromotionRepository {
  Future<void> stageMediaPromotion(PendingRoomMediaPromotion promotion);

  Future<List<PendingRoomMediaPromotion>> pendingMediaPromotions();

  Future<RoomDetailsCommitStatus> completeMediaPromotion(String operationId);

  Future<void> discardMediaPromotion(String operationId);

  Future<void> quarantineMediaPromotion(
    String operationId, {
    required String reason,
    required DateTime detectedAt,
  });
}
