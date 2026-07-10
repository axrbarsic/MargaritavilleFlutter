import '../margaritaville_sound_routing.dart';

abstract interface class InteractionSoundSettingsRepository {
  Future<MargaritavilleSoundAssignments> load();

  Future<void> save(MargaritavilleSoundAssignments assignments);
}
