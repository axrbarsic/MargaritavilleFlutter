import 'package:interaction_foundation/interaction_foundation.dart';

import '../../work_session/domain/models/room_state.dart';
import '../domain/margaritaville_sound_routing.dart';

final class MargaritavilleFeedbackController {
  MargaritavilleFeedbackController({InteractionFeedbackRuntime? runtime})
    : _runtime = runtime ?? InteractionFeedbackRuntime();

  final InteractionFeedbackRuntime _runtime;

  Future<void> initialize() {
    return _runtime.configure(
      InteractionFeedbackConfiguration(
        sounds: MargaritavilleSoundAsset.nativeRegistrations,
      ),
    );
  }

  void tap() => _emit(MargaritavilleSoundEvent.tap, InteractionFeedbackCue.tap);

  void confirm() =>
      _emit(MargaritavilleSoundEvent.confirm, InteractionFeedbackCue.confirm);

  void deselect() =>
      _emit(MargaritavilleSoundEvent.deselect, InteractionFeedbackCue.deselect);

  void holdStartHapticOnly() =>
      _runtime.emit(cue: InteractionFeedbackCue.holdStart);

  void holdWarningHapticOnly() =>
      _runtime.emit(cue: InteractionFeedbackCue.holdWarning);

  void holdCommitHapticOnly() =>
      _runtime.emit(cue: InteractionFeedbackCue.holdCommit);

  void actionMenuOpened() =>
      _playSound(MargaritavilleSoundEvent.actionMenuOpen);

  void roomStatusChanged(RoomDisplayStatus status) {
    _playSound(switch (status) {
      RoomDisplayStatus.pending => MargaritavilleSoundEvent.roomPending,
      RoomDisplayStatus.open => MargaritavilleSoundEvent.roomOpen,
      RoomDisplayStatus.ready => MargaritavilleSoundEvent.roomReady,
      RoomDisplayStatus.scheduled => MargaritavilleSoundEvent.roomScheduled,
    });
  }

  void setAudioContext(InteractionAudioContext context) {
    _runtime.setAudioContext(context);
  }

  void dispose() => _runtime.dispose();

  void _emit(MargaritavilleSoundEvent event, InteractionFeedbackCue cue) {
    final asset = event.defaultAsset;
    _runtime.emit(
      cue: cue,
      soundId: asset == MargaritavilleSoundAsset.none ? null : asset.id,
      soundPriority: event.priority,
    );
  }

  void _playSound(MargaritavilleSoundEvent event) {
    final asset = event.defaultAsset;
    if (asset == MargaritavilleSoundAsset.none) return;
    _runtime.emit(
      cue: InteractionFeedbackCue.none,
      soundId: asset.id,
      soundPriority: event.priority,
    );
  }
}
