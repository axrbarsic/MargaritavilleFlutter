import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/persistence/shared_preferences_settings_key_value_store.dart';
import '../../data/repositories/preferences_interaction_sound_settings_repository.dart';
import '../../domain/margaritaville_sound_routing.dart';
import '../../domain/repositories/interaction_sound_settings_repository.dart';

final interactionSoundSettingsRepositoryProvider =
    Provider<InteractionSoundSettingsRepository>((ref) {
      return PreferencesInteractionSoundSettingsRepository(
        SharedPreferencesSettingsKeyValueStore(),
      );
    });

final interactionSoundSettingsControllerProvider =
    AsyncNotifierProvider<
      InteractionSoundSettingsController,
      MargaritavilleSoundAssignments
    >(InteractionSoundSettingsController.new);

final class InteractionSoundSettingsController
    extends AsyncNotifier<MargaritavilleSoundAssignments> {
  Future<void> _writeTail = Future<void>.value();

  @override
  Future<MargaritavilleSoundAssignments> build() {
    return ref.watch(interactionSoundSettingsRepositoryProvider).load();
  }

  Future<void> setAsset(
    MargaritavilleSoundSlot slot,
    MargaritavilleSoundAsset asset,
  ) {
    final completer = Completer<void>();
    _writeTail = _writeTail.then((_) async {
      try {
        final current = state.requireValue;
        final next = current.withAsset(slot, asset);
        if (next == current) {
          completer.complete();
          return;
        }
        await ref.read(interactionSoundSettingsRepositoryProvider).save(next);
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
