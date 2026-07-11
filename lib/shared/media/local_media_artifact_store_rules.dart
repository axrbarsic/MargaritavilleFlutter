part of 'local_media_artifact_store.dart';

final RegExp _safeId = RegExp(r'^[A-Za-z0-9][A-Za-z0-9_-]{0,127}$');
final RegExp _safeExtension = RegExp(r'^[A-Za-z0-9]{1,10}$');
final RegExp _safeMime = RegExp(
  r'^[A-Za-z0-9][A-Za-z0-9!#$&^_.+-]*/[A-Za-z0-9][A-Za-z0-9!#$&^_.+-]*$',
);
final RegExp _safeFinalPath = RegExp(
  r'^Media/[A-Za-z0-9][A-Za-z0-9_-]{0,127}\.[A-Za-z0-9]{1,10}$',
);

typedef _NormalizedInput = ({
  String mediaId,
  String transientFilePath,
  int expectedByteLength,
  String extension,
  String mimeType,
});

_NormalizedInput _normalize(MediaArtifactInput input) {
  if (!_safeId.hasMatch(input.mediaId)) {
    throw ArgumentError.value(input.mediaId, 'mediaId', 'Unsafe media id');
  }
  final extension = input.originalExtension.startsWith('.')
      ? input.originalExtension.substring(1)
      : input.originalExtension;
  final normalizedExtension = extension.toLowerCase();
  if (!_safeExtension.hasMatch(normalizedExtension)) {
    throw ArgumentError.value(
      input.originalExtension,
      'originalExtension',
      'Unsafe media extension',
    );
  }
  if (!_safeMime.hasMatch(input.mimeType)) {
    throw ArgumentError.value(input.mimeType, 'mimeType', 'Unsafe MIME type');
  }
  final source = File(input.transientFilePath);
  if (input.transientFilePath.contains('\u0000') ||
      source.absolute.path != input.transientFilePath) {
    throw ArgumentError.value(
      input.transientFilePath,
      'transientFilePath',
      'Transient path must be absolute',
    );
  }
  if (input.expectedByteLength < 0) {
    throw ArgumentError.value(
      input.expectedByteLength,
      'expectedByteLength',
      'Negative media length',
    );
  }
  return (
    mediaId: input.mediaId,
    transientFilePath: input.transientFilePath,
    expectedByteLength: input.expectedByteLength,
    extension: normalizedExtension,
    mimeType: input.mimeType.toLowerCase(),
  );
}

void _validateArtifact(StagedMediaArtifact artifact) {
  if (!_safeId.hasMatch(artifact.mediaId) ||
      !_safeExtension.hasMatch(artifact.originalExtension) ||
      !_safeMime.hasMatch(artifact.mimeType)) {
    throw ArgumentError('Unsafe staged media identity');
  }
  final expected = _paths(artifact.mediaId, artifact.originalExtension);
  if (artifact.stagedRelativePath != expected.staged ||
      artifact.finalRelativePath != expected.finalPath ||
      artifact.byteLength < 0 ||
      !RegExp(r'^[a-f0-9]{64}$').hasMatch(artifact.checksumSha256)) {
    throw ArgumentError('Unsafe staged media paths or metadata');
  }
}

void _validatePrepared(PreparedMediaArtifact artifact) {
  final source = File(artifact.transientFilePath);
  final expected = _paths(artifact.mediaId, artifact.originalExtension);
  if (!_safeId.hasMatch(artifact.mediaId) ||
      !_safeExtension.hasMatch(artifact.originalExtension) ||
      !_safeMime.hasMatch(artifact.mimeType) ||
      artifact.transientFilePath.contains('\u0000') ||
      source.absolute.path != artifact.transientFilePath ||
      artifact.stagedRelativePath != expected.staged ||
      artifact.finalRelativePath != expected.finalPath ||
      artifact.byteLength <= 0 ||
      !RegExp(r'^[a-f0-9]{64}$').hasMatch(artifact.checksumSha256)) {
    throw ArgumentError('Unsafe prepared media artifact');
  }
}

void _validateFinalPath(String path) {
  if (!_safeFinalPath.hasMatch(path)) {
    throw ArgumentError.value(path, 'relativePath', 'Unsafe final media path');
  }
}

({String staged, String finalPath}) _paths(String mediaId, String extension) =>
    (
      staged: 'Media/.staging/$mediaId.$extension.partial',
      finalPath: 'Media/$mediaId.$extension',
    );
