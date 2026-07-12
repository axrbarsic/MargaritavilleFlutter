import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interaction_foundation/interaction_foundation.dart';
import 'package:margaritaville_flutter/app/margaritaville_theme.dart';
import 'package:margaritaville_flutter/features/room_details/application/commands/room_details_command.dart';
import 'package:margaritaville_flutter/features/room_details/application/voice/room_voice_artifact_store.dart';
import 'package:margaritaville_flutter/features/room_details/domain/models/room_details_snapshot.dart';
import 'package:margaritaville_flutter/features/room_details/domain/models/room_media_item.dart';
import 'package:margaritaville_flutter/features/room_details/domain/repositories/room_details_repository.dart';
import 'package:margaritaville_flutter/features/room_details/presentation/controllers/room_details_controller.dart';
import 'package:margaritaville_flutter/features/room_details/presentation/controllers/room_voice_capture_controller.dart';
import 'package:margaritaville_flutter/features/room_details/presentation/room_details_screen.dart';
import '../../../support/test_feedback_scope.dart';

void main() {
  testWidgets('records, transcribes and renders a durable voice bubble', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(440, 956);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final bridge = _WidgetVoiceBridge();
    final repository = _WidgetRoomRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          voiceCaptureBridgeProvider.overrideWithValue(bridge),
          roomVoiceArtifactStoreProvider.overrideWithValue(
            _WidgetArtifactStore(),
          ),
          roomDetailsRepositoryProvider.overrideWithValue(repository),
        ],
        child: TestFeedbackScope(
          child: MaterialApp(
            theme: MargaritavilleTheme.dark,
            home: const RoomDetailsScreen(
              sessionId: 'session-1',
              roomNumber: '101',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('room-details-record-voice')));
    await tester.pumpAndSettle();
    expect(find.text('Остановить запись'), findsOneWidget);
    expect(find.text('Идёт запись...'), findsOneWidget);

    await tester.tap(find.byKey(const Key('room-details-record-voice')));
    await tester.pumpAndSettle();

    expect(find.text('Комната готова.'), findsOneWidget);
    expect(find.text('Готово'), findsOneWidget);
    expect(repository.media, hasLength(1));
    expect(bridge.released, ['result-1']);
  });
}

final class _WidgetVoiceBridge implements VoiceCaptureBridge {
  final Map<String, VoiceCaptureEventListener> listeners = {};
  final List<String> released = [];
  VoiceCaptureStartRequest? request;

  @override
  Future<VoiceCaptureCapabilities> getCapabilities({
    String localeIdentifier = VoiceCaptureContract.defaultLocaleIdentifier,
  }) async => const VoiceCaptureCapabilities(
    contractVersion: 1,
    supported: true,
    speechPermission: VoicePermissionState.granted,
    microphonePermission: VoicePermissionState.granted,
    recognizerAvailable: true,
  );

  @override
  Future<VoiceCaptureAcknowledgement> startCapture(
    VoiceCaptureStartRequest request,
  ) async {
    this.request = request;
    _emit(1, VoiceCapturePhase.requestingPermissions);
    _emit(2, VoiceCapturePhase.starting);
    _emit(3, VoiceCapturePhase.recording);
    return _ack(request.operationId, VoiceCaptureStatusCode.recording);
  }

  @override
  Future<VoiceCaptureAcknowledgement> stopCapture(String operationId) async {
    _emit(4, VoiceCapturePhase.finishing);
    _emit(
      5,
      VoiceCapturePhase.completed,
      result: VoiceCaptureResult(
        contractVersion: 1,
        operationId: operationId,
        resultId: 'result-1',
        temporaryFilePath: '/tmp/widget.m4a',
        originDeviceId: 'iphone-1',
        createdAtMicros: 1783785600000000,
        durationMs: 1200,
        byteLength: 12,
        mimeType: 'audio/mp4',
        codec: 'aac',
        sampleRateHz: 44100,
        channelCount: 1,
        recognizedText: 'Комната готова.',
      ),
    );
    return _ack(operationId, VoiceCaptureStatusCode.finishingTranscription);
  }

  void _emit(
    int sequence,
    VoiceCapturePhase phase, {
    VoiceCaptureResult? result,
  }) {
    final operationId = request!.operationId;
    listeners[operationId]?.call(
      VoiceCaptureEvent(
        contractVersion: 1,
        operationId: operationId,
        sequence: sequence,
        phase: phase,
        statusCode: switch (phase) {
          VoiceCapturePhase.recording => VoiceCaptureStatusCode.recording,
          VoiceCapturePhase.finishing =>
            VoiceCaptureStatusCode.finishingTranscription,
          VoiceCapturePhase.completed => VoiceCaptureStatusCode.completed,
          _ => VoiceCaptureStatusCode.checkingAccess,
        },
        result: result,
      ),
    );
  }

  @override
  Future<VoiceCaptureAcknowledgement> cancelCapture(String operationId) async =>
      _ack(operationId, VoiceCaptureStatusCode.cancelled);

  @override
  Future<void> releaseResult(String resultId) async => released.add(resultId);

  @override
  VoiceCaptureEventSubscription subscribe(
    String operationId,
    VoiceCaptureEventListener listener, {
    bool replayLatest = true,
  }) {
    listeners[operationId] = listener;
    return VoiceCaptureEventSubscription(() => listeners.remove(operationId));
  }

  @override
  VoiceCaptureEventSubscription subscribeAll(
    VoiceCaptureEventListener listener,
  ) => VoiceCaptureEventSubscription(() {});

  @override
  void forgetOperation(String operationId) => listeners.remove(operationId);

  static VoiceCaptureAcknowledgement _ack(
    String operationId,
    VoiceCaptureStatusCode status,
  ) => VoiceCaptureAcknowledgement(
    contractVersion: 1,
    operationId: operationId,
    accepted: true,
    statusCode: status,
  );
}

final class _WidgetArtifactStore implements RoomVoiceArtifactStore {
  @override
  Future<StoredRoomVoiceArtifact> persist(RoomVoiceArtifactInput input) async =>
      const StoredRoomVoiceArtifact(
        relativePath: 'Media/widget.m4a',
        checksumSha256: 'widget-sha256',
        byteLength: 12,
        created: true,
      );

  @override
  Future<void> remove(String relativePath) async {}
}

final class _WidgetRoomRepository implements RoomDetailsRepository {
  final List<RoomMediaItem> media = [];

  @override
  Future<RoomDetailsCommitStatus> commit(RoomDetailsCommand command) async {
    if (command case AddRoomMediaCommand(media: final item)) media.add(item);
    return RoomDetailsCommitStatus.applied;
  }

  @override
  Future<RoomDetailsSnapshot> load({
    required String sessionId,
    required String roomNumber,
  }) async => RoomDetailsSnapshot(
    sessionId: sessionId,
    roomNumber: roomNumber,
    media: List.unmodifiable(media),
    updatedAt: media.isEmpty ? null : media.first.updatedAt,
  );
}
