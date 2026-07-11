import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/shared/device/app_installation_identity.dart';
import 'package:margaritaville_flutter/shared/persistence/settings_key_value_store.dart';

void main() {
  test(
    'creates one durable installation identity and then reuses it',
    () async {
      final store = _MemoryStore();
      final identity = AppInstallationIdentity(
        store: store,
        random: Random(7),
        now: () => DateTime.utc(2027, 2, 10, 12),
      );

      final first = await identity.load();
      final second = await identity.load();

      expect(first, second);
      expect(first, startsWith('install-'));
      expect(store.writes, 1);
    },
  );

  test('replaces an invalid legacy value with a typed identity', () async {
    final store = _MemoryStore()..value = '../unsafe';
    final result = await AppInstallationIdentity(
      store: store,
      random: Random(9),
      now: () => DateTime.utc(2027, 2, 10, 12),
    ).load();

    expect(result, isNot('../unsafe'));
    expect(store.value, result);
  });
}

final class _MemoryStore implements SettingsKeyValueStore {
  String? value;
  int writes = 0;

  @override
  Future<String?> readString(String key) async => value;

  @override
  Future<void> writeString(String key, String value) async {
    this.value = value;
    writes += 1;
  }

  @override
  Future<bool?> readBool(String key) => throw UnimplementedError();

  @override
  Future<double?> readDouble(String key) => throw UnimplementedError();

  @override
  Future<void> writeBool(String key, bool value) => throw UnimplementedError();

  @override
  Future<void> writeDouble(String key, double value) =>
      throw UnimplementedError();
}
