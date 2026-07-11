import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interaction_foundation/interaction_foundation.dart';
import 'package:margaritaville_flutter/app/margaritaville_theme.dart';
import 'package:margaritaville_flutter/features/interaction/application/margaritaville_feedback_controller.dart';
import 'package:margaritaville_flutter/features/interaction/domain/margaritaville_sound_routing.dart';
import 'package:margaritaville_flutter/features/interaction/domain/repositories/interaction_sound_settings_repository.dart';
import 'package:margaritaville_flutter/features/interaction/presentation/controllers/interaction_sound_settings_controller.dart';
import 'package:margaritaville_flutter/features/interaction/presentation/margaritaville_feedback_scope.dart';
import 'package:margaritaville_flutter/features/summary/presentation/summary_screen.dart';
import 'package:margaritaville_flutter/features/summary/presentation/widgets/summary_header.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/hotel_profile.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/housekeeper.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/room_state.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_assignment.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_session.dart';
import 'package:margaritaville_flutter/shared/edr/edr_overlay_controller.dart';

List<InteractionFeedbackCue> interactionCues(
  SummaryHeaderFeedbackHarness harness,
) => harness.bridge.requests.map((request) => request.cue).toList();

double settingsOpacity(WidgetTester tester) => tester
    .widget<Opacity>(find.byKey(const Key('summary-settings-opacity')))
    .opacity;

final class SummaryHeaderFeedbackHarness {
  final bridge = RecordingFeedbackBridge();
  late final controller = MargaritavilleFeedbackController(
    runtime: InteractionFeedbackRuntime(bridge: bridge),
  );

  Widget app({
    VoidCallback? onOpenSettings,
    VoidCallback? onOpenSelection,
    ValueChanged<RoomDisplayStatus?>? onFilterChanged,
  }) {
    return ProviderScope(
      overrides: [
        interactionSoundSettingsRepositoryProvider.overrideWithValue(
          MemorySoundRepository(),
        ),
      ],
      child: MargaritavilleFeedbackScope(
        controller: controller,
        child: MaterialApp(
          theme: MargaritavilleTheme.dark,
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 440,
                height: 48,
                child: SummaryHeader(
                  session: _session(),
                  activeFilter: null,
                  onFilterChanged: onFilterChanged ?? (_) {},
                  onOpenSettings: onOpenSettings ?? () {},
                  onOpenSelection: onOpenSelection ?? () {},
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget summaryApp({required Future<void> Function() onOpenSettings}) {
    return ProviderScope(
      overrides: [
        interactionSoundSettingsRepositoryProvider.overrideWithValue(
          MemorySoundRepository(),
        ),
      ],
      child: MargaritavilleFeedbackScope(
        controller: controller,
        child: MaterialApp(
          theme: MargaritavilleTheme.dark,
          home: SummaryScreen(
            session: _session(),
            edrController: EdrOverlayController(supported: false),
            onOpenSettings: onOpenSettings,
          ),
        ),
      ),
    );
  }

  void dispose() => controller.dispose();
}

final class RecordingFeedbackBridge implements InteractionFeedbackBridge {
  final requests = <InteractionFeedbackRequest>[];

  @override
  Future<void> clearPending() async {}

  @override
  Future<void> configure(
    InteractionFeedbackConfiguration configuration,
  ) async {}

  @override
  Future<void> emit(InteractionFeedbackRequest request) async {
    requests.add(request);
  }

  @override
  Future<void> previewSound(String soundId) async {}

  @override
  Future<void> setAudioContext(InteractionAudioContext context) async {}
}

final class MemorySoundRepository
    implements InteractionSoundSettingsRepository {
  @override
  Future<MargaritavilleSoundAssignments> load() async =>
      MargaritavilleSoundAssignments.defaults;

  @override
  Future<void> save(MargaritavilleSoundAssignments assignments) async {}
}

WorkSession _session() {
  final startedAt = DateTime(2027, 2, 10, 20, 47);
  return WorkSession.create(
    id: 'header-interaction-fixture',
    hotel: HotelProfile.margaritaville,
    startedAt: startedAt,
    assignments: [
      WorkAssignment(
        id: 'work-block-1',
        cartNumber: 1,
        housekeeper: Housekeeper(
          id: 'ketty',
          displayName: 'Ketty',
          paletteKey: 'ruby',
          updatedAt: startedAt,
        ),
        assignedAt: startedAt,
        updatedAt: startedAt,
        rooms: [RoomState.pending(roomNumber: '101', selectedAt: startedAt)],
      ),
    ],
  ).lockWorkday(changedAt: startedAt);
}
