import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/cell_calibration/domain/models/room_cell_typography_profile.dart';
import 'package:margaritaville_flutter/features/cell_calibration/domain/repositories/room_cell_calibration_repository.dart';
import 'package:margaritaville_flutter/features/cell_calibration/presentation/controllers/room_cell_calibration_controller.dart';

void main() {
  test(
    '3 and 4 column drafts stay independent and saved profile reopens',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final repository = _MemoryRepository();
      var container = ProviderContainer(
        overrides: [
          roomCellCalibrationRepositoryProvider.overrideWithValue(repository),
        ],
      );
      await container.read(roomCellCalibrationControllerProvider.future);
      final controller = container.read(
        roomCellCalibrationControllerProvider.notifier,
      );
      const three = RoomCellTypographyProfile(
        roomNumberSize: 51,
        roomTimeSize: 19,
      );
      controller.updateDraft(RoomCellLayoutProfile.three, three);
      controller.updateDraft(
        RoomCellLayoutProfile.four,
        const RoomCellTypographyProfile(roomNumberSize: 40, roomTimeSize: 14),
      );
      controller.reset(RoomCellLayoutProfile.four);

      expect(
        container
            .read(roomCellCalibrationControllerProvider)
            .requireValue
            .draftFor(RoomCellLayoutProfile.four),
        RoomCellTypographyProfile.defaults,
      );
      await controller.save(RoomCellLayoutProfile.three);
      container.dispose();

      container = ProviderContainer(
        overrides: [
          roomCellCalibrationRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      final reopened = await container.read(
        roomCellCalibrationControllerProvider.future,
      );
      expect(reopened.appliedFor(RoomCellLayoutProfile.three), three);
      expect(
        reopened.appliedFor(RoomCellLayoutProfile.four),
        RoomCellTypographyProfile.defaults,
      );
    },
  );
}

final class _MemoryRepository implements RoomCellCalibrationRepository {
  final Map<
    (RoomCellCalibrationPlatform, RoomCellLayoutProfile),
    RoomCellCalibrationSnapshot
  >
  values = {};

  @override
  Future<RoomCellCalibrationSnapshot?> load(
    RoomCellCalibrationPlatform platform,
    RoomCellLayoutProfile layout,
  ) async => values[(platform, layout)];

  @override
  Future<void> save(RoomCellCalibrationSnapshot snapshot) async {
    values[(snapshot.platform, snapshot.layout)] = snapshot;
  }
}
