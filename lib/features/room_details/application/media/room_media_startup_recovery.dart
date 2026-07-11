import 'room_media_garbage_collector.dart';
import 'room_media_promotion_recovery.dart';

/// Completes every durable media repair before room UI may read its manifests.
///
/// Garbage collection is independent from promotion recovery and therefore
/// always runs, even when one or more promotion journals need user-visible
/// retry. The first failure is rethrown only after both passes finish.
final class RoomMediaStartupRecovery {
  const RoomMediaStartupRecovery({
    required RoomMediaPromotionRecovery promotionRecovery,
    required RoomMediaGarbageCollector garbageCollector,
    this.promotionTimeout = const Duration(seconds: 8),
    this.garbageTimeout = const Duration(seconds: 4),
  }) : _promotionRecovery = promotionRecovery,
       _garbageCollector = garbageCollector;

  final RoomMediaPromotionRecovery _promotionRecovery;
  final RoomMediaGarbageCollector _garbageCollector;
  final Duration promotionTimeout;
  final Duration garbageTimeout;

  Future<RoomMediaPromotionRecoveryReport> run() async {
    Object? promotionError;
    StackTrace? promotionStackTrace;
    RoomMediaPromotionRecoveryReport? report;
    try {
      report = await _promotionRecovery.recoverAll().timeout(promotionTimeout);
    } catch (error, stackTrace) {
      promotionError = error;
      promotionStackTrace = stackTrace;
    }

    try {
      await _garbageCollector.collect().timeout(garbageTimeout);
    } catch (error, stackTrace) {
      if (promotionError == null) {
        Error.throwWithStackTrace(error, stackTrace);
      }
    }

    if (promotionError != null) {
      Error.throwWithStackTrace(promotionError, promotionStackTrace!);
    }
    return report!;
  }
}
