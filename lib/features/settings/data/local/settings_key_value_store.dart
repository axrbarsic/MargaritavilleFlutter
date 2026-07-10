abstract interface class SettingsKeyValueStore {
  Future<bool?> readBool(String key);

  Future<double?> readDouble(String key);

  Future<void> writeBool(String key, bool value);

  Future<void> writeDouble(String key, double value);
}
