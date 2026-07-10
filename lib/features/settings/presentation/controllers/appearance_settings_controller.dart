import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/persistence/shared_preferences_settings_key_value_store.dart';
import '../../data/repositories/preferences_appearance_settings_repository.dart';
import '../../domain/models/app_background_mode.dart';
import '../../domain/models/appearance_settings.dart';
import '../../domain/repositories/appearance_settings_repository.dart';

final appearanceSettingsRepositoryProvider =
    Provider<AppearanceSettingsRepository>((ref) {
      return PreferencesAppearanceSettingsRepository(
        SharedPreferencesSettingsKeyValueStore(),
      );
    });

final appearanceSettingsControllerProvider =
    AsyncNotifierProvider<AppearanceSettingsController, AppearanceSettings>(
      AppearanceSettingsController.new,
    );

final class AppearanceSettingsController
    extends AsyncNotifier<AppearanceSettings> {
  Future<void> _writeTail = Future<void>.value();

  @override
  Future<AppearanceSettings> build() {
    return ref.watch(appearanceSettingsRepositoryProvider).load();
  }

  Future<void> setLiveCellsEnabled(bool enabled) {
    return _update((value) => value.copyWith(liveCellsEnabled: enabled));
  }

  Future<void> setCellSpringIntensity(double intensity) {
    return _update((value) => value.copyWith(cellSpringIntensity: intensity));
  }

  Future<void> setVipJellyEnabled(bool enabled) {
    return _update((value) => value.copyWith(vipJellyEnabled: enabled));
  }

  Future<void> setVipJellySpeed(double speed) {
    return _update((value) => value.copyWith(vipJellySpeed: speed));
  }

  Future<void> setVipHdrLightEnabled(bool enabled) {
    return _update((value) => value.copyWith(vipHdrLightEnabled: enabled));
  }

  Future<void> setStatusHdrPulseEnabled(bool enabled) {
    return _update((value) => value.copyWith(statusHdrPulseEnabled: enabled));
  }

  Future<void> setVividStatusPaletteEnabled(bool enabled) {
    return _update(
      (value) => value.copyWith(vividStatusPaletteEnabled: enabled),
    );
  }

  Future<void> resetVisualEffects() {
    return _update((_) => AppearanceSettings.defaults);
  }

  Future<void> setBackgroundMode(AppBackgroundMode mode) {
    return _update((value) => value.copyWith(backgroundMode: mode));
  }

  Future<void> setMatrixSpeed(double speed) {
    return _update((value) => value.copyWith(matrixSpeed: speed));
  }

  Future<void> _update(
    AppearanceSettings Function(AppearanceSettings current) transform,
  ) {
    final completer = Completer<void>();
    _writeTail = _writeTail.then((_) async {
      try {
        final current = state.requireValue;
        final next = transform(current).normalized();
        if (next == current) {
          completer.complete();
          return;
        }
        await ref.read(appearanceSettingsRepositoryProvider).save(next);
        state = AsyncData(next);
        completer.complete();
      } catch (error, stackTrace) {
        state = AsyncError(error, stackTrace);
        completer.complete();
      }
    });
    return completer.future;
  }
}
