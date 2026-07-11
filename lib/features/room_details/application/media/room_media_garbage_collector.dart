import '../../../../shared/media/local_media_artifact_store.dart';
import '../../domain/repositories/room_media_garbage_repository.dart';

final class RoomMediaGarbageCollector {
  const RoomMediaGarbageCollector({
    required RoomMediaGarbageRepository repository,
    required MediaArtifactStore artifactStore,
  }) : _repository = repository,
       _artifactStore = artifactStore;

  final RoomMediaGarbageRepository _repository;
  final MediaArtifactStore _artifactStore;

  Future<void> collect() async {
    for (final media in await _repository.tombstonedMedia()) {
      try {
        await _artifactStore.removeFinal(media.relativePath);
      } catch (_) {
        // Keep the tombstone; the next startup retries this idempotently.
      }
    }
  }
}
