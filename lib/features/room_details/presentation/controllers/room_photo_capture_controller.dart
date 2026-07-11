import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../shared/device/app_installation_identity.dart';
import '../../../../shared/media/capture/captured_photo_artifact.dart';
import '../../../../shared/media/local_media_artifact_store.dart';
import '../../../../shared/persistence/app_database_provider.dart';
import '../../../../shared/persistence/shared_preferences_settings_key_value_store.dart';
import '../../application/media/room_media_delete.dart';
import '../../application/media/room_media_garbage_collector.dart';
import '../../application/media/room_media_promotion_recovery.dart';
import '../../application/media/room_media_startup_recovery.dart';
import '../../application/media/room_photo_capture_save.dart';
import '../../application/media/room_photo_capture_state.dart';
import '../../data/repositories/drift_room_details_repository.dart';
import '../../domain/models/room_media_item.dart';
import '../../domain/repositories/room_media_garbage_repository.dart';
import '../../domain/repositories/room_media_promotion_repository.dart';
import 'room_details_controller.dart';

final roomMediaArtifactStoreProvider = Provider<MediaArtifactStore>((ref) {
  return LocalMediaArtifactStore(getApplicationSupportDirectory);
});

final roomMediaPromotionRepositoryProvider =
    Provider<RoomMediaPromotionRepository>((ref) {
      return DriftRoomMediaPromotionRepository(ref.watch(appDatabaseProvider));
    });

final roomMediaGarbageRepositoryProvider = Provider<RoomMediaGarbageRepository>(
  (ref) {
    return DriftRoomMediaGarbageRepository(ref.watch(appDatabaseProvider));
  },
);

final appInstallationIdentityProvider = FutureProvider<String>((ref) {
  return AppInstallationIdentity(
    store: SharedPreferencesSettingsKeyValueStore(),
  ).load();
});

final roomMediaRecoveryProvider =
    FutureProvider<RoomMediaPromotionRecoveryReport>((ref) {
      return _recoverRoomMedia(ref);
    });

Future<RoomMediaPromotionRecoveryReport> _recoverRoomMedia(Ref ref) async {
  final store = ref.watch(roomMediaArtifactStoreProvider);
  final elapsed = Stopwatch()..start();
  debugPrint('Начата startup recovery локальных медиа');
  try {
    final report = await RoomMediaStartupRecovery(
      promotionRecovery: RoomMediaPromotionRecovery(
        artifactStore: store,
        repository: ref.watch(roomMediaPromotionRepositoryProvider),
      ),
      garbageCollector: RoomMediaGarbageCollector(
        artifactStore: store,
        repository: ref.watch(roomMediaGarbageRepositoryProvider),
      ),
    ).run();
    debugPrint(
      'Startup recovery локальных медиа завершена за '
      '${elapsed.elapsedMilliseconds} ms: '
      'recovered=${report.recovered}, quarantined=${report.quarantined}',
    );
    return report;
  } catch (error, stackTrace) {
    debugPrint(
      'Ошибка startup recovery локальных медиа через '
      '${elapsed.elapsedMilliseconds} ms: $error',
    );
    debugPrintStack(stackTrace: stackTrace);
    rethrow;
  }
}

final roomPhotoCaptureControllerProvider = NotifierProvider.autoDispose
    .family<
      RoomPhotoCaptureController,
      RoomPhotoCaptureState,
      RoomDetailsRequest
    >(RoomPhotoCaptureController.new);

final class RoomPhotoCaptureController extends Notifier<RoomPhotoCaptureState> {
  RoomPhotoCaptureController(this.request);

  final RoomDetailsRequest request;
  late final RoomPhotoCaptureSave _save;
  late final RoomMediaDelete _delete;
  final _ids = _PhotoIdFactory();

  @override
  RoomPhotoCaptureState build() {
    _save = RoomPhotoCaptureSave(
      artifactStore: ref.watch(roomMediaArtifactStoreProvider),
      promotionRepository: ref.watch(roomMediaPromotionRepositoryProvider),
      releaseCapture: _releaseTransient,
    );
    _delete = RoomMediaDelete(
      repository: ref.watch(roomDetailsRepositoryProvider),
      artifactStore: ref.watch(roomMediaArtifactStoreProvider),
    );
    return const RoomPhotoCaptureState.idle();
  }

  Future<void> delete(RoomMediaItem media) async {
    if (state.isBusy) return;
    state = RoomPhotoCaptureState(
      phase: RoomPhotoCapturePhase.saving,
      statusText: 'Удаляю медиа...',
      mediaId: media.id,
    );
    try {
      await _delete(
        media: media,
        commandId: _ids.next('room-media-delete'),
        issuedAt: DateTime.now().toUtc(),
      );
      state = const RoomPhotoCaptureState(
        phase: RoomPhotoCapturePhase.saved,
        statusText: 'Медиа удалено',
      );
      ref.invalidate(roomDetailsControllerProvider(request));
    } catch (_) {
      state = RoomPhotoCaptureState(
        phase: RoomPhotoCapturePhase.failed,
        statusText: 'Не удалось удалить медиа',
        mediaId: media.id,
      );
    }
  }

  Future<void> save(CapturedPhotoArtifact capture) async {
    if (state.isBusy) return;
    final mediaId = _ids.next('photo-media');
    final operationId = _ids.next('photo-operation');
    state = RoomPhotoCaptureState(
      phase: RoomPhotoCapturePhase.saving,
      statusText: 'Сохраняю фото...',
      mediaId: mediaId,
    );
    try {
      final originDeviceId = await ref.read(
        appInstallationIdentityProvider.future,
      );
      await _save(
        capture: capture,
        originDeviceId: originDeviceId,
        operationId: operationId,
        mediaId: mediaId,
        sessionId: request.sessionId,
        roomNumber: request.roomNumber,
        issuedAt: DateTime.now().toUtc(),
      );
      state = RoomPhotoCaptureState(
        phase: RoomPhotoCapturePhase.saved,
        statusText: 'Фото сохранено локально',
        mediaId: mediaId,
      );
      ref.invalidate(roomDetailsControllerProvider(request));
    } catch (_) {
      state = RoomPhotoCaptureState(
        phase: RoomPhotoCapturePhase.failed,
        statusText: 'Не удалось сохранить фото',
        mediaId: mediaId,
      );
    }
  }

  static Future<void> _releaseTransient(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}

final class _PhotoIdFactory {
  final Random _random = Random.secure();

  String next(String prefix) {
    final micros = DateTime.now().toUtc().microsecondsSinceEpoch;
    final entropy = List.generate(
      4,
      (_) => _random.nextInt(0x10000).toRadixString(16).padLeft(4, '0'),
    ).join();
    return '$prefix-$micros-$entropy';
  }
}
