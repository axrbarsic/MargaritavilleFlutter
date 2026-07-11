part of 'drift_room_details_repository.dart';

final class DriftRoomMediaPromotionRepository
    implements RoomMediaPromotionRepository {
  const DriftRoomMediaPromotionRepository(this._database);

  final AppDatabase _database;

  @override
  Future<void> stageMediaPromotion(PendingRoomMediaPromotion promotion) async {
    _validatePromotion(promotion);
    final inserted = await _database
        .into(_database.mediaPromotionRecords)
        .insertReturningOrNull(
          _promotionCompanion(promotion),
          mode: InsertMode.insertOrIgnore,
        );
    if (inserted != null) return;

    final query = _database.select(_database.mediaPromotionRecords)
      ..where((row) => row.operationId.equals(promotion.operationId))
      ..limit(1);
    final existing = await query.getSingleOrNull();
    if (existing == null || _mapPromotion(existing) != promotion) {
      throw StateError(
        'Media promotion ${promotion.operationId} has an identity conflict',
      );
    }
  }

  @override
  Future<List<PendingRoomMediaPromotion>> pendingMediaPromotions() async {
    final query = _database.select(_database.mediaPromotionRecords)
      ..where((row) => row.quarantinedAt.isNull())
      ..orderBy([(row) => OrderingTerm.asc(row.issuedAt)]);
    return (await query.get()).map(_mapPromotion).toList(growable: false);
  }

  @override
  Future<RoomDetailsCommitStatus> completeMediaPromotion(String operationId) {
    return _database.transaction(() async {
      final query = _database.select(_database.mediaPromotionRecords)
        ..where((row) => row.operationId.equals(operationId))
        ..limit(1);
      final row = await query.getSingleOrNull();
      if (row == null) {
        throw StateError('Media promotion $operationId was not found');
      }
      final promotion = _mapPromotion(row);
      final status = await DriftRoomDetailsRepository(_database)._commit(
        AddRoomMediaCommand(
          commandId: promotion.commandId,
          sessionId: promotion.media.sessionId,
          roomNumber: promotion.media.roomNumber,
          issuedAt: promotion.media.updatedAt,
          media: promotion.media,
        ),
      );
      if (status == RoomDetailsCommitStatus.ignored) return status;
      if (status == RoomDetailsCommitStatus.duplicate) {
        await _verifyPublishedPromotion(promotion);
      }
      await (_database.delete(
        _database.mediaPromotionRecords,
      )..where((value) => value.operationId.equals(operationId))).go();
      return status;
    });
  }

  @override
  Future<void> discardMediaPromotion(String operationId) async {
    await (_database.delete(
      _database.mediaPromotionRecords,
    )..where((row) => row.operationId.equals(operationId))).go();
  }

  @override
  Future<void> quarantineMediaPromotion(
    String operationId, {
    required String reason,
    required DateTime detectedAt,
  }) async {
    final updated =
        await (_database.update(
          _database.mediaPromotionRecords,
        )..where((row) => row.operationId.equals(operationId))).write(
          MediaPromotionRecordsCompanion(
            quarantinedAt: Value(detectedAt),
            failureReason: Value(reason),
          ),
        );
    if (updated != 1) {
      throw StateError('Media promotion $operationId was not found');
    }
  }

  Future<void> _verifyPublishedPromotion(
    PendingRoomMediaPromotion promotion,
  ) async {
    final query = _database.select(_database.mediaManifestRecords)
      ..where((row) => row.id.equals(promotion.media.id))
      ..limit(1);
    final existing = await query.getSingleOrNull();
    if (existing == null) {
      throw StateError(
        'Duplicate promotion ${promotion.operationId} has no manifest',
      );
    }
    _verifyImmutableMediaIdentity(existing, promotion.media);
  }
}
