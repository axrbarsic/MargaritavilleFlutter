abstract interface class SettingsKeyValueStore {
  Future<bool?> readBool(String key);

  Future<double?> readDouble(String key);

  Future<String?> readString(String key);

  Future<void> writeBool(String key, bool value);

  Future<void> writeDouble(String key, double value);

  Future<void> writeString(String key, String value);
}
