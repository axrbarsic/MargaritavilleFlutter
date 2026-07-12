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
      ).updateWindowGeometry(7, 19, 3, 5, 11, 8.25, 122.5, 424, 780, 0, -18.5);

      expect(received, <Object?>[
        7,
        19,
        3,
        5,
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

      ByteData? encodedResponse;
      await messenger.handlePlatformMessage(
        channel.name,
        EdrOverlayFlutterApi.pigeonChannelCodec.encodeMessage(<Object?>[
          7,
          19,
          31,
          5,
        ]),
        (response) => encodedResponse = response,
      );

      expect(receiver.lastReady, (
        session: 7,
        activation: 19,
        content: 31,
        presentation: 5,
      ));
      final response =
          EdrOverlayFlutterApi.pigeonChannelCodec.decodeMessage(
                encodedResponse,
              )!
              as List<Object?>;
      final acknowledgement = response.single! as EdrReadyAck;
      expect(acknowledgement.accepted, isTrue);
      expect(acknowledgement.presentationRevision, 5);
    },
  );

  test('typed suspend transport preserves presentation lease', () async {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const suffix = 'suspend-contract';
    final channel = BasicMessageChannel<Object?>(
      'dev.flutter.pigeon.margaritaville_flutter.'
      'EdrOverlayHostApi.suspendWindow.$suffix',
      EdrOverlayHostApi.pigeonChannelCodec,
      binaryMessenger: messenger,
    );
    Object? received;
    messenger.setMockDecodedMessageHandler<Object?>(channel, (message) async {
      received = message;
      return <Object?>[
        EdrPresentationAck(
          surfaceSessionId: 7,
          activationId: 19,
          presentationRevision: 5,
          suppressed: true,
          outcome: EdrPresentationOutcome.transparentPresented,
          nativeGeneration: 13,
          presentedAtNanos: 17,
        ),
      ];
    });
    addTearDown(() {
      messenger.setMockDecodedMessageHandler<Object?>(channel, null);
    });

    final acknowledgement = await EdrOverlayHostApi(
      binaryMessenger: messenger,
      messageChannelSuffix: suffix,
    ).suspendWindow(7, 19, 5);

    expect(received, <Object?>[7, 19, 5]);
    expect(acknowledgement.suppressed, isTrue);
    expect(acknowledgement.nativeGeneration, 13);
    expect(acknowledgement.presentedAtNanos, 17);
  });
}

final class _RecordingFlutterApi implements EdrOverlayFlutterApi {
  ({int session, int activation, int content, int presentation})? lastReady;

  @override
  Future<EdrReadyAck> windowReady(
    int surfaceSessionId,
    int activationId,
    int contentRevision,
    int presentationRevision,
  ) async {
    lastReady = (
      session: surfaceSessionId,
      activation: activationId,
      content: contentRevision,
      presentation: presentationRevision,
    );
    return EdrReadyAck(
      surfaceSessionId: surfaceSessionId,
      activationId: activationId,
      contentRevision: contentRevision,
      presentationRevision: presentationRevision,
      accepted: true,
    );
  }
}
