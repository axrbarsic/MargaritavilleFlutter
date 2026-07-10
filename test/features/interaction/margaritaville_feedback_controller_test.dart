import 'package:flutter_test/flutter_test.dart';
import 'package:interaction_foundation/interaction_foundation.dart';
import 'package:margaritaville_flutter/features/interaction/application/margaritaville_feedback_controller.dart';
import 'package:margaritaville_flutter/features/interaction/domain/margaritaville_sound_routing.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/room_state.dart';

void main() {
  test(
    'configures the licensed donor sound palette and native timing',
    () async {
      final bridge = _FakeInteractionFeedbackBridge();
      final controller = MargaritavilleFeedbackController(
        runtime: InteractionFeedbackRuntime(bridge: bridge),
      );
      addTearDown(controller.dispose);

      await controller.initialize();

      expect(
        bridge.configuration?.soundCoalescingWindow,
        const Duration(milliseconds: 45),
      );
      expect(bridge.configuration?.playerPoolSize, 4);
      expect(bridge.configuration?.respectSilentMode, isTrue);
      expect(bridge.configuration?.mixWithOthers, isTrue);
      expect(bridge.configuration?.sounds, hasLength(13));
    },
  );

  test(
    'keeps the donor three-bucket routing and haptic-only hold cues',
    () async {
      final bridge = _FakeInteractionFeedbackBridge();
      final controller = MargaritavilleFeedbackController(
        runtime: InteractionFeedbackRuntime(bridge: bridge),
      );
      addTearDown(controller.dispose);
      await controller.initialize();

      controller.confirm();
      controller.roomStatusChanged(RoomDisplayStatus.open);
      controller.roomStatusChanged(RoomDisplayStatus.ready);
      controller.holdCommitHapticOnly();
      await Future<void>.delayed(Duration.zero);

      expect(bridge.requests, hasLength(4));
      expect(bridge.requests[0].cue, InteractionFeedbackCue.confirm);
      expect(
        bridge.requests[0].soundId,
        MargaritavilleSoundAsset.uiRolloverTick.id,
      );
      expect(bridge.requests[0].soundPriority, 40);
      expect(bridge.requests[1].cue, InteractionFeedbackCue.none);
      expect(
        bridge.requests[1].soundId,
        MargaritavilleSoundAsset.uiConfirmGlass.id,
      );
      expect(bridge.requests[1].soundPriority, 80);
      expect(
        bridge.requests[2].soundId,
        MargaritavilleSoundAsset.frontDeskBell.id,
      );
      expect(bridge.requests[3].cue, InteractionFeedbackCue.holdCommit);
      expect(bridge.requests[3].soundId, isNull);
    },
  );

  test(
    'applies persisted assignments and previews the exact selected asset',
    () async {
      final bridge = _FakeInteractionFeedbackBridge();
      final controller = MargaritavilleFeedbackController(
        runtime: InteractionFeedbackRuntime(bridge: bridge),
      );
      addTearDown(controller.dispose);
      await controller.initialize();
      controller.updateSoundAssignments(
        const MargaritavilleSoundAssignments(
          interfaceActions: MargaritavilleSoundAsset.none,
          room: MargaritavilleSoundAsset.uiAlertSnap,
          roomReady: MargaritavilleSoundAsset.kenneyBong1,
        ),
      );

      controller.confirm();
      controller.roomStatusChanged(RoomDisplayStatus.open);
      controller.roomStatusChanged(RoomDisplayStatus.ready);
      controller.previewSound(MargaritavilleSoundAsset.uiMenuOpen);
      await Future<void>.delayed(Duration.zero);

      expect(bridge.requests[0].soundId, isNull);
      expect(
        bridge.requests[1].soundId,
        MargaritavilleSoundAsset.uiAlertSnap.id,
      );
      expect(
        bridge.requests[2].soundId,
        MargaritavilleSoundAsset.kenneyBong1.id,
      );
      expect(bridge.previews, [MargaritavilleSoundAsset.uiMenuOpen.id]);
    },
  );
}

final class _FakeInteractionFeedbackBridge
    implements InteractionFeedbackBridge {
  InteractionFeedbackConfiguration? configuration;
  final requests = <InteractionFeedbackRequest>[];
  final previews = <String>[];

  @override
  Future<void> clearPending() async {}

  @override
  Future<void> configure(InteractionFeedbackConfiguration configuration) async {
    this.configuration = configuration;
  }

  @override
  Future<void> emit(InteractionFeedbackRequest request) async {
    requests.add(request);
  }

  @override
  Future<void> previewSound(String soundId) async {
    previews.add(soundId);
  }

  @override
  Future<void> setAudioContext(InteractionAudioContext context) async {}
}
