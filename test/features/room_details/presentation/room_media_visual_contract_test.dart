import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/room_details/domain/models/room_media_item.dart';
import 'package:margaritaville_flutter/features/room_details/presentation/room_media_viewer_screen.dart';
import 'package:margaritaville_flutter/features/room_details/presentation/widgets/room_details_media_section.dart';

void main() {
  testWidgets('donor grid keeps 132x182 preview and 30x30 delete target', (
    tester,
  ) async {
    final media = [_photo('photo-1'), _photo('photo-2')];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 360,
            child: RoomDetailsMediaSection(
              media: media,
              onPhoto: () {},
              onVideo: () {},
              onOpen: (_) {},
              onDelete: (_) {},
              resolvePath: (_) async => '/tmp/missing.jpg',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byKey(const ValueKey('room-media-open-photo-1'))),
      const Size(132, 182),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('room-media-delete-photo-1'))),
      const Size(30, 30),
    );
    final first = tester.getTopLeft(
      find.byKey(const ValueKey('room-media-open-photo-1')),
    );
    final second = tester.getTopLeft(
      find.byKey(const ValueKey('room-media-open-photo-2')),
    );
    expect(second.dx - (first.dx + 132), greaterThanOrEqualTo(12));
  });

  testWidgets('viewer starts at tapped media, swipes and exposes zoom 1 to 5', (
    tester,
  ) async {
    final media = [_photo('photo-1'), _photo('photo-2')];
    await tester.pumpWidget(
      MaterialApp(
        home: RoomMediaViewerScreen(
          media: media,
          initialMediaId: 'photo-2',
          resolvePath: (_) async => '/tmp/missing.jpg',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2 / 2'), findsOneWidget);
    final zoom = tester.widget<InteractiveViewer>(
      find.byKey(const ValueKey('room-media-zoom-photo-2')),
    );
    expect(zoom.minScale, 1);
    expect(zoom.maxScale, 5);
    expect(find.byKey(const Key('room-media-viewer-close')), findsOneWidget);

    await tester.drag(
      find.byKey(const Key('room-media-viewer-pages')),
      const Offset(500, 0),
    );
    await tester.pumpAndSettle();
    expect(find.text('1 / 2'), findsOneWidget);
  });
}

RoomMediaItem _photo(String id) {
  final createdAt = DateTime.utc(2027, 2, 10, 12, 45);
  return RoomMediaItem(
    id: id,
    sessionId: 'session-1',
    roomNumber: '101',
    kind: RoomMediaKind.photo,
    relativePath: 'Media/$id.jpg',
    checksumSha256: 'sha-$id',
    originDeviceId: 'device-1',
    createdAt: createdAt,
    updatedAt: createdAt,
    mimeType: 'image/jpeg',
    byteLength: 100,
    originalExtension: 'jpg',
  );
}
