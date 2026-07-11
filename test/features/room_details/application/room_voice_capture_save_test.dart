import 'package:flutter_test/flutter_test.dart';
import 'package:interaction_foundation/interaction_foundation.dart';
import 'package:margaritaville_flutter/features/room_details/application/commands/room_details_command.dart';
import 'package:margaritaville_flutter/features/room_details/application/voice/room_voice_artifact_store.dart';
import 'package:margaritaville_flutter/features/room_details/application/voice/room_voice_capture_save.dart';
import 'package:margaritaville_flutter/features/room_details/domain/models/room_details_snapshot.dart';
import 'package:margaritaville_flutter/features/room_details/domain/models/room_media_item.dart';
import 'package:margaritaville_flutter/features/room_details/domain/repositories/room_details_repository.dart';

void main() {
  test('duplicate succeeds only when projection has identical media', () async {
    final store = _Store(created: false);
    final repository = _Repository(RoomDetailsCommitStatus.duplicate);
    repository.projected.add(_expectedMedia());

    final media = await _save(store, repository)();

    expect(media.id, 'voice-media');
    expect(store.removed, isEmpty);
  });

  test('duplicate without projection is rejected', () async {
    final store = _Store(created: true);
    final repository = _Repository(RoomDetailsCommitStatus.duplicate);

    await expectLater(_save(store, repository)(), throwsStateError);

    expect(store.removed, ['Media/voice-media.m4a']);
  });

  test('ignored commit rolls back only a newly created artifact', () async {
    final store = _Store(created: true);
    final repository = _Repository(RoomDetailsCommitStatus.ignored);

    await expectLater(_save(store, repository)(), throwsStateError);

    expect(store.removed, ['Media/voice-media.m4a']);
  });

  test(
    'transient failure never deletes a reused crash-recovery artifact',
    () async {
      final store = _Store(created: false);
      final repository = _Repository(RoomDetailsCommitStatus.applied)
        ..failure = StateError('transient');

      await expectLater(_save(store, repository)(), throwsStateError);

      expect(store.removed, isEmpty);
    },
  );
}

Future<RoomMediaItem> Function() _save(
  RoomVoiceArtifactStore store,
  RoomDetailsRepository repository,
) {
  final useCase = RoomVoiceCaptureSave(
    artifactStore: store,
    repository: repository,
  );
  return () => useCase(
    result: _result(),
    mediaId: 'voice-media',
    sessionId: 'session-1',
    roomNumber: '101',
    issuedAt: DateTime.utc(2026, 7, 11, 12),
  );
}

VoiceCaptureResult _result() => const VoiceCaptureResult(
  contractVersion: 1,
  operationId: 'operation-1',
  resultId: 'result-1',
  temporaryFilePath: '/tmp/result.m4a',
  originDeviceId: 'iphone-1',
  createdAtMicros: 1783785600000000,
  durationMs: 1000,
  byteLength: 10,
  mimeType: 'audio/mp4',
  codec: 'aac',
  sampleRateHz: 44100,
  channelCount: 1,
  recognizedText: 'Тест',
);

RoomMediaItem _expectedMedia() => RoomMediaItem(
  id: 'voice-media',
  sessionId: 'session-1',
  roomNumber: '101',
  kind: RoomMediaKind.voice,
  relativePath: 'Media/voice-media.m4a',
  checksumSha256: 'sha256',
  originDeviceId: 'iphone-1',
  createdAt: DateTime.fromMicrosecondsSinceEpoch(1783785600000000, isUtc: true),
  updatedAt: DateTime.utc(2026, 7, 11, 12),
  mimeType: 'audio/mp4',
  duration: const Duration(seconds: 1),
  transcript: 'Тест',
);

final class _Store implements RoomVoiceArtifactStore {
  _Store({required this.created});

  final bool created;
  final List<String> removed = [];

  @override
  Future<StoredRoomVoiceArtifact> persist(RoomVoiceArtifactInput input) async =>
      StoredRoomVoiceArtifact(
        relativePath: 'Media/voice-media.m4a',
        checksumSha256: 'sha256',
        byteLength: 10,
        created: created,
      );

  @override
  Future<void> remove(String relativePath) async => removed.add(relativePath);
}

final class _Repository implements RoomDetailsRepository {
  _Repository(this.status);

  final RoomDetailsCommitStatus status;
  final List<RoomMediaItem> projected = [];
  Object? failure;

  @override
  Future<RoomDetailsCommitStatus> commit(RoomDetailsCommand command) async {
    final error = failure;
    if (error != null) throw error;
    return status;
  }

  @override
  Future<RoomDetailsSnapshot> load({
    required String sessionId,
    required String roomNumber,
  }) async => RoomDetailsSnapshot(
    sessionId: sessionId,
    roomNumber: roomNumber,
    media: projected,
  );
}
