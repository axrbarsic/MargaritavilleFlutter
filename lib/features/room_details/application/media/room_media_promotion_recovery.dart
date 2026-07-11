import 'dart:io';

import '../../../../shared/media/local_media_artifact_store.dart';
import '../../domain/models/pending_room_media_promotion.dart';
import '../../domain/repositories/room_details_repository.dart';
import '../../domain/repositories/room_media_promotion_repository.dart';

final class RoomMediaPromotionRecoveryFailure {
  const RoomMediaPromotionRecoveryFailure({
    required this.operationId,
    required this.error,
    required this.stackTrace,
  });

  final String operationId;
  final Object error;
  final StackTrace stackTrace;
}

final class RoomMediaPromotionRecoveryException implements Exception {
  const RoomMediaPromotionRecoveryException({
    required this.failures,
    required this.recovered,
    required this.quarantined,
  });

  final List<RoomMediaPromotionRecoveryFailure> failures;
  final int recovered;
  final int quarantined;

  @override
  String toString() =>
      'Не удалось восстановить ${failures.length} медиаопераций';
}

final class RoomMediaPromotionRecoveryReport {
  const RoomMediaPromotionRecoveryReport({
    required this.recovered,
    required this.quarantined,
  });

  final int recovered;
  final int quarantined;
}

enum _RecoveryOutcome { recovered, quarantined }

final class RoomMediaPromotionRecovery {
  const RoomMediaPromotionRecovery({
    required MediaArtifactStore artifactStore,
    required RoomMediaPromotionRepository repository,
  }) : _artifactStore = artifactStore,
       _repository = repository;

  final MediaArtifactStore _artifactStore;
  final RoomMediaPromotionRepository _repository;

  Future<RoomMediaPromotionRecoveryReport> recoverAll() async {
    final failures = <RoomMediaPromotionRecoveryFailure>[];
    var recovered = 0;
    var quarantined = 0;
    for (final promotion in await _repository.pendingMediaPromotions()) {
      try {
        switch (await _recover(promotion)) {
          case _RecoveryOutcome.recovered:
            recovered += 1;
          case _RecoveryOutcome.quarantined:
            quarantined += 1;
        }
      } catch (error, stackTrace) {
        failures.add(
          RoomMediaPromotionRecoveryFailure(
            operationId: promotion.operationId,
            error: error,
            stackTrace: stackTrace,
          ),
        );
      }
    }
    if (failures.isNotEmpty) {
      throw RoomMediaPromotionRecoveryException(
        failures: List.unmodifiable(failures),
        recovered: recovered,
        quarantined: quarantined,
      );
    }
    return RoomMediaPromotionRecoveryReport(
      recovered: recovered,
      quarantined: quarantined,
    );
  }

  Future<_RecoveryOutcome> _recover(PendingRoomMediaPromotion promotion) async {
    final prepared = PreparedMediaArtifact(
      mediaId: promotion.media.id,
      transientFilePath: promotion.transientFilePath,
      stagedRelativePath: promotion.stagedRelativePath,
      finalRelativePath: promotion.media.relativePath,
      checksumSha256: promotion.media.checksumSha256,
      byteLength: promotion.byteLength,
      originalExtension: promotion.media.originalExtension!,
      mimeType: promotion.media.mimeType!,
    );
    StagedMediaArtifact artifact;
    try {
      artifact = await _artifactStore.stagePrepared(prepared);
      await _artifactStore.promote(artifact);
    } on MediaArtifactSourceMissing catch (error) {
      return _quarantine(promotion, error);
    } on MediaArtifactIntegrityConflict catch (error) {
      return _quarantine(promotion, error);
    }
    final status = await _repository.completeMediaPromotion(
      promotion.operationId,
    );
    if (status == RoomDetailsCommitStatus.ignored) {
      return _quarantine(
        promotion,
        StateError(
          'Восстановленное фото ${promotion.media.id} не было опубликовано',
        ),
      );
    }
    await _releaseTransient(promotion.transientFilePath);
    return _RecoveryOutcome.recovered;
  }

  Future<_RecoveryOutcome> _quarantine(
    PendingRoomMediaPromotion promotion,
    Object error,
  ) async {
    final rawReason = error.toString();
    final reason = rawReason.length <= 500
        ? rawReason
        : rawReason.substring(0, 500);
    await _repository.quarantineMediaPromotion(
      promotion.operationId,
      reason: reason,
      detectedAt: DateTime.now().toUtc(),
    );
    await _releaseTransient(promotion.transientFilePath);
    return _RecoveryOutcome.quarantined;
  }

  static Future<void> _releaseTransient(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {
      // The promotion has a durable terminal state; cache cleanup is best-effort.
    }
  }
}
