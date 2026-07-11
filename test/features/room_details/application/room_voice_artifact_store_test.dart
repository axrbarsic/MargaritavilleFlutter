import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/room_details/application/voice/room_voice_artifact_store.dart';

void main() {
  late Directory temporaryDirectory;
  late Directory supportDirectory;
  late LocalRoomVoiceArtifactStore store;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp('voice-source-');
    supportDirectory = await Directory.systemTemp.createTemp('voice-store-');
    store = LocalRoomVoiceArtifactStore(() async => supportDirectory);
  });

  tearDown(() async {
    await temporaryDirectory.delete(recursive: true);
    await supportDirectory.delete(recursive: true);
  });

  test('copies atomically and returns real SHA-256 metadata', () async {
    final source = File('${temporaryDirectory.path}/capture.m4a');
    await source.writeAsBytes(const [1, 2, 3, 4]);

    final result = await store.persist(
      RoomVoiceArtifactInput(
        mediaId: 'voice-101',
        temporaryFilePath: source.path,
        expectedByteLength: 4,
      ),
    );

    expect(result.relativePath, 'Media/voice-101.m4a');
    expect(
      result.checksumSha256,
      '9f64a747e1b97f131fabb6b447296c9b6f0201e79fb3c5356e6c77e89b6a806a',
    );
    expect(result.byteLength, 4);
    expect(
      await File(
        '${supportDirectory.path}/${result.relativePath}',
      ).readAsBytes(),
      const [1, 2, 3, 4],
    );
    expect(
      supportDirectory.listSync(recursive: true).whereType<File>(),
      everyElement(
        isNot(predicate<File>((file) => file.path.endsWith('.partial'))),
      ),
    );
  });

  test('rejects corrupted copy metadata and removes partial file', () async {
    final source = File('${temporaryDirectory.path}/capture.m4a');
    await source.writeAsBytes(const [1, 2, 3]);

    await expectLater(
      store.persist(
        RoomVoiceArtifactInput(
          mediaId: 'voice-102',
          temporaryFilePath: source.path,
          expectedByteLength: 4,
        ),
      ),
      throwsStateError,
    );
    expect(
      supportDirectory.listSync(recursive: true).whereType<File>(),
      isEmpty,
    );
  });

  test('removes only safe app-relative media paths', () async {
    final source = File('${temporaryDirectory.path}/capture.m4a');
    await source.writeAsBytes(const [9]);
    final result = await store.persist(
      RoomVoiceArtifactInput(
        mediaId: 'voice-103',
        temporaryFilePath: source.path,
        expectedByteLength: 1,
      ),
    );

    await store.remove(result.relativePath);
    expect(
      File('${supportDirectory.path}/${result.relativePath}').existsSync(),
      isFalse,
    );
    await expectLater(store.remove('../outside'), throwsArgumentError);
  });

  test('retry after atomic rename reuses an identical artifact', () async {
    final source = File('${temporaryDirectory.path}/capture.m4a');
    await source.writeAsBytes(const [5, 6, 7]);
    const input = RoomVoiceArtifactInput(
      mediaId: 'voice-retry',
      temporaryFilePath: '',
      expectedByteLength: 3,
    );
    final actualInput = RoomVoiceArtifactInput(
      mediaId: input.mediaId,
      temporaryFilePath: source.path,
      expectedByteLength: input.expectedByteLength,
    );

    final first = await store.persist(actualInput);
    final retried = await store.persist(actualInput);

    expect(retried.relativePath, first.relativePath);
    expect(retried.checksumSha256, first.checksumSha256);
    expect(retried.byteLength, first.byteLength);
  });

  test(
    'retry refuses to replace a different artifact with the same id',
    () async {
      final first = File('${temporaryDirectory.path}/first.m4a');
      final second = File('${temporaryDirectory.path}/second.m4a');
      await first.writeAsBytes(const [1, 2, 3]);
      await second.writeAsBytes(const [3, 2, 1]);
      await store.persist(
        RoomVoiceArtifactInput(
          mediaId: 'voice-conflict',
          temporaryFilePath: first.path,
          expectedByteLength: 3,
        ),
      );

      await expectLater(
        store.persist(
          RoomVoiceArtifactInput(
            mediaId: 'voice-conflict',
            temporaryFilePath: second.path,
            expectedByteLength: 3,
          ),
        ),
        throwsStateError,
      );
    },
  );
}
