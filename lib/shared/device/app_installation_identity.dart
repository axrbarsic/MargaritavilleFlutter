import 'dart:math';

import '../persistence/settings_key_value_store.dart';

final class AppInstallationIdentity {
  AppInstallationIdentity({
    required SettingsKeyValueStore store,
    Random? random,
    DateTime Function()? now,
  }) : _store = store,
       _random = random ?? Random.secure(),
       _now = now ?? DateTime.now;

  static const storageKey = 'app.installation.identity.v1';

  final SettingsKeyValueStore _store;
  final Random _random;
  final DateTime Function() _now;

  Future<String> load() async {
    final existing = await _store.readString(storageKey);
    if (existing != null && _valid.hasMatch(existing)) return existing;

    final timestamp = _now().toUtc().microsecondsSinceEpoch.toRadixString(16);
    final entropy = List.generate(
      8,
      (_) => _random.nextInt(0x10000).toRadixString(16).padLeft(4, '0'),
    ).join();
    final generated = 'install-$timestamp-$entropy';
    await _store.writeString(storageKey, generated);
    return generated;
  }

  static final RegExp _valid = RegExp(r'^install-[a-f0-9]+-[a-f0-9]{32}$');
}
