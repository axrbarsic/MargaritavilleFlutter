import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/interaction/data/repositories/preferences_interaction_sound_settings_repository.dart';
import 'package:margaritaville_flutter/features/interaction/domain/margaritaville_sound_routing.dart';
import 'package:margaritaville_flutter/shared/persistence/settings_key_value_store.dart';

void main() {
  test(
    'persists the three donor assignments as independent typed values',
    () async {
      final store = _MemorySettingsKeyValueStore();
      final repository = PreferencesInteractionSoundSettingsRepository(store);

      expect(await repository.load(), MargaritavilleSoundAssignments.defaults);

      const expected = MargaritavilleSoundAssignments(
        interfaceActions: MargaritavilleSoundAsset.none,
        room: MargaritavilleSoundAsset.uiMenuOpen,
        roomReady: MargaritavilleSoundAsset.kenneyBong1,
      );
      await repository.save(expected);

      expect(await repository.load(), expected);
      expect(store.values, hasLength(3));
      expect(store.values.values, everyElement(isA<String>()));
    },
  );

  test('falls back per slot when a stored sound id is unknown', () async {
    final store = _MemorySettingsKeyValueStore(
      strings: {
        PreferencesInteractionSoundSettingsRepository.interfaceActionsKey:
            'removed-sound',
        PreferencesInteractionSoundSettingsRepository.roomKey:
            MargaritavilleSoundAsset.uiAlertSnap.id,
      },
    );
    final repository = PreferencesInteractionSoundSettingsRepository(store);

    final loaded = await repository.load();

    expect(
      loaded.interfaceActions,
      MargaritavilleSoundAssignments.defaults.interfaceActions,
    );
    expect(loaded.room, MargaritavilleSoundAsset.uiAlertSnap);
    expect(loaded.roomReady, MargaritavilleSoundAssignments.defaults.roomReady);
  });
}

final class _MemorySettingsKeyValueStore implements SettingsKeyValueStore {
  _MemorySettingsKeyValueStore({Map<String, String>? strings})
    : values = <String, Object?>{...?strings};

  final Map<String, Object?> values;

  @override
  Future<bool?> readBool(String key) async => values[key] as bool?;

  @override
  Future<double?> readDouble(String key) async => values[key] as double?;

  @override
  Future<String?> readString(String key) async => values[key] as String?;

  @override
  Future<void> writeBool(String key, bool value) async => values[key] = value;

  @override
  Future<void> writeDouble(String key, double value) async =>
      values[key] = value;

  @override
  Future<void> writeString(String key, String value) async =>
      values[key] = value;
}
