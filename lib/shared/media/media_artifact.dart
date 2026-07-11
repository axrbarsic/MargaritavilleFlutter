import 'dart:io';

typedef ApplicationSupportDirectoryProvider = Future<Directory> Function();

enum MediaArtifactPresence { missing, staged, promoted }

final class MediaArtifactSourceMissing implements Exception {
  const MediaArtifactSourceMissing(this.path);

  final String path;

  @override
  String toString() => 'Transient media source is missing: $path';
}

final class MediaArtifactIntegrityConflict implements Exception {
  const MediaArtifactIntegrityConflict(this.message);

  final String message;

  @override
  String toString() => message;
}

final class MediaArtifactInput {
  const MediaArtifactInput({
    required this.mediaId,
    required this.transientFilePath,
    required this.expectedByteLength,
    required this.originalExtension,
    required this.mimeType,
  });

  final String mediaId;
  final String transientFilePath;
  final int expectedByteLength;
  final String originalExtension;
  final String mimeType;
}

final class StagedMediaArtifact {
  const StagedMediaArtifact({
    required this.mediaId,
    required this.stagedRelativePath,
    required this.finalRelativePath,
    required this.checksumSha256,
    required this.byteLength,
    required this.originalExtension,
    required this.mimeType,
    required this.created,
    required this.alreadyPromoted,
  });

  final String mediaId;
  final String stagedRelativePath;
  final String finalRelativePath;
  final String checksumSha256;
  final int byteLength;
  final String originalExtension;
  final String mimeType;
  final bool created;
  final bool alreadyPromoted;
}

final class PreparedMediaArtifact {
  const PreparedMediaArtifact({
    required this.mediaId,
    required this.transientFilePath,
    required this.stagedRelativePath,
    required this.finalRelativePath,
    required this.checksumSha256,
    required this.byteLength,
    required this.originalExtension,
    required this.mimeType,
  });

  final String mediaId;
  final String transientFilePath;
  final String stagedRelativePath;
  final String finalRelativePath;
  final String checksumSha256;
  final int byteLength;
  final String originalExtension;
  final String mimeType;
}

final class PromotedMediaArtifact {
  const PromotedMediaArtifact({
    required this.relativePath,
    required this.absolutePath,
    required this.checksumSha256,
    required this.byteLength,
    required this.created,
  });

  final String relativePath;
  final String absolutePath;
  final String checksumSha256;
  final int byteLength;
  final bool created;
}

abstract interface class MediaArtifactStore {
  Future<PreparedMediaArtifact> prepare(MediaArtifactInput input);

  Future<StagedMediaArtifact> stage(MediaArtifactInput input);

  Future<StagedMediaArtifact> stagePrepared(PreparedMediaArtifact artifact);

  Future<PromotedMediaArtifact> promote(StagedMediaArtifact artifact);

  Future<MediaArtifactPresence> inspect(StagedMediaArtifact artifact);

  Future<void> discardStage(StagedMediaArtifact artifact);

  Future<void> removeFinal(String relativePath);

  Future<String> resolveFinalPath(String relativePath);
}
