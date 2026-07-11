import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/shared/edr/generated/edr_overlay_api.g.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'typed geometry transport preserves fractional negative bounce',
    () async {
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      const suffix = 'geometry-contract';
      final channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.margaritaville_flutter.'
        'EdrOverlayHostApi.updateWindowGeometry.$suffix',
        EdrOverlayHostApi.pigeonChannelCodec,
        binaryMessenger: messenger,
      );
      Object? received;
      messenger.setMockDecodedMessageHandler<Object?>(channel, (message) async {
        received = message;
        return <Object?>[null];
      });
      addTearDown(() {
        messenger.setMockDecodedMessageHandler<Object?>(channel, null);
      });

      await EdrOverlayHostApi(
        binaryMessenger: messenger,
        messageChannelSuffix: suffix,
      ).updateWindowGeometry(7, 19, 3, 11, 8.25, 122.5, 424, 780, 0, -18.5);

      expect(received, <Object?>[
        7,
        19,
        3,
        11,
        8.25,
        122.5,
        424.0,
        780.0,
        0.0,
        -18.5,
      ]);
    },
  );

  test(
    'typed readiness transport preserves the complete native lease',
    () async {
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      const suffix = 'readiness-contract';
      final receiver = _RecordingFlutterApi();
      EdrOverlayFlutterApi.setUp(
        receiver,
        binaryMessenger: messenger,
        messageChannelSuffix: suffix,
      );
      addTearDown(() {
        EdrOverlayFlutterApi.setUp(
          null,
          binaryMessenger: messenger,
          messageChannelSuffix: suffix,
        );
      });
      final channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.margaritaville_flutter.'
        'EdrOverlayFlutterApi.windowReady.$suffix',
        EdrOverlayFlutterApi.pigeonChannelCodec,
        binaryMessenger: messenger,
      );

      await messenger.handlePlatformMessage(
        channel.name,
        EdrOverlayFlutterApi.pigeonChannelCodec.encodeMessage(<Object?>[
          7,
          19,
          31,
        ]),
        null,
      );

      expect(receiver.lastReady, (session: 7, activation: 19, content: 31));
    },
  );
}

final class _RecordingFlutterApi implements EdrOverlayFlutterApi {
  ({int session, int activation, int content})? lastReady;

  @override
  void windowReady(
    int surfaceSessionId,
    int activationId,
    int contentRevision,
  ) {
    lastReady = (
      session: surfaceSessionId,
      activation: activationId,
      content: contentRevision,
    );
  }
}
