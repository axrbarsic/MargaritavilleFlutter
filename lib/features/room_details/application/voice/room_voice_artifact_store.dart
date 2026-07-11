import 'dart:io';

import 'package:crypto/crypto.dart';

final class RoomVoiceArtifactInput {
  const RoomVoiceArtifactInput({
    required this.mediaId,
    required this.temporaryFilePath,
    required this.expectedByteLength,
  });

  final String mediaId;
  final String temporaryFilePath;
  final int expectedByteLength;
}

final class StoredRoomVoiceArtifact {
  const StoredRoomVoiceArtifact({
    required this.relativePath,
    required this.checksumSha256,
    required this.byteLength,
    required this.created,
  });

  final String relativePath;
  final String checksumSha256;
  final int byteLength;
  final bool created;
}

abstract interface class RoomVoiceArtifactStore {
  Future<StoredRoomVoiceArtifact> persist(RoomVoiceArtifactInput input);

  Future<void> remove(String relativePath);
}

final class LocalRoomVoiceArtifactStore implements RoomVoiceArtifactStore {
  LocalRoomVoiceArtifactStore(this._rootDirectory);

  final Future<Directory> Function() _rootDirectory;

  @override
  Future<StoredRoomVoiceArtifact> persist(RoomVoiceArtifactInput input) async {
    _validateMediaId(input.mediaId);
    final source = File(input.temporaryFilePath);
    if (!await source.exists()) {
      throw StateError('Временная голосовая запись не найдена');
    }

    final root = await _rootDirectory();
    final mediaDirectory = Directory('${root.path}/Media');
    await mediaDirectory.create(recursive: true);
    final relativePath = 'Media/${input.mediaId}.m4a';
    final target = File('${root.path}/$relativePath');
    if (await target.exists()) {
      return _reuseIdenticalArtifact(
        source: source,
        target: target,
        input: input,
        relativePath: relativePath,
      );
    }

    final partial = File('${target.path}.partial');
    if (await partial.exists()) await partial.delete();
    try {
      await source.copy(partial.path);
      final byteLength = await partial.length();
      if (byteLength <= 0 ||
          (input.expectedByteLength > 0 &&
              byteLength != input.expectedByteLength)) {
        throw StateError('Голосовая запись повреждена при копировании');
      }
      final checksum = await sha256.bind(partial.openRead()).first;
      await partial.rename(target.path);
      return StoredRoomVoiceArtifact(
        relativePath: relativePath,
        checksumSha256: checksum.toString(),
        byteLength: byteLength,
        created: true,
      );
    } catch (_) {
      if (await partial.exists()) await partial.delete();
      rethrow;
    }
  }

  @override
  Future<void> remove(String relativePath) async {
    if (!relativePath.startsWith('Media/') || relativePath.contains('..')) {
      throw ArgumentError.value(relativePath, 'relativePath');
    }
    final root = await _rootDirectory();
    final file = File('${root.path}/$relativePath');
    if (await file.exists()) await file.delete();
  }

  static void _validateMediaId(String value) {
    if (!RegExp(r'^[A-Za-z0-9._-]+$').hasMatch(value)) {
      throw ArgumentError.value(value, 'mediaId');
    }
  }

  static Future<StoredRoomVoiceArtifact> _reuseIdenticalArtifact({
    required File source,
    required File target,
    required RoomVoiceArtifactInput input,
    required String relativePath,
  }) async {
    final sourceLength = await source.length();
    final targetLength = await target.length();
    if (sourceLength <= 0 ||
        sourceLength != targetLength ||
        (input.expectedByteLength > 0 &&
            targetLength != input.expectedByteLength)) {
      throw StateError('Голосовой файл ${input.mediaId} уже существует');
    }
    final hashes = await Future.wait([
      sha256.bind(source.openRead()).first,
      sha256.bind(target.openRead()).first,
    ]);
    if (hashes[0] != hashes[1]) {
      throw StateError('Голосовой файл ${input.mediaId} уже существует');
    }
    return StoredRoomVoiceArtifact(
      relativePath: relativePath,
      checksumSha256: hashes[1].toString(),
      byteLength: targetLength,
      created: false,
    );
  }
}
