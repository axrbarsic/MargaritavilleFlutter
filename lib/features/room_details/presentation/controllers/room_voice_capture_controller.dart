import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interaction_foundation/interaction_foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../application/voice/room_voice_artifact_store.dart';
import '../../application/voice/room_voice_capture_coordinator.dart';
import '../../application/voice/room_voice_capture_save.dart';
import '../../application/voice/room_voice_capture_state.dart';
import 'room_details_controller.dart';

final voiceCaptureBridgeProvider = Provider<VoiceCaptureBridge>((ref) {
  return PigeonVoiceCaptureBridge();
});

final roomVoiceArtifactStoreProvider = Provider<RoomVoiceArtifactStore>((ref) {
  return LocalRoomVoiceArtifactStore(getApplicationSupportDirectory);
});

final roomVoiceCaptureControllerProvider = NotifierProvider.autoDispose
    .family<
      RoomVoiceCaptureController,
      RoomVoiceCaptureState,
      RoomDetailsRequest
    >(RoomVoiceCaptureController.new);

final class RoomVoiceCaptureController extends Notifier<RoomVoiceCaptureState> {
  RoomVoiceCaptureController(this.request);

  final RoomDetailsRequest request;
  late final RoomVoiceCaptureCoordinator _coordinator;
  StreamSubscription<RoomVoiceCaptureState>? _subscription;

  @override
  RoomVoiceCaptureState build() {
    final repository = ref.watch(roomDetailsRepositoryProvider);
    _coordinator = RoomVoiceCaptureCoordinator(
      sessionId: request.sessionId,
      roomNumber: request.roomNumber,
      bridge: ref.watch(voiceCaptureBridgeProvider),
      saveCapture: RoomVoiceCaptureSave(
        artifactStore: ref.watch(roomVoiceArtifactStoreProvider),
        repository: repository,
      ),
      idFactory: _VoiceIdFactory().next,
      now: DateTime.now,
    );
    _subscription = _coordinator.states.listen((next) {
      state = next;
      if (next.phase == RoomVoiceCapturePhase.saved) {
        ref.invalidate(roomDetailsControllerProvider(request));
      }
    });
    ref.onDispose(() {
      unawaited(_subscription?.cancel());
      unawaited(_coordinator.dispose());
    });
    unawaited(_coordinator.initialize());
    return _coordinator.state;
  }

  Future<void> toggle() => _coordinator.toggle();

  Future<void> cancel() => _coordinator.cancel();
}

final class _VoiceIdFactory {
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
