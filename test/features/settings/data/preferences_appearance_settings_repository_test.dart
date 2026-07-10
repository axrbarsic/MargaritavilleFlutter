import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/settings/data/local/settings_key_value_store.dart';
import 'package:margaritaville_flutter/features/settings/data/repositories/preferences_appearance_settings_repository.dart';
import 'package:margaritaville_flutter/features/settings/domain/models/app_background_mode.dart';
import 'package:margaritaville_flutter/features/settings/domain/models/appearance_settings.dart';

void main() {
  test('persists each visual setting as an independent typed value', () async {
    final store = _MemorySettingsKeyValueStore();
    final repository = PreferencesAppearanceSettingsRepository(store);

    expect(await repository.load(), AppearanceSettings.defaults);

    const expected = AppearanceSettings(
      liveCellsEnabled: true,
      cellSpringIntensity: 0.48,
      vipJellyEnabled: false,
      vipJellySpeed: 1.25,
      vipHdrLightEnabled: true,
      statusHdrPulseEnabled: true,
      backgroundMode: AppBackgroundMode.off,
      matrixSpeed: 1.7,
    );
    await repository.save(expected);

    expect(await repository.load(), expected);
    expect(store.values.length, 8);
    expect(
      store.values.values,
      everyElement(isNot(isA<Map<Object?, Object?>>())),
    );
  });

  test('normalizes invalid persisted slider values on load', () async {
    final store = _MemorySettingsKeyValueStore(
      doubles: {
        PreferencesAppearanceSettingsRepository.cellSpringIntensityKey: -4,
        PreferencesAppearanceSettingsRepository.vipJellySpeedKey: 9,
        PreferencesAppearanceSettingsRepository.matrixSpeedKey: -4,
      },
    );
    final repository = PreferencesAppearanceSettingsRepository(store);

    final loaded = await repository.load();

    expect(loaded.cellSpringIntensity, 0);
    expect(loaded.vipJellySpeed, 2.5);
    expect(loaded.matrixSpeed, 0.08);
  });
}

final class _MemorySettingsKeyValueStore implements SettingsKeyValueStore {
  _MemorySettingsKeyValueStore({Map<String, double>? doubles})
    : values = <String, Object?>{...?doubles};

  final Map<String, Object?> values;

  @override
  Future<bool?> readBool(String key) async => values[key] as bool?;

  @override
  Future<double?> readDouble(String key) async => values[key] as double?;

  @override
  Future<String?> readString(String key) async => values[key] as String?;

  @override
  Future<void> writeBool(String key, bool value) async {
    values[key] = value;
  }

  @override
  Future<void> writeDouble(String key, double value) async {
    values[key] = value;
  }

  @override
  Future<void> writeString(String key, String value) async {
    values[key] = value;
  }
}
