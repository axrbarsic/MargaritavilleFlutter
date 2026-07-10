import '../../../../shared/persistence/settings_key_value_store.dart';
import '../../domain/margaritaville_sound_routing.dart';
import '../../domain/repositories/interaction_sound_settings_repository.dart';

final class PreferencesInteractionSoundSettingsRepository
    implements InteractionSoundSettingsRepository {
  const PreferencesInteractionSoundSettingsRepository(this._store);

  static const interfaceActionsKey =
      'margaritaville.feedback.interface_actions_sound.v1';
  static const roomKey = 'margaritaville.feedback.room_sound.v1';
  static const roomReadyKey = 'margaritaville.feedback.room_ready_sound.v1';

  final SettingsKeyValueStore _store;

  @override
  Future<MargaritavilleSoundAssignments> load() async {
    const defaults = MargaritavilleSoundAssignments.defaults;
    return MargaritavilleSoundAssignments(
      interfaceActions: _asset(
        await _store.readString(interfaceActionsKey),
        defaults.interfaceActions,
      ),
      room: _asset(await _store.readString(roomKey), defaults.room),
      roomReady: _asset(
        await _store.readString(roomReadyKey),
        defaults.roomReady,
      ),
    );
  }

  @override
  Future<void> save(MargaritavilleSoundAssignments assignments) {
    return Future.wait([
      _store.writeString(interfaceActionsKey, assignments.interfaceActions.id),
      _store.writeString(roomKey, assignments.room.id),
      _store.writeString(roomReadyKey, assignments.roomReady.id),
    ]);
  }

  MargaritavilleSoundAsset _asset(
    String? rawValue,
    MargaritavilleSoundAsset fallback,
  ) {
    return MargaritavilleSoundAsset.fromId(rawValue) ?? fallback;
  }
}
