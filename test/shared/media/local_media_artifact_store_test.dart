import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/shared/media/local_media_artifact_store.dart';

void main() {
  late Directory sourceDirectory;
  late Directory supportDirectory;
  late LocalMediaArtifactStore store;

  setUp(() async {
    sourceDirectory = await Directory.systemTemp.createTemp('media-source-');
    supportDirectory = await Directory.systemTemp.createTemp('media-store-');
    store = LocalMediaArtifactStore(() async => supportDirectory);
  });

  tearDown(() async {
    await sourceDirectory.delete(recursive: true);
    await supportDirectory.delete(recursive: true);
  });

  test('prepare hashes bytes without creating app-owned media', () async {
    final source = await _source(sourceDirectory, 'capture.jpg', [4, 2]);

    final prepared = await store.prepare(
      _input(source, mediaId: 'photo-prepare'),
    );

    expect(prepared.byteLength, 2);
    expect(prepared.transientFilePath, source.path);
    expect(Directory('${supportDirectory.path}/Media').existsSync(), isFalse);
  });

  test('stage preserves bytes and leaves the verified file pending', () async {
    final source = await _source(sourceDirectory, 'capture.HEIC', [1, 2, 3, 4]);

    final staged = await store.stage(
      _input(source, mediaId: 'photo-101', extension: '.HEIC'),
    );

    expect(staged.stagedRelativePath, 'Media/.staging/photo-101.heic.partial');
    expect(staged.finalRelativePath, 'Media/photo-101.heic');
    expect(staged.originalExtension, 'heic');
    expect(staged.mimeType, 'image/heic');
    expect(staged.byteLength, 4);
    expect(staged.created, isTrue);
    expect(staged.alreadyPromoted, isFalse);
    expect(
      staged.checksumSha256,
      '9f64a747e1b97f131fabb6b447296c9b6f0201e79fb3c5356e6c77e89b6a806a',
    );
    expect(
      await File(
        '${supportDirectory.path}/${staged.stagedRelativePath}',
      ).readAsBytes(),
      [1, 2, 3, 4],
    );
    expect(
      File('${supportDirectory.path}/${staged.finalRelativePath}').existsSync(),
      isFalse,
    );
  });

  test(
    'promote atomically renames staged bytes into the final location',
    () async {
      final source = await _source(sourceDirectory, 'capture.jpg', [5, 6, 7]);
      final staged = await store.stage(_input(source, mediaId: 'photo-102'));

      final promoted = await store.promote(staged);

      expect(promoted.created, isTrue);
      expect(
        File(
          '${supportDirectory.path}/${staged.stagedRelativePath}',
        ).existsSync(),
        isFalse,
      );
      expect(await File(promoted.absolutePath).readAsBytes(), [5, 6, 7]);
      expect(
        await store.resolveFinalPath(staged.finalRelativePath),
        promoted.absolutePath,
      );
    },
  );

  test('identical stage retry reuses the verified pending artifact', () async {
    final source = await _source(sourceDirectory, 'capture.jpg', [8, 9]);
    final input = _input(source, mediaId: 'photo-stage-retry');

    final first = await store.stage(input);
    final retried = await store.stage(input);

    expect(first.created, isTrue);
    expect(retried.created, isFalse);
    expect(retried.alreadyPromoted, isFalse);
    expect(retried.checksumSha256, first.checksumSha256);
  });

  test(
    'retry replaces an interrupted copying file from journaled source',
    () async {
      final source = await _source(sourceDirectory, 'capture.jpg', [3, 1, 4]);
      final prepared = await store.prepare(
        _input(source, mediaId: 'photo-interrupted'),
      );
      final copying = File(
        '${supportDirectory.path}/${prepared.stagedRelativePath}.copying',
      );
      await copying.parent.create(recursive: true);
      await copying.writeAsBytes([3], flush: true);

      final staged = await store.stagePrepared(prepared);

      expect(staged.created, isTrue);
      expect(copying.existsSync(), isFalse);
      expect(
        await File(
          '${supportDirectory.path}/${prepared.stagedRelativePath}',
        ).readAsBytes(),
        [3, 1, 4],
      );
    },
  );

  test(
    'identical final retry is recognized without recreating staging',
    () async {
      final source = await _source(sourceDirectory, 'capture.jpg', [10, 11]);
      final input = _input(source, mediaId: 'photo-final-retry');
      final first = await store.stage(input);
      await store.promote(first);

      final retried = await store.stage(input);
      final promoted = await store.promote(retried);

      expect(retried.created, isFalse);
      expect(retried.alreadyPromoted, isTrue);
      expect(promoted.created, isFalse);
      expect(
        File(
          '${supportDirectory.path}/${retried.stagedRelativePath}',
        ).existsSync(),
        isFalse,
      );
    },
  );

  test('same media id refuses different staged or final bytes', () async {
    final firstSource = await _source(sourceDirectory, 'first.jpg', [1, 1]);
    final secondSource = await _source(sourceDirectory, 'second.jpg', [2, 2]);
    await store.stage(_input(firstSource, mediaId: 'photo-conflict'));

    await expectLater(
      store.stage(_input(secondSource, mediaId: 'photo-conflict')),
      throwsA(isA<MediaArtifactIntegrityConflict>()),
    );

    final finalFirst = await store.stage(
      _input(firstSource, mediaId: 'photo-final-conflict'),
    );
    await store.promote(finalFirst);
    await expectLater(
      store.stage(_input(secondSource, mediaId: 'photo-final-conflict')),
      throwsA(isA<MediaArtifactIntegrityConflict>()),
    );
  });

  test('length mismatch fails without leaving a new partial file', () async {
    final source = await _source(sourceDirectory, 'capture.jpg', [1, 2, 3]);

    await expectLater(
      store.stage(
        MediaArtifactInput(
          mediaId: 'photo-corrupt',
          transientFilePath: source.path,
          expectedByteLength: 4,
          originalExtension: 'jpg',
          mimeType: 'image/jpeg',
        ),
      ),
      throwsStateError,
    );

    expect(
      File(
        '${supportDirectory.path}/Media/.staging/photo-corrupt.jpg.partial',
      ).existsSync(),
      isFalse,
    );
  });

  test('validates identifiers, extension, mime and transient path', () async {
    final source = await _source(sourceDirectory, 'capture.jpg', [1]);

    for (final input in [
      _input(source, mediaId: '../photo'),
      _input(source, mediaId: 'photo/101'),
      _input(source, mediaId: 'photo', extension: '../jpg'),
      MediaArtifactInput(
        mediaId: 'photo',
        transientFilePath: source.path,
        expectedByteLength: 1,
        originalExtension: 'jpg',
        mimeType: 'image/jpeg\nunsafe',
      ),
      const MediaArtifactInput(
        mediaId: 'photo',
        transientFilePath: 'relative/capture.jpg',
        expectedByteLength: 1,
        originalExtension: 'jpg',
        mimeType: 'image/jpeg',
      ),
    ]) {
      await expectLater(store.stage(input), throwsArgumentError);
    }
    await expectLater(
      store.resolveFinalPath('../outside.jpg'),
      throwsArgumentError,
    );
    await expectLater(
      store.resolveFinalPath('Media/.staging/photo.jpg.partial'),
      throwsArgumentError,
    );
    await expectLater(
      store.promote(
        const StagedMediaArtifact(
          mediaId: 'photo',
          stagedRelativePath: 'Media/.staging/photo.jpg.partial',
          finalRelativePath: 'Media/photo.jpg',
          checksumSha256:
              '0000000000000000000000000000000000000000000000000000000000000000',
          byteLength: 1,
          originalExtension: 'jpg',
          mimeType: 'image/jpeg\nunsafe',
          created: false,
          alreadyPromoted: false,
        ),
      ),
      throwsArgumentError,
    );
  });

  test('discard and final removal are safe and idempotent', () async {
    final source = await _source(sourceDirectory, 'capture.jpg', [7]);
    final discarded = await store.stage(
      _input(source, mediaId: 'photo-discard'),
    );

    await store.discardStage(discarded);
    await store.discardStage(discarded);
    expect(
      File(
        '${supportDirectory.path}/${discarded.stagedRelativePath}',
      ).existsSync(),
      isFalse,
    );

    final promoted = await store.stage(_input(source, mediaId: 'photo-remove'));
    await store.promote(promoted);
    await store.removeFinal(promoted.finalRelativePath);
    await store.removeFinal(promoted.finalRelativePath);
    expect(
      File(
        '${supportDirectory.path}/${promoted.finalRelativePath}',
      ).existsSync(),
      isFalse,
    );
    await expectLater(store.removeFinal('../outside.jpg'), throwsArgumentError);
  });
}

Future<File> _source(Directory directory, String name, List<int> bytes) async {
  final file = File('${directory.path}/$name');
  await file.writeAsBytes(bytes, flush: true);
  return file;
}

MediaArtifactInput _input(
  File source, {
  required String mediaId,
  String extension = 'jpg',
}) => MediaArtifactInput(
  mediaId: mediaId,
  transientFilePath: source.path,
  expectedByteLength: source.lengthSync(),
  originalExtension: extension,
  mimeType: extension.toLowerCase().contains('heic')
      ? 'image/heic'
      : 'image/jpeg',
);
