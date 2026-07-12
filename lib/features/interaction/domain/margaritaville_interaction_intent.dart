import 'package:interaction_foundation/interaction_foundation.dart';

import 'margaritaville_sound_routing.dart';

enum MargaritavilleInteractionIntent {
  tap,
  navigate,
  select,
  deselect,
  toggleOn,
  toggleOff,
  confirm,
  retry,
  warning,
  destructive,
  invalid,
  detent,
  holdStart,
  holdWarning,
  holdCommit,
  openSettings,
  openSelection,
}

final class MargaritavilleInteractionPattern {
  const MargaritavilleInteractionPattern({
    required this.cue,
    required this.soundEvent,
  });

  final InteractionFeedbackCue cue;
  final MargaritavilleSoundEvent soundEvent;
}

extension MargaritavilleInteractionIntentPolicy
    on MargaritavilleInteractionIntent {
  MargaritavilleInteractionPattern get pattern => switch (this) {
    MargaritavilleInteractionIntent.tap ||
    MargaritavilleInteractionIntent.navigate ||
    MargaritavilleInteractionIntent.retry =>
      const MargaritavilleInteractionPattern(
        cue: InteractionFeedbackCue.tap,
        soundEvent: MargaritavilleSoundEvent.tap,
      ),
    MargaritavilleInteractionIntent.select ||
    MargaritavilleInteractionIntent.toggleOn =>
      const MargaritavilleInteractionPattern(
        cue: InteractionFeedbackCue.select,
        soundEvent: MargaritavilleSoundEvent.select,
      ),
    MargaritavilleInteractionIntent.deselect ||
    MargaritavilleInteractionIntent.toggleOff =>
      const MargaritavilleInteractionPattern(
        cue: InteractionFeedbackCue.deselect,
        soundEvent: MargaritavilleSoundEvent.deselect,
      ),
    MargaritavilleInteractionIntent.confirm ||
    MargaritavilleInteractionIntent.destructive =>
      const MargaritavilleInteractionPattern(
        cue: InteractionFeedbackCue.confirm,
        soundEvent: MargaritavilleSoundEvent.confirm,
      ),
    MargaritavilleInteractionIntent.warning ||
    MargaritavilleInteractionIntent.invalid =>
      const MargaritavilleInteractionPattern(
        cue: InteractionFeedbackCue.invalid,
        soundEvent: MargaritavilleSoundEvent.invalid,
      ),
    MargaritavilleInteractionIntent.detent =>
      const MargaritavilleInteractionPattern(
        cue: InteractionFeedbackCue.detent,
        soundEvent: MargaritavilleSoundEvent.detent,
      ),
    MargaritavilleInteractionIntent.holdStart =>
      const MargaritavilleInteractionPattern(
        cue: InteractionFeedbackCue.holdStart,
        soundEvent: MargaritavilleSoundEvent.holdStart,
      ),
    MargaritavilleInteractionIntent.holdWarning =>
      const MargaritavilleInteractionPattern(
        cue: InteractionFeedbackCue.holdWarning,
        soundEvent: MargaritavilleSoundEvent.holdWarning,
      ),
    MargaritavilleInteractionIntent.holdCommit =>
      const MargaritavilleInteractionPattern(
        cue: InteractionFeedbackCue.holdCommit,
        soundEvent: MargaritavilleSoundEvent.holdCommit,
      ),
    MargaritavilleInteractionIntent.openSettings =>
      const MargaritavilleInteractionPattern(
        cue: InteractionFeedbackCue.confirm,
        soundEvent: MargaritavilleSoundEvent.settingsOpen,
      ),
    MargaritavilleInteractionIntent.openSelection =>
      const MargaritavilleInteractionPattern(
        cue: InteractionFeedbackCue.confirm,
        soundEvent: MargaritavilleSoundEvent.selectionOpen,
      ),
  };
}
