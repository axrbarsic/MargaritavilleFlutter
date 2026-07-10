import 'package:shared_preferences/shared_preferences.dart';

import 'settings_key_value_store.dart';

final class SharedPreferencesSettingsKeyValueStore
    implements SettingsKeyValueStore {
  SharedPreferencesSettingsKeyValueStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  @override
  Future<bool?> readBool(String key) => _preferences.getBool(key);

  @override
  Future<double?> readDouble(String key) => _preferences.getDouble(key);

  @override
  Future<String?> readString(String key) => _preferences.getString(key);

  @override
  Future<void> writeBool(String key, bool value) {
    return _preferences.setBool(key, value);
  }

  @override
  Future<void> writeDouble(String key, double value) {
    return _preferences.setDouble(key, value);
  }

  @override
  Future<void> writeString(String key, String value) {
    return _preferences.setString(key, value);
  }
}
