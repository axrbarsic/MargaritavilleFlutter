import 'dart:io';

import 'package:crypto/crypto.dart';

import 'media_artifact.dart';

export 'media_artifact.dart';

part 'local_media_artifact_store_rules.dart';

/// Byte-preserving local media storage split around a durable journal boundary.
///
/// [prepare] only verifies and describes the transient source. The caller must
/// persist that descriptor in its crash journal before [stagePrepared] creates
/// a same-volume `.partial` file. [promote] then performs the atomic final
/// rename. This ordering makes every app-owned file recoverable by construction.
final class LocalMediaArtifactStore implements MediaArtifactStore {
  const LocalMediaArtifactStore(this._supportDirectoryProvider);

  final ApplicationSupportDirectoryProvider _supportDirectoryProvider;

  @override
  Future<PreparedMediaArtifact> prepare(MediaArtifactInput input) async {
    final normalized = _normalize(input);
    final paths = _paths(normalized.mediaId, normalized.extension);
    final source = File(normalized.transientFilePath);
    final sourceStat = await source.stat();
    if (sourceStat.type != FileSystemEntityType.file) {
      throw MediaArtifactSourceMissing(source.path);
    }
    if (sourceStat.size != normalized.expectedByteLength) {
      throw StateError('Transient media length does not match native metadata');
    }
    final sourceChecksum = await _checksum(source);
    return PreparedMediaArtifact(
      mediaId: normalized.mediaId,
      transientFilePath: normalized.transientFilePath,
      stagedRelativePath: paths.staged,
      finalRelativePath: paths.finalPath,
      checksumSha256: sourceChecksum,
      byteLength: normalized.expectedByteLength,
      originalExtension: normalized.extension,
      mimeType: normalized.mimeType,
    );
  }

  @override
  Future<StagedMediaArtifact> stage(MediaArtifactInput input) async =>
      stagePrepared(await prepare(input));

  @override
  Future<StagedMediaArtifact> stagePrepared(
    PreparedMediaArtifact artifact,
  ) async {
    _validatePrepared(artifact);
    final root = await _root();
    final source = File(artifact.transientFilePath);
    final paths = (
      staged: artifact.stagedRelativePath,
      finalPath: artifact.finalRelativePath,
    );
    final stagedFile = _file(root, paths.staged);
    final copyingFile = _file(root, '${paths.staged}.copying');
    final finalFile = _file(root, paths.finalPath);

    if (await finalFile.exists()) {
      await _requireIdentical(
        finalFile,
        artifact.byteLength,
        artifact.checksumSha256,
        'Final media id is already bound to different bytes',
      );
      return _result(artifact, created: false, alreadyPromoted: true);
    }
    if (await stagedFile.exists()) {
      await _requireIdentical(
        stagedFile,
        artifact.byteLength,
        artifact.checksumSha256,
        'Staged media id is already bound to different bytes',
      );
      return _result(artifact, created: false, alreadyPromoted: false);
    }

    final sourceStat = await source.stat();
    if (sourceStat.type != FileSystemEntityType.file) {
      throw MediaArtifactSourceMissing(source.path);
    }
    if (sourceStat.size != artifact.byteLength ||
        await _checksum(source) != artifact.checksumSha256) {
      throw const MediaArtifactIntegrityConflict(
        'Transient media changed after journal commit',
      );
    }

    await stagedFile.parent.create(recursive: true);
    if (await copyingFile.exists()) await copyingFile.delete();
    try {
      await source.copy(copyingFile.path);
      await _flush(copyingFile);
      await _requireIdentical(
        copyingFile,
        artifact.byteLength,
        artifact.checksumSha256,
        'Staged media copy failed byte verification',
      );
      if (await finalFile.exists()) {
        await _requireIdentical(
          finalFile,
          artifact.byteLength,
          artifact.checksumSha256,
          'Final media id raced with different bytes',
        );
        await copyingFile.delete();
        return _result(artifact, created: false, alreadyPromoted: true);
      }
      if (await stagedFile.exists()) {
        await _requireIdentical(
          stagedFile,
          artifact.byteLength,
          artifact.checksumSha256,
          'Staged media id raced with different bytes',
        );
        await copyingFile.delete();
        return _result(artifact, created: false, alreadyPromoted: false);
      }
      await copyingFile.rename(stagedFile.path);
      return _result(artifact, created: true, alreadyPromoted: false);
    } catch (_) {
      if (await copyingFile.exists()) await copyingFile.delete();
      rethrow;
    }
  }

  @override
  Future<PromotedMediaArtifact> promote(StagedMediaArtifact artifact) async {
    _validateArtifact(artifact);
    final root = await _root();
    final stagedFile = _file(root, artifact.stagedRelativePath);
    final finalFile = _file(root, artifact.finalRelativePath);
    if (await finalFile.exists()) {
      await _requireIdentical(
        finalFile,
        artifact.byteLength,
        artifact.checksumSha256,
        'Final media id is already bound to different bytes',
      );
      if (await stagedFile.exists()) {
        await _requireIdentical(
          stagedFile,
          artifact.byteLength,
          artifact.checksumSha256,
          'Staged retry conflicts with final bytes',
        );
        await stagedFile.delete();
      }
      return _promoted(root, artifact, created: false);
    }
    if (!await stagedFile.exists()) {
      throw StateError('Verified staged media is missing');
    }
    await _requireIdentical(
      stagedFile,
      artifact.byteLength,
      artifact.checksumSha256,
      'Staged media changed before promotion',
    );
    await finalFile.parent.create(recursive: true);
    await stagedFile.rename(finalFile.path);
    return _promoted(root, artifact, created: true);
  }

  @override
  Future<MediaArtifactPresence> inspect(StagedMediaArtifact artifact) async {
    _validateArtifact(artifact);
    final root = await _root();
    final stagedFile = _file(root, artifact.stagedRelativePath);
    final finalFile = _file(root, artifact.finalRelativePath);
    if (await finalFile.exists()) {
      await _requireIdentical(
        finalFile,
        artifact.byteLength,
        artifact.checksumSha256,
        'Final media changed after journal commit',
      );
      return MediaArtifactPresence.promoted;
    }
    if (await stagedFile.exists()) {
      await _requireIdentical(
        stagedFile,
        artifact.byteLength,
        artifact.checksumSha256,
        'Staged media changed after journal commit',
      );
      return MediaArtifactPresence.staged;
    }
    return MediaArtifactPresence.missing;
  }

  @override
  Future<void> discardStage(StagedMediaArtifact artifact) async {
    _validateArtifact(artifact);
    final file = _file(await _root(), artifact.stagedRelativePath);
    if (await file.exists()) await file.delete();
  }

  @override
  Future<void> removeFinal(String relativePath) async {
    _validateFinalPath(relativePath);
    final file = _file(await _root(), relativePath);
    if (await file.exists()) await file.delete();
  }

  @override
  Future<String> resolveFinalPath(String relativePath) async {
    _validateFinalPath(relativePath);
    return _file(await _root(), relativePath).path;
  }

  Future<Directory> _root() async {
    final root = await _supportDirectoryProvider();
    await root.create(recursive: true);
    return Directory(await root.resolveSymbolicLinks());
  }

  static File _file(Directory root, String relativePath) =>
      File('${root.path}/$relativePath');

  static Future<String> _checksum(File file) async =>
      (await sha256.bind(file.openRead()).single).toString();

  static Future<void> _flush(File file) async {
    final handle = await file.open(mode: FileMode.append);
    try {
      await handle.flush();
    } finally {
      await handle.close();
    }
  }

  static Future<void> _requireIdentical(
    File file,
    int byteLength,
    String checksum,
    String message,
  ) async {
    final stat = await file.stat();
    if (stat.type != FileSystemEntityType.file ||
        stat.size != byteLength ||
        await _checksum(file) != checksum) {
      throw MediaArtifactIntegrityConflict(message);
    }
  }

  static StagedMediaArtifact _result(
    PreparedMediaArtifact artifact, {
    required bool created,
    required bool alreadyPromoted,
  }) => StagedMediaArtifact(
    mediaId: artifact.mediaId,
    stagedRelativePath: artifact.stagedRelativePath,
    finalRelativePath: artifact.finalRelativePath,
    checksumSha256: artifact.checksumSha256,
    byteLength: artifact.byteLength,
    originalExtension: artifact.originalExtension,
    mimeType: artifact.mimeType,
    created: created,
    alreadyPromoted: alreadyPromoted,
  );

  static PromotedMediaArtifact _promoted(
    Directory root,
    StagedMediaArtifact artifact, {
    required bool created,
  }) => PromotedMediaArtifact(
    relativePath: artifact.finalRelativePath,
    absolutePath: _file(root, artifact.finalRelativePath).path,
    checksumSha256: artifact.checksumSha256,
    byteLength: artifact.byteLength,
    created: created,
  );
}
