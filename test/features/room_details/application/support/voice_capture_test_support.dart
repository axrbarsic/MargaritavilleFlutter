import 'dart:async';

import 'package:interaction_foundation/interaction_foundation.dart';
import 'package:margaritaville_flutter/features/room_details/application/commands/room_details_command.dart';
import 'package:margaritaville_flutter/features/room_details/application/voice/room_voice_artifact_store.dart';
import 'package:margaritaville_flutter/features/room_details/application/voice/room_voice_capture_coordinator.dart';
import 'package:margaritaville_flutter/features/room_details/application/voice/room_voice_capture_save.dart';
import 'package:margaritaville_flutter/features/room_details/domain/models/room_details_snapshot.dart';
import 'package:margaritaville_flutter/features/room_details/domain/models/room_media_item.dart';
import 'package:margaritaville_flutter/features/room_details/domain/repositories/room_details_repository.dart';

RoomVoiceCaptureCoordinator makeVoiceCoordinator(
  VoiceCaptureBridge bridge,
  RoomVoiceArtifactStore store,
  RoomDetailsRepository repository,
) {
  var nextId = 0;
  return RoomVoiceCaptureCoordinator(
    sessionId: 'session-1',
    roomNumber: '101',
    bridge: bridge,
    saveCapture: RoomVoiceCaptureSave(
      artifactStore: store,
      repository: repository,
    ),
    idFactory: (prefix) => '$prefix-${nextId++}',
    now: () => DateTime.utc(2026, 7, 11, 12),
  );
}

VoiceCaptureEvent voiceEvent(
  int sequence,
  VoiceCapturePhase phase, {
  VoiceCaptureStatusCode status = VoiceCaptureStatusCode.recording,
  VoiceCaptureResult? result,
}) => VoiceCaptureEvent(
  contractVersion: 1,
  operationId: 'voice-operation-0',
  sequence: sequence,
  phase: phase,
  statusCode: status,
  result: result,
);

VoiceCaptureResult voiceResult({
  String? recognizedText = '  Готово, номер 101.  ',
}) => VoiceCaptureResult(
  contractVersion: 1,
  operationId: 'voice-operation-0',
  resultId: 'native-result-1',
  temporaryFilePath: '/tmp/voice.m4a',
  originDeviceId: 'iphone-1',
  createdAtMicros: 1783785600000000,
  durationMs: 1450,
  byteLength: 42,
  mimeType: 'audio/mp4',
  codec: 'aac',
  sampleRateHz: 44100,
  channelCount: 1,
  recognizedText: recognizedText,
);

final class FakeVoiceBridge implements VoiceCaptureBridge {
  FakeVoiceBridge(this.log);

  final List<String> log;
  final Map<String, VoiceCaptureEventListener> listeners = {};
  bool failRelease = false;

  void emit(VoiceCaptureEvent event) =>
      listeners[event.operationId]?.call(event);

  @override
  Future<VoiceCaptureCapabilities> getCapabilities({
    String localeIdentifier = VoiceCaptureContract.defaultLocaleIdentifier,
  }) async => const VoiceCaptureCapabilities(
    contractVersion: 1,
    supported: true,
    speechPermission: VoicePermissionState.granted,
    microphonePermission: VoicePermissionState.granted,
    recognizerAvailable: true,
  );

  @override
  Future<VoiceCaptureAcknowledgement> startCapture(
    VoiceCaptureStartRequest request,
  ) async => VoiceCaptureAcknowledgement(
    contractVersion: 1,
    operationId: request.operationId,
    accepted: true,
    statusCode: VoiceCaptureStatusCode.recording,
  );

  @override
  Future<VoiceCaptureAcknowledgement> stopCapture(String operationId) async =>
      VoiceCaptureAcknowledgement(
        contractVersion: 1,
        operationId: operationId,
        accepted: true,
        statusCode: VoiceCaptureStatusCode.finishingTranscription,
      );

  @override
  Future<VoiceCaptureAcknowledgement> cancelCapture(String operationId) async {
    log.add('cancel');
    return VoiceCaptureAcknowledgement(
      contractVersion: 1,
      operationId: operationId,
      accepted: true,
      statusCode: VoiceCaptureStatusCode.cancelled,
    );
  }

  @override
  Future<void> releaseResult(String resultId) async {
    log.add('release');
    if (failRelease) throw StateError('cleanup failed');
  }

  @override
  VoiceCaptureEventSubscription subscribe(
    String operationId,
    VoiceCaptureEventListener listener, {
    bool replayLatest = true,
  }) {
    listeners[operationId] = listener;
    return VoiceCaptureEventSubscription(() => listeners.remove(operationId));
  }

  @override
  VoiceCaptureEventSubscription subscribeAll(
    VoiceCaptureEventListener listener,
  ) => VoiceCaptureEventSubscription(() {});

  @override
  void forgetOperation(String operationId) => listeners.remove(operationId);
}

final class FakeVoiceArtifactStore implements RoomVoiceArtifactStore {
  FakeVoiceArtifactStore(this.log);

  final List<String> log;
  Completer<void>? persistGate;

  @override
  Future<StoredRoomVoiceArtifact> persist(RoomVoiceArtifactInput input) async {
    log.add('persist');
    await persistGate?.future;
    return const StoredRoomVoiceArtifact(
      relativePath: 'Media/voice-media-1.m4a',
      checksumSha256: 'sha256',
      byteLength: 42,
      created: true,
    );
  }

  @override
  Future<void> remove(String relativePath) async => log.add('remove');
}

final class FakeRoomDetailsRepository implements RoomDetailsRepository {
  FakeRoomDetailsRepository(this.log);

  final List<String> log;
  final List<RoomMediaItem> media = [];
  int failCommits = 0;

  @override
  Future<RoomDetailsCommitStatus> commit(RoomDetailsCommand command) async {
    log.add('commit');
    if (failCommits-- > 0) throw StateError('database failed');
    if (command case AddRoomMediaCommand(media: final capturedMedia)) {
      media.add(capturedMedia);
    }
    return RoomDetailsCommitStatus.applied;
  }

  @override
  Future<RoomDetailsSnapshot> load({
    required String sessionId,
    required String roomNumber,
  }) async => RoomDetailsSnapshot(
    sessionId: sessionId,
    roomNumber: roomNumber,
    media: media,
  );
}
