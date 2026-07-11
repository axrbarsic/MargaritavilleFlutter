import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/room_details/presentation/camera/room_photo_camera_screen.dart';
import 'package:margaritaville_flutter/shared/media/capture/captured_photo_artifact.dart';
import 'package:margaritaville_flutter/shared/media/capture/photo_camera_session.dart';

void main() {
  testWidgets('camera returns one captured photo from the shutter', (
    tester,
  ) async {
    final session = _FakeSession();
    CapturedPhotoArtifact? captured;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              captured = await Navigator.push<CapturedPhotoArtifact>(
                context,
                MaterialPageRoute(
                  builder: (_) => RoomPhotoCameraScreen(
                    sessionFactory: () async => session,
                  ),
                ),
              );
            },
            child: const Text('Открыть'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Открыть'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('fake-camera-preview')), findsOneWidget);
    expect(find.byKey(const Key('photo-camera-shutter')), findsOneWidget);

    await tester.tap(find.byKey(const Key('photo-camera-shutter')));
    await tester.pumpAndSettle();

    expect(session.captureCount, 1);
    expect(captured?.byteLength, 4);
  });

  testWidgets('permission denial is Russian and remains closable', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RoomPhotoCameraScreen(
          sessionFactory: () async =>
              throw const PhotoCameraFailure(PhotoCameraFailureCode.denied),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Нет доступа к камере'), findsOneWidget);
    expect(find.byKey(const Key('photo-camera-close')), findsOneWidget);
  });

  testWidgets('inactive lifecycle disposes camera resources', (tester) async {
    final session = _FakeSession();
    await tester.pumpWidget(
      MaterialApp(
        home: RoomPhotoCameraScreen(sessionFactory: () async => session),
      ),
    );
    await tester.pumpAndSettle();

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();

    expect(session.disposeCount, 1);
    expect(find.byKey(const Key('fake-camera-preview')), findsNothing);
  });

  testWidgets('resume waits until the previous session finishes disposal', (
    tester,
  ) async {
    final disposeGate = Completer<void>();
    final first = _FakeSession(onDispose: () => disposeGate.future);
    final second = _FakeSession();
    var factoryCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: RoomPhotoCameraScreen(
          sessionFactory: () async {
            factoryCalls += 1;
            return factoryCalls == 1 ? first : second;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(first.disposeCount, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(factoryCalls, 1);
    expect(find.byKey(const Key('fake-camera-preview')), findsNothing);

    disposeGate.complete();
    await tester.pumpAndSettle();
    expect(factoryCalls, 2);
    expect(find.byKey(const Key('fake-camera-preview')), findsOneWidget);
  });
}

final class _FakeSession implements PhotoCameraSession {
  _FakeSession({this.onDispose});

  final Future<void> Function()? onDispose;
  int captureCount = 0;
  int disposeCount = 0;

  @override
  double get previewAspectRatio => 4 / 3;

  @override
  Widget buildPreview() =>
      const ColoredBox(key: Key('fake-camera-preview'), color: Colors.blue);

  @override
  Future<CapturedPhotoArtifact> takePicture() async {
    captureCount += 1;
    return CapturedPhotoArtifact(
      transientFilePath: '/tmp/photo.jpg',
      byteLength: 4,
      mimeType: 'image/jpeg',
      fileExtension: 'jpg',
      createdAt: DateTime.utc(2027, 2, 10),
    );
  }

  @override
  Future<void> dispose() async {
    disposeCount += 1;
    await onDispose?.call();
  }
}
