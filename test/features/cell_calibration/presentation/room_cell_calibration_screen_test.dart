import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/app/margaritaville_theme.dart';
import 'package:margaritaville_flutter/features/cell_calibration/domain/models/room_cell_typography_profile.dart';
import 'package:margaritaville_flutter/features/cell_calibration/domain/repositories/room_cell_calibration_repository.dart';
import 'package:margaritaville_flutter/features/cell_calibration/presentation/controllers/room_cell_calibration_controller.dart';
import 'package:margaritaville_flutter/features/cell_calibration/presentation/room_cell_calibration_screen.dart';
import 'package:margaritaville_flutter/features/cell_calibration/presentation/two_finger_scale_gesture_recognizer.dart';
import 'package:margaritaville_flutter/features/summary/presentation/summary_visual_policy.dart';
import 'package:margaritaville_flutter/features/summary/presentation/widgets/room_status_tile.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/room_state.dart';
import 'package:margaritaville_flutter/shared/edr/edr_overlay_controller.dart';

import '../../../support/test_feedback_scope.dart';

void main() {
  testWidgets('real two-finger scale updates selected role and Apply state', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = _MemoryRepository();
    final edr = EdrOverlayController(supported: false);
    addTearDown(edr.dispose);
    await tester.pumpWidget(_stand(repository, edr));
    await tester.pumpAndSettle();

    final tile = find.byType(RoomStatusTile).first;
    final scrollable = tester.state<ScrollableState>(
      find.byType(Scrollable).first,
    );
    final initialOffset = scrollable.position.pixels;
    final center = tester.getCenter(tile);
    final first = await tester.startGesture(
      center + const Offset(-2, 0),
      pointer: 1,
    );
    final second = await tester.startGesture(
      center + const Offset(2, 0),
      pointer: 2,
    );
    await tester.pump();
    await first.moveTo(center + const Offset(-28, 0));
    await second.moveTo(center + const Offset(28, 0));
    await tester.pump();
    await first.up();
    await second.up();
    await tester.pump();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(RoomCellCalibrationScreen)),
    );
    final draft = container
        .read(roomCellCalibrationControllerProvider)
        .requireValue
        .draftFor(RoomCellLayoutProfile.four);
    expect(draft.roomNumberSize, greaterThan(44));
    expect(draft.roomTimeSize, 16);
    expect(scrollable.position.pixels, initialOffset);

    await tester.tap(find.byKey(const Key('cell-calibration-apply')));
    await tester.pump();
    final applied = container
        .read(roomCellCalibrationControllerProvider)
        .requireValue
        .appliedFor(RoomCellLayoutProfile.four);
    expect(applied, draft);
    expect(tester.widget<RoomStatusTile>(tile).typographyProfile, draft);
  });

  testWidgets('calibration gesture never builds production long-press action', (
    tester,
  ) async {
    var advances = 0;
    final room = RoomState.pending(
      roomNumber: '101',
      selectedAt: DateTime.utc(2027, 2, 10),
    );
    await tester.pumpWidget(
      ProviderScope(
        child: TestFeedbackScope(
          child: MaterialApp(
            theme: MargaritavilleTheme.dark,
            home: Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: RoomStatusTile(
                  room: room,
                  onAdvance: () => advances++,
                  onReset: () {},
                  onToggleVip: () {},
                  onSchedule: () {},
                  onOpenMedia: () {},
                  calibrationGesture: RoomCellCalibrationGesture({
                    TwoFingerScaleGestureRecognizer:
                        GestureRecognizerFactoryWithHandlers<
                          TwoFingerScaleGestureRecognizer
                        >(
                          TwoFingerScaleGestureRecognizer.new,
                          (recognizer) => recognizer.onUpdate = (_) {},
                        ),
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final center = tester.getCenter(find.byType(RoomStatusTile));
    final first = await tester.startGesture(
      center - const Offset(8, 0),
      pointer: 3,
    );
    final second = await tester.startGesture(
      center + const Offset(8, 0),
      pointer: 4,
    );
    await tester.pump(const Duration(seconds: 1));
    await first.moveBy(const Offset(-12, 0));
    await second.moveBy(const Offset(12, 0));
    await first.up();
    await second.up();

    expect(advances, 0);
  });
}

Widget _stand(
  RoomCellCalibrationRepository repository,
  EdrOverlayController edr,
) => ProviderScope(
  overrides: [
    roomCellCalibrationRepositoryProvider.overrideWithValue(repository),
  ],
  child: TestFeedbackScope(
    child: MaterialApp(
      theme: MargaritavilleTheme.dark,
      home: RoomCellCalibrationScreen(
        edrController: edr,
        baseVisualPolicy: SummaryVisualPolicy.balanced,
        onClose: () {},
      ),
    ),
  ),
);

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
