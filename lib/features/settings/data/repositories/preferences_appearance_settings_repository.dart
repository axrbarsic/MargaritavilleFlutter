import '../../domain/models/app_background_mode.dart';
import '../../domain/models/appearance_settings.dart';
import '../../domain/repositories/appearance_settings_repository.dart';
import '../local/settings_key_value_store.dart';

final class PreferencesAppearanceSettingsRepository
    implements AppearanceSettingsRepository {
  const PreferencesAppearanceSettingsRepository(this._store);

  static const liveCellsEnabledKey =
      'margaritaville.appearance.live_cells_enabled.v1';
  static const cellSpringIntensityKey =
      'margaritaville.appearance.cell_spring_intensity.v1';
  static const vipJellyEnabledKey =
      'margaritaville.appearance.vip_jelly_enabled.v1';
  static const vipJellySpeedKey =
      'margaritaville.appearance.vip_jelly_speed.v1';
  static const vipHdrLightEnabledKey =
      'margaritaville.appearance.vip_hdr_light_enabled.v1';
  static const statusHdrPulseEnabledKey =
      'margaritaville.appearance.status_hdr_pulse_enabled.v1';
  static const vividStatusPaletteEnabledKey =
      'margaritaville.appearance.vivid_status_palette_enabled.v1';
  static const backgroundModeKey =
      'margaritaville.appearance.background_mode.v1';
  static const matrixSpeedKey = 'margaritaville.appearance.matrix_speed.v1';

  final SettingsKeyValueStore _store;

  @override
  Future<AppearanceSettings> load() async {
    const defaults = AppearanceSettings.defaults;
    return AppearanceSettings(
      liveCellsEnabled:
          await _store.readBool(liveCellsEnabledKey) ??
          defaults.liveCellsEnabled,
      cellSpringIntensity:
          await _store.readDouble(cellSpringIntensityKey) ??
          defaults.cellSpringIntensity,
      vipJellyEnabled:
          await _store.readBool(vipJellyEnabledKey) ?? defaults.vipJellyEnabled,
      vipJellySpeed:
          await _store.readDouble(vipJellySpeedKey) ?? defaults.vipJellySpeed,
      vipHdrLightEnabled:
          await _store.readBool(vipHdrLightEnabledKey) ??
          defaults.vipHdrLightEnabled,
      statusHdrPulseEnabled:
          await _store.readBool(statusHdrPulseEnabledKey) ??
          defaults.statusHdrPulseEnabled,
      vividStatusPaletteEnabled:
          await _store.readBool(vividStatusPaletteEnabledKey) ??
          defaults.vividStatusPaletteEnabled,
      backgroundMode: _backgroundMode(
        await _store.readString(backgroundModeKey),
      ),
      matrixSpeed:
          await _store.readDouble(matrixSpeedKey) ?? defaults.matrixSpeed,
    ).normalized();
  }

  @override
  Future<void> save(AppearanceSettings settings) async {
    final value = settings.normalized();
    await Future.wait([
      _store.writeBool(liveCellsEnabledKey, value.liveCellsEnabled),
      _store.writeDouble(cellSpringIntensityKey, value.cellSpringIntensity),
      _store.writeBool(vipJellyEnabledKey, value.vipJellyEnabled),
      _store.writeDouble(vipJellySpeedKey, value.vipJellySpeed),
      _store.writeBool(vipHdrLightEnabledKey, value.vipHdrLightEnabled),
      _store.writeBool(statusHdrPulseEnabledKey, value.statusHdrPulseEnabled),
      _store.writeBool(
        vividStatusPaletteEnabledKey,
        value.vividStatusPaletteEnabled,
      ),
      _store.writeString(backgroundModeKey, value.backgroundMode.name),
      _store.writeDouble(matrixSpeedKey, value.matrixSpeed),
    ]);
  }

  AppBackgroundMode _backgroundMode(String? rawValue) {
    for (final mode in AppBackgroundMode.values) {
      if (mode.name == rawValue) return mode;
    }
    return AppearanceSettings.defaults.backgroundMode;
  }
}
