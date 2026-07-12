import 'package:flutter_test/flutter_test.dart';
import 'package:interaction_foundation/interaction_foundation.dart';
import 'package:margaritaville_flutter/features/interaction/domain/margaritaville_interaction_intent.dart';
import 'package:margaritaville_flutter/features/interaction/domain/margaritaville_sound_routing.dart';

void main() {
  test('every discrete intent has an explicit non-empty haptic policy', () {
    expect(MargaritavilleInteractionIntent.values, isNotEmpty);
    for (final intent in MargaritavilleInteractionIntent.values) {
      expect(intent.pattern.cue, isNot(InteractionFeedbackCue.none));
      expect(intent.pattern.soundEvent, isA<MargaritavilleSoundEvent>());
    }
  });

  test('navigation commits keep their dedicated sound priority', () {
    expect(
      MargaritavilleInteractionIntent.openSettings.pattern.soundEvent,
      MargaritavilleSoundEvent.settingsOpen,
    );
    expect(
      MargaritavilleInteractionIntent.openSelection.pattern.soundEvent,
      MargaritavilleSoundEvent.selectionOpen,
    );
    expect(
      MargaritavilleInteractionIntent.openSettings.pattern.cue,
      InteractionFeedbackCue.confirm,
    );
  });
}
