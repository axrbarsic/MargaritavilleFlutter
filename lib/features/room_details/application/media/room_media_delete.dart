import '../../../../shared/media/local_media_artifact_store.dart';
import '../../domain/models/room_media_item.dart';
import '../../domain/repositories/room_details_repository.dart';
import '../commands/room_details_command.dart';

final class RoomMediaDelete {
  const RoomMediaDelete({
    required RoomDetailsRepository repository,
    required MediaArtifactStore artifactStore,
  }) : _repository = repository,
       _artifactStore = artifactStore;

  final RoomDetailsRepository _repository;
  final MediaArtifactStore _artifactStore;

  Future<void> call({
    required RoomMediaItem media,
    required String commandId,
    required DateTime issuedAt,
  }) async {
    final status = await _repository.commit(
      DeleteRoomMediaCommand(
        commandId: commandId,
        sessionId: media.sessionId,
        roomNumber: media.roomNumber,
        issuedAt: issuedAt,
        mediaId: media.id,
      ),
    );
    if (status == RoomDetailsCommitStatus.ignored) {
      throw StateError('Медиа не было удалено из локального хранилища');
    }
    if (status == RoomDetailsCommitStatus.duplicate) {
      final snapshot = await _repository.load(
        sessionId: media.sessionId,
        roomNumber: media.roomNumber,
      );
      if (snapshot.media.any((item) => item.id == media.id)) {
        throw StateError('Повтор удаления не подтвердил tombstone');
      }
    }
    try {
      await _artifactStore.removeFinal(media.relativePath);
    } catch (_) {
      // Tombstone is durable; startup garbage collection will retry the file.
    }
  }
}
