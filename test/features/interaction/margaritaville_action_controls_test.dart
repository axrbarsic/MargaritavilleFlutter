import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interaction_foundation/interaction_foundation.dart';
import 'package:margaritaville_flutter/features/interaction/application/margaritaville_feedback_controller.dart';
import 'package:margaritaville_flutter/features/interaction/presentation/margaritaville_feedback_scope.dart';
import 'package:margaritaville_flutter/features/settings/presentation/widgets/appearance_settings_controls.dart';

void main() {
  testWidgets('toggle row and nested switch emit one accepted action each', (
    tester,
  ) async {
    final bridge = _RecordingBridge();
    final controller = MargaritavilleFeedbackController(
      runtime: InteractionFeedbackRuntime(bridge: bridge),
    );
    addTearDown(controller.dispose);
    var changes = 0;
    await tester.pumpWidget(
      ProviderScope(
        child: MargaritavilleFeedbackScope(
          controller: controller,
          child: MaterialApp(
            home: Scaffold(
              body: AppearanceSettingToggleRow(
                title: 'VIP HDR-свет',
                subtitle: 'Тест',
                icon: Icons.wb_sunny_rounded,
                value: false,
                onChanged: (_) => changes += 1,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('VIP HDR-свет'));
    await tester.pump();
    expect(changes, 1);
    expect(bridge.requests, hasLength(1));
    expect(bridge.requests.single.cue, InteractionFeedbackCue.select);

    bridge.requests.clear();
    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(changes, 2);
    expect(bridge.requests, hasLength(1));
    expect(bridge.requests.single.cue, InteractionFeedbackCue.select);
  });
}

final class _RecordingBridge implements InteractionFeedbackBridge {
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
