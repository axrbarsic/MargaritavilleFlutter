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
import 'package:margaritaville_flutter/features/summary/presentation/widgets/summary_header.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/hotel_profile.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/housekeeper.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/room_state.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_assignment.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_session.dart';

void main() {
  testWidgets('settings requires the exact donor hold sequence', (
    tester,
  ) async {
    final harness = _FeedbackHarness();
    addTearDown(harness.dispose);
    var openings = 0;
    await tester.pumpWidget(harness.app(onOpenSettings: () => openings++));
    await tester.pump();

    final settings = find.byKey(const Key('summary-open-settings'));
    await tester.tap(settings);
    await tester.pump(const Duration(milliseconds: 500));
    expect(openings, 0);
    expect(harness.bridge.requests, isEmpty);

    final hold = await tester.startGesture(tester.getCenter(settings));
    await tester.pump(const Duration(milliseconds: 139));
    expect(harness.bridge.requests, isEmpty);
    await tester.pump(const Duration(milliseconds: 1));
    expect(_cues(harness), const [InteractionFeedbackCue.holdStart]);
    await tester.pump(const Duration(milliseconds: 190));
    expect(_cues(harness), const [
      InteractionFeedbackCue.holdStart,
      InteractionFeedbackCue.holdWarning,
    ]);
    await tester.pump(const Duration(milliseconds: 130));
    expect(openings, 1);
    expect(_cues(harness), const [
      InteractionFeedbackCue.holdStart,
      InteractionFeedbackCue.holdWarning,
      InteractionFeedbackCue.holdCommit,
      InteractionFeedbackCue.none,
    ]);
    expect(harness.bridge.requests.last.soundPriority, 70);
    await hold.up();
  });

  testWidgets('settings hold cancels beyond eight points', (tester) async {
    final harness = _FeedbackHarness();
    addTearDown(harness.dispose);
    var openings = 0;
    await tester.pumpWidget(harness.app(onOpenSettings: () => openings++));
    await tester.pump();

    final settings = find.byKey(const Key('summary-open-settings'));
    final hold = await tester.startGesture(tester.getCenter(settings));
    await hold.moveBy(const Offset(8.01, 0));
    await tester.pump(const Duration(milliseconds: 500));
    await hold.up();

    expect(openings, 0);
    expect(harness.bridge.requests, isEmpty);
  });

  testWidgets('puzzle emits donor thresholds and resets after 160ms', (
    tester,
  ) async {
    final harness = _FeedbackHarness();
    addTearDown(harness.dispose);
    var completions = 0;
    await tester.pumpWidget(harness.app(onOpenSelection: () => completions++));
    await tester.pump();

    const travel = 337.0;
    final puzzle = find.byKey(const Key('unlock-workday'));
    final drag = await tester.startGesture(tester.getCenter(puzzle));
    await drag.moveBy(const Offset(-3, 0));
    await tester.pump();
    expect(_cues(harness), const [InteractionFeedbackCue.holdStart]);

    await drag.moveBy(const Offset(-(travel * 0.5 - 3), 0));
    await tester.pump();
    final halfOpacity = tester.widget<Opacity>(
      find.byKey(const Key('summary-settings-opacity')),
    );
    expect(halfOpacity.opacity, closeTo(0.175, 0.001));

    await drag.moveBy(const Offset(-(travel * 0.33), 0));
    await tester.pump();
    expect(_cues(harness), const [
      InteractionFeedbackCue.holdStart,
      InteractionFeedbackCue.holdWarning,
    ]);

    await drag.moveBy(const Offset(-(travel * 0.18), 0));
    await tester.pump();
    expect(_cues(harness), const [
      InteractionFeedbackCue.holdStart,
      InteractionFeedbackCue.holdWarning,
      InteractionFeedbackCue.holdCommit,
    ]);

    await drag.up();
    await tester.pump();
    expect(completions, 1);
    expect(_cues(harness), const [
      InteractionFeedbackCue.holdStart,
      InteractionFeedbackCue.holdWarning,
      InteractionFeedbackCue.holdCommit,
      InteractionFeedbackCue.confirm,
      InteractionFeedbackCue.confirm,
      InteractionFeedbackCue.none,
    ]);
    expect(harness.bridge.requests.last.soundPriority, 70);
    expect(_settingsOpacity(tester), 0);
    await tester.pump(const Duration(milliseconds: 159));
    expect(_settingsOpacity(tester), 0);
    await tester.pump(const Duration(milliseconds: 1));
    expect(_settingsOpacity(tester), 1);
  });

  testWidgets('status filter emits one tap cue before changing', (
    tester,
  ) async {
    final harness = _FeedbackHarness();
    addTearDown(harness.dispose);
    RoomDisplayStatus? selected;
    await tester.pumpWidget(
      harness.app(onFilterChanged: (value) => selected = value),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('summary-filter-open')));
    await tester.pump();

    expect(selected, RoomDisplayStatus.open);
    expect(_cues(harness), const [InteractionFeedbackCue.tap]);
  });
}

List<InteractionFeedbackCue> _cues(_FeedbackHarness harness) =>
    harness.bridge.requests.map((request) => request.cue).toList();

double _settingsOpacity(WidgetTester tester) => tester
    .widget<Opacity>(find.byKey(const Key('summary-settings-opacity')))
    .opacity;

final class _FeedbackHarness {
  final bridge = _RecordingFeedbackBridge();
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
          _MemorySoundRepository(),
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

  void dispose() => controller.dispose();
}

final class _RecordingFeedbackBridge implements InteractionFeedbackBridge {
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

final class _MemorySoundRepository
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
