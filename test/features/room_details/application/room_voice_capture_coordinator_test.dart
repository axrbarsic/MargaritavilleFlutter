import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:interaction_foundation/interaction_foundation.dart';
import 'package:margaritaville_flutter/features/room_details/application/voice/room_voice_capture_state.dart';

import 'support/voice_capture_test_support.dart';

void main() {
  test('persists, commits, then releases native result', () async {
    final log = <String>[];
    final bridge = FakeVoiceBridge(log);
    final store = FakeVoiceArtifactStore(log);
    final repository = FakeRoomDetailsRepository(log);
    final coordinator = makeVoiceCoordinator(bridge, store, repository);
    addTearDown(coordinator.dispose);

    await coordinator.toggle();
    bridge.emit(voiceEvent(1, VoiceCapturePhase.recording));
    expect(coordinator.state.phase, RoomVoiceCapturePhase.recording);
    await coordinator.toggle();
    bridge.emit(
      voiceEvent(
        3,
        VoiceCapturePhase.completed,
        status: VoiceCaptureStatusCode.completed,
        result: voiceResult(),
      ),
    );
    await coordinator.states.firstWhere(
      (state) => state.phase == RoomVoiceCapturePhase.saved,
    );

    expect(log, containsAllInOrder(['persist', 'commit', 'release']));
    expect(repository.media.single.transcript, 'Готово, номер 101.');
    expect(repository.media.single.checksumSha256, 'sha256');
  });

  test(
    'repository failure rolls back new file but retains native result',
    () async {
      final log = <String>[];
      final bridge = FakeVoiceBridge(log);
      final store = FakeVoiceArtifactStore(log);
      final repository = FakeRoomDetailsRepository(log)..failCommits = 1;
      final coordinator = makeVoiceCoordinator(bridge, store, repository);
      addTearDown(coordinator.dispose);

      await coordinator.toggle();
      bridge.emit(voiceEvent(1, VoiceCapturePhase.recording));
      bridge.emit(
        voiceEvent(2, VoiceCapturePhase.completed, result: voiceResult()),
      );
      await coordinator.states.firstWhere((state) => state.canRetrySave);

      expect(log, containsAllInOrder(['persist', 'commit', 'remove']));
      expect(log, isNot(contains('release')));
      await coordinator.toggle();
      expect(coordinator.state.phase, RoomVoiceCapturePhase.saved);
      expect(log.last, 'release');
    },
  );

  test('native temp cleanup failure never removes durable app media', () async {
    final log = <String>[];
    final bridge = FakeVoiceBridge(log)..failRelease = true;
    final store = FakeVoiceArtifactStore(log);
    final repository = FakeRoomDetailsRepository(log);
    final coordinator = makeVoiceCoordinator(bridge, store, repository);
    addTearDown(coordinator.dispose);

    await coordinator.toggle();
    bridge.emit(voiceEvent(1, VoiceCapturePhase.recording));
    bridge.emit(
      voiceEvent(2, VoiceCapturePhase.completed, result: voiceResult()),
    );
    await coordinator.states.firstWhere(
      (state) => state.phase == RoomVoiceCapturePhase.saved,
    );

    expect(log, containsAllInOrder(['persist', 'commit', 'release']));
    expect(log, isNot(contains('remove')));
  });

  test('microphone denial is Russian and never creates media', () async {
    final log = <String>[];
    final bridge = FakeVoiceBridge(log);
    final coordinator = makeVoiceCoordinator(
      bridge,
      FakeVoiceArtifactStore(log),
      FakeRoomDetailsRepository(log),
    );
    addTearDown(coordinator.dispose);

    await coordinator.toggle();
    bridge.emit(
      voiceEvent(
        1,
        VoiceCapturePhase.failed,
        status: VoiceCaptureStatusCode.microphoneDenied,
      ),
    );

    expect(coordinator.state.phase, RoomVoiceCapturePhase.failed);
    expect(coordinator.state.statusText, 'Нет доступа к микрофону');
    expect(log, isNot(contains('persist')));
  });

  test(
    'speech denial still saves audio and reports unavailable recognition',
    () async {
      final log = <String>[];
      final repository = FakeRoomDetailsRepository(log);
      final bridge = FakeVoiceBridge(log);
      final coordinator = makeVoiceCoordinator(
        bridge,
        FakeVoiceArtifactStore(log),
        repository,
      );
      addTearDown(coordinator.dispose);

      await coordinator.toggle();
      bridge.emit(voiceEvent(1, VoiceCapturePhase.recording));
      bridge.emit(
        voiceEvent(
          2,
          VoiceCapturePhase.completed,
          status: VoiceCaptureStatusCode.speechUnavailable,
          result: voiceResult(recognizedText: null),
        ),
      );
      await coordinator.states.firstWhere(
        (state) => state.phase == RoomVoiceCapturePhase.saved,
      );

      expect(coordinator.state.statusText, 'Распознавание недоступно');
      expect(repository.media.single.transcript, isNull);
      expect(log, containsAllInOrder(['persist', 'commit', 'release']));
    },
  );

  test('dispose during transcription cancels the native operation', () async {
    final log = <String>[];
    final bridge = FakeVoiceBridge(log);
    final coordinator = makeVoiceCoordinator(
      bridge,
      FakeVoiceArtifactStore(log),
      FakeRoomDetailsRepository(log),
    );

    await coordinator.toggle();
    bridge.emit(voiceEvent(1, VoiceCapturePhase.recording));
    await coordinator.toggle();
    expect(coordinator.state.phase, RoomVoiceCapturePhase.finishing);
    await coordinator.dispose();

    expect(log, contains('cancel'));
  });

  test(
    'abandoning a failed save releases its retained native result',
    () async {
      final log = <String>[];
      final bridge = FakeVoiceBridge(log);
      final repository = FakeRoomDetailsRepository(log)..failCommits = 1;
      final coordinator = makeVoiceCoordinator(
        bridge,
        FakeVoiceArtifactStore(log),
        repository,
      );
      addTearDown(coordinator.dispose);

      await coordinator.toggle();
      bridge.emit(voiceEvent(1, VoiceCapturePhase.recording));
      bridge.emit(
        voiceEvent(2, VoiceCapturePhase.completed, result: voiceResult()),
      );
      await coordinator.states.firstWhere((state) => state.canRetrySave);
      await coordinator.cancel();

      expect(log, containsAllInOrder(['remove', 'release']));
      expect(coordinator.state.phase, RoomVoiceCapturePhase.idle);
    },
  );

  test(
    'dispose waits for an in-flight durable copy before releasing temp',
    () async {
      final log = <String>[];
      final bridge = FakeVoiceBridge(log);
      final store = FakeVoiceArtifactStore(log)
        ..persistGate = Completer<void>();
      final coordinator = makeVoiceCoordinator(
        bridge,
        store,
        FakeRoomDetailsRepository(log),
      );

      await coordinator.toggle();
      bridge.emit(voiceEvent(1, VoiceCapturePhase.recording));
      bridge.emit(
        voiceEvent(2, VoiceCapturePhase.completed, result: voiceResult()),
      );
      await Future<void>.delayed(Duration.zero);
      expect(log, contains('persist'));

      final disposing = coordinator.dispose();
      await Future<void>.delayed(Duration.zero);
      expect(log, isNot(contains('release')));
      store.persistGate!.complete();
      await disposing;

      expect(log, containsAllInOrder(['persist', 'commit', 'release']));
    },
  );
}
