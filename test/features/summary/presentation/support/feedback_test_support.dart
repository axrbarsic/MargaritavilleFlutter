import 'package:interaction_foundation/interaction_foundation.dart';
import 'package:margaritaville_flutter/features/interaction/domain/margaritaville_sound_routing.dart';
import 'package:margaritaville_flutter/features/interaction/domain/repositories/interaction_sound_settings_repository.dart';

final class RecordingFeedbackBridge implements InteractionFeedbackBridge {
  final requests = <InteractionFeedbackRequest>[];

  @override
  Future<void> clearPending() async {}

  @override
  Future<void> configure(
    InteractionFeedbackConfiguration configuration,
  ) async {}

  @override
  Future<void> emit(InteractionFeedbackRequest request) async {
    requests.add(request);
  }

  @override
  Future<void> previewSound(String soundId) async {}

  @override
  Future<void> setAudioContext(InteractionAudioContext context) async {}
}

final class MemorySoundRepository
    implements InteractionSoundSettingsRepository {
  @override
  Future<MargaritavilleSoundAssignments> load() async =>
      MargaritavilleSoundAssignments.defaults;

  @override
  Future<void> save(MargaritavilleSoundAssignments assignments) async {}
}
