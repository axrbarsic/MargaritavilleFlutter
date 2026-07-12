import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/persistence/shared_preferences_settings_key_value_store.dart';
import '../../data/preferences_room_cell_calibration_repository.dart';
import '../../domain/models/room_cell_typography_profile.dart';
import '../../domain/repositories/room_cell_calibration_repository.dart';

final roomCellCalibrationRepositoryProvider =
    Provider<RoomCellCalibrationRepository>((ref) {
      return PreferencesRoomCellCalibrationRepository(
        SharedPreferencesSettingsKeyValueStore(),
      );
    });

final roomCellCalibrationControllerProvider =
    AsyncNotifierProvider<
      RoomCellCalibrationController,
      RoomCellCalibrationState
    >(RoomCellCalibrationController.new);

final class RoomCellCalibrationState {
  RoomCellCalibrationState({
    required this.platform,
    required Map<RoomCellLayoutProfile, RoomCellTypographyProfile> draft,
    required Map<RoomCellLayoutProfile, RoomCellTypographyProfile> applied,
  }) : draft = Map.unmodifiable(draft),
       applied = Map.unmodifiable(applied);

  final RoomCellCalibrationPlatform platform;
  final Map<RoomCellLayoutProfile, RoomCellTypographyProfile> draft;
  final Map<RoomCellLayoutProfile, RoomCellTypographyProfile> applied;

  RoomCellTypographyProfile draftFor(RoomCellLayoutProfile layout) =>
      draft[layout] ?? RoomCellTypographyProfile.defaults;

  RoomCellTypographyProfile appliedFor(RoomCellLayoutProfile layout) =>
      applied[layout] ?? RoomCellTypographyProfile.defaults;

  RoomCellCalibrationState copyWith({
    Map<RoomCellLayoutProfile, RoomCellTypographyProfile>? draft,
    Map<RoomCellLayoutProfile, RoomCellTypographyProfile>? applied,
  }) => RoomCellCalibrationState(
    platform: platform,
    draft: draft ?? this.draft,
    applied: applied ?? this.applied,
  );
}

final class RoomCellCalibrationController
    extends AsyncNotifier<RoomCellCalibrationState> {
  @override
  Future<RoomCellCalibrationState> build() async {
    final platform = switch (defaultTargetPlatform) {
      TargetPlatform.iOS => RoomCellCalibrationPlatform.ios,
      _ => RoomCellCalibrationPlatform.android,
    };
    final repository = ref.watch(roomCellCalibrationRepositoryProvider);
    final snapshots = await Future.wait([
      for (final layout in RoomCellLayoutProfile.values)
        repository.load(platform, layout),
    ]);
    final restored = <RoomCellLayoutProfile, RoomCellTypographyProfile>{
      for (var index = 0; index < RoomCellLayoutProfile.values.length; index++)
        RoomCellLayoutProfile.values[index]:
            snapshots[index]?.profile ?? RoomCellTypographyProfile.defaults,
    };
    return RoomCellCalibrationState(
      platform: platform,
      draft: restored,
      applied: restored,
    );
  }

  void updateDraft(
    RoomCellLayoutProfile layout,
    RoomCellTypographyProfile profile,
  ) {
    final current = state.requireValue;
    state = AsyncData(
      current.copyWith(draft: {...current.draft, layout: profile}),
    );
  }

  void apply(RoomCellLayoutProfile layout) {
    final current = state.requireValue;
    state = AsyncData(
      current.copyWith(
        applied: {...current.applied, layout: current.draftFor(layout)},
      ),
    );
  }

  void reset(RoomCellLayoutProfile layout) {
    updateDraft(layout, RoomCellTypographyProfile.defaults);
  }

  Future<RoomCellCalibrationSnapshot> save(RoomCellLayoutProfile layout) async {
    final current = state.requireValue;
    final snapshot = RoomCellCalibrationSnapshot(
      platform: current.platform,
      layout: layout,
      profile: current.draftFor(layout),
    );
    await ref.read(roomCellCalibrationRepositoryProvider).save(snapshot);
    apply(layout);
    return snapshot;
  }
}
