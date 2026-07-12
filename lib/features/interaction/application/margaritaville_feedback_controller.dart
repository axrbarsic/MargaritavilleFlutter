import 'package:interaction_foundation/interaction_foundation.dart';

import '../../work_session/domain/models/room_state.dart';
import '../domain/margaritaville_interaction_intent.dart';
import '../domain/margaritaville_sound_routing.dart';

final class MargaritavilleFeedbackController {
  MargaritavilleFeedbackController({
    InteractionFeedbackRuntime? runtime,
    MargaritavilleSoundAssignments soundAssignments =
        MargaritavilleSoundAssignments.defaults,
  }) : _runtime = runtime ?? InteractionFeedbackRuntime(),
       _soundAssignments = soundAssignments;

  final InteractionFeedbackRuntime _runtime;
  MargaritavilleSoundAssignments _soundAssignments;

  Future<void> initialize() {
    return _runtime.configure(
      InteractionFeedbackConfiguration(
        sounds: MargaritavilleSoundAsset.nativeRegistrations,
      ),
    );
  }

  void perform(MargaritavilleInteractionIntent intent, {String? eventId}) {
    final pattern = intent.pattern;
    _emit(pattern.soundEvent, pattern.cue, eventId: eventId);
  }

  void performHapticOnly(
    MargaritavilleInteractionIntent intent, {
    String? eventId,
  }) {
    _runtime.emit(cue: intent.pattern.cue, eventId: eventId);
  }

  void tap() => _emit(MargaritavilleSoundEvent.tap, InteractionFeedbackCue.tap);

  void confirm() =>
      _emit(MargaritavilleSoundEvent.confirm, InteractionFeedbackCue.confirm);

  void deselect() =>
      _emit(MargaritavilleSoundEvent.deselect, InteractionFeedbackCue.deselect);

  void holdStart() => _emit(
    MargaritavilleSoundEvent.holdStart,
    InteractionFeedbackCue.holdStart,
  );

  void holdWarning() => _emit(
    MargaritavilleSoundEvent.holdWarning,
    InteractionFeedbackCue.holdWarning,
  );

  void holdCommit() => _emit(
    MargaritavilleSoundEvent.holdCommit,
    InteractionFeedbackCue.holdCommit,
  );

  void holdStartHapticOnly() =>
      _runtime.emit(cue: InteractionFeedbackCue.holdStart);

  void holdWarningHapticOnly() =>
      _runtime.emit(cue: InteractionFeedbackCue.holdWarning);

  void holdCommitHapticOnly() =>
      _runtime.emit(cue: InteractionFeedbackCue.holdCommit);

  void actionMenuOpened() =>
      _playSound(MargaritavilleSoundEvent.actionMenuOpen);

  void settingsOpened() => _playSound(MargaritavilleSoundEvent.settingsOpen);

  void settingsOpenCommitted() => _emit(
    MargaritavilleSoundEvent.settingsOpen,
    InteractionFeedbackCue.confirm,
  );

  void selectionOpenCommitted() => _emit(
    MargaritavilleSoundEvent.selectionOpen,
    InteractionFeedbackCue.confirm,
  );

  void selectionOpened() => _playSound(MargaritavilleSoundEvent.selectionOpen);

  void updateSoundAssignments(MargaritavilleSoundAssignments assignments) {
    _soundAssignments = assignments;
  }

  void previewSound(MargaritavilleSoundAsset asset) {
    if (asset == MargaritavilleSoundAsset.none) return;
    _runtime.previewSound(asset.id);
  }

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

  void _emit(
    MargaritavilleSoundEvent event,
    InteractionFeedbackCue cue, {
    String? eventId,
  }) {
    final asset = _soundAssignments.assetFor(event);
    _runtime.emit(
      cue: cue,
      eventId: eventId,
      soundId: asset == MargaritavilleSoundAsset.none ? null : asset.id,
      soundPriority: event.priority,
    );
  }

  void _playSound(MargaritavilleSoundEvent event) {
    final asset = _soundAssignments.assetFor(event);
    if (asset == MargaritavilleSoundAsset.none) return;
    _runtime.emit(
      cue: InteractionFeedbackCue.none,
      soundId: asset.id,
      soundPriority: event.priority,
    );
  }
}
