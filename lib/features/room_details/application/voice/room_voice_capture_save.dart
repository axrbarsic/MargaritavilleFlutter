import 'package:interaction_foundation/interaction_foundation.dart';

import '../../domain/models/room_media_item.dart';
import '../../domain/repositories/room_details_repository.dart';
import '../commands/room_details_command.dart';
import 'room_voice_artifact_store.dart';
import 'room_voice_capture_status.dart';

final class RoomVoiceCaptureSave {
  const RoomVoiceCaptureSave({
    required RoomVoiceArtifactStore artifactStore,
    required RoomDetailsRepository repository,
  }) : _artifactStore = artifactStore,
       _repository = repository;

  final RoomVoiceArtifactStore _artifactStore;
  final RoomDetailsRepository _repository;

  Future<RoomMediaItem> call({
    required VoiceCaptureResult result,
    required String mediaId,
    required String sessionId,
    required String roomNumber,
    required DateTime issuedAt,
  }) async {
    final artifact = await _artifactStore.persist(
      RoomVoiceArtifactInput(
        mediaId: mediaId,
        temporaryFilePath: result.temporaryFilePath,
        expectedByteLength: result.byteLength,
      ),
    );
    final createdAt = DateTime.fromMicrosecondsSinceEpoch(
      result.createdAtMicros,
      isUtc: true,
    );
    final media = RoomMediaItem(
      id: mediaId,
      sessionId: sessionId,
      roomNumber: roomNumber,
      kind: RoomMediaKind.voice,
      relativePath: artifact.relativePath,
      checksumSha256: artifact.checksumSha256,
      originDeviceId: result.originDeviceId,
      createdAt: createdAt,
      updatedAt: issuedAt,
      mimeType: result.mimeType,
      duration: Duration(milliseconds: result.durationMs),
      transcript: normalizeVoiceTranscript(result.recognizedText),
    );
    try {
      final status = await _repository.commit(
        AddRoomMediaCommand(
          commandId: 'room-voice:$mediaId',
          sessionId: sessionId,
          roomNumber: roomNumber,
          issuedAt: issuedAt,
          media: media,
        ),
      );
      if (status == RoomDetailsCommitStatus.ignored) {
        throw StateError('Запись не была принята локальным хранилищем');
      }
      if (status == RoomDetailsCommitStatus.duplicate) {
        await _verifyDuplicate(media);
      }
      return media;
    } catch (_) {
      if (artifact.created) {
        await _artifactStore.remove(artifact.relativePath);
      }
      rethrow;
    }
  }

  Future<void> _verifyDuplicate(RoomMediaItem expected) async {
    final snapshot = await _repository.load(
      sessionId: expected.sessionId,
      roomNumber: expected.roomNumber,
    );
    final matches = snapshot.media.any(
      (item) =>
          item.id == expected.id &&
          item.relativePath == expected.relativePath &&
          item.checksumSha256 == expected.checksumSha256,
    );
    if (!matches) {
      throw StateError('Повтор команды не подтвердил сохранённую запись');
    }
  }
}
