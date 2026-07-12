import 'dart:async';
import 'dart:ui' show SemanticsAction;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interaction_foundation/interaction_foundation.dart';
import 'package:margaritaville_flutter/features/interaction/domain/margaritaville_sound_routing.dart';
import 'package:margaritaville_flutter/features/summary/presentation/summary_visual_policy.dart';
import 'package:margaritaville_flutter/shared/edr/edr_overlay_bridge.dart';
import 'package:margaritaville_flutter/shared/edr/edr_overlay_controller.dart';
import 'package:margaritaville_flutter/shared/edr/generated/edr_overlay_api.g.dart';

import 'summary_header_interaction_test_support.dart';

void main() {
  testWidgets('settings hold emits one combined cue only on commit', (
    tester,
  ) async {
    final harness = SummaryHeaderFeedbackHarness();
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
    await tester.pump(const Duration(milliseconds: 459));
    expect(openings, 0);
    expect(harness.bridge.requests, isEmpty);
    await tester.pump(const Duration(milliseconds: 1));
    expect(openings, 1);
    expect(harness.bridge.requests, isEmpty);
    await hold.up();
    await tester.pump();
    expect(openings, 1);
    expect(harness.bridge.requests, isEmpty);
  });

  testWidgets(
    'settings hold tolerates finger jitter and late cancel is silent',
    (tester) async {
      final harness = SummaryHeaderFeedbackHarness();
      addTearDown(harness.dispose);
      var openings = 0;
      await tester.pumpWidget(harness.app(onOpenSettings: () => openings++));
      await tester.pump();

      final settings = find.byKey(const Key('summary-open-settings'));
      final tolerated = await tester.startGesture(tester.getCenter(settings));
      await tolerated.moveBy(const Offset(8.01, 0));
      await tester.pump(const Duration(milliseconds: 460));
      expect(openings, 1);
      expect(harness.bridge.requests, isEmpty);
      await tolerated.up();

      final cancelled = await tester.startGesture(tester.getCenter(settings));
      await tester.pump(const Duration(milliseconds: 340));
      await cancelled.moveBy(const Offset(30, 0));
      await tester.pump(const Duration(milliseconds: 200));
      await cancelled.up();

      expect(openings, 1);
      expect(harness.bridge.requests, isEmpty);
    },
  );

  testWidgets('settings uses a forgiving 54 by 48 point hit target', (
    tester,
  ) async {
    final harness = SummaryHeaderFeedbackHarness();
    addTearDown(harness.dispose);
    await tester.pumpWidget(harness.app());
    await tester.pump();

    expect(
      tester.getSize(find.byKey(const Key('summary-open-settings'))),
      const Size(54, 48),
    );
  });

  testWidgets('settings semantics exposes long press and commits once', (
    tester,
  ) async {
    final semanticsHandle = tester.ensureSemantics();
    final harness = SummaryHeaderFeedbackHarness();
    addTearDown(harness.dispose);
    var openings = 0;
    await tester.pumpWidget(harness.app(onOpenSettings: () => openings++));
    await tester.pump();

    final settings = find.byKey(const Key('summary-open-settings'));
    final data = tester.getSemantics(settings).getSemanticsData();
    expect(data.hasAction(SemanticsAction.longPress), isTrue);
    expect(data.hasAction(SemanticsAction.tap), isFalse);

    final semanticSettings = find.semantics.byLabel('Открыть настройки');
    tester.semantics.longPress(semanticSettings);
    tester.semantics.longPress(semanticSettings);
    await tester.pump();

    expect(openings, 1);
    expect(harness.bridge.requests, isEmpty);
    semanticsHandle.dispose();
  });

  testWidgets('settings hold recognizes every inner edge of its hit target', (
    tester,
  ) async {
    final harness = SummaryHeaderFeedbackHarness();
    addTearDown(harness.dispose);
    var openings = 0;
    await tester.pumpWidget(harness.app(onOpenSettings: () => openings++));
    await tester.pump();

    final rect = tester.getRect(find.byKey(const Key('summary-open-settings')));
    final points = <Offset>[
      rect.topLeft + const Offset(1, 1),
      rect.topRight + const Offset(-1, 1),
      rect.bottomLeft + const Offset(1, -1),
      rect.bottomRight + const Offset(-1, -1),
    ];

    for (final point in points) {
      final hold = await tester.startGesture(point);
      await tester.pump(const Duration(milliseconds: 460));
      await hold.up();
      await tester.pump();
    }

    expect(openings, points.length);
    expect(harness.bridge.requests, isEmpty);
  });

  testWidgets('pending settings route admits one semantic commit and cue', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(440, 956);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final semanticsHandle = tester.ensureSemantics();
    final harness = SummaryHeaderFeedbackHarness();
    addTearDown(harness.dispose);
    final routeCompleter = Completer<void>();
    var routeCalls = 0;
    await tester.pumpWidget(
      harness.summaryApp(
        onOpenSettings: () {
          routeCalls += 1;
          return routeCompleter.future;
        },
      ),
    );
    await tester.pump();

    final semanticSettings = find.semantics.byLabel('Открыть настройки');
    tester.semantics.longPress(semanticSettings);
    await tester.pump();
    tester.semantics.longPress(semanticSettings);
    await tester.pump();

    expect(routeCalls, 1);
    expect(harness.bridge.requests, hasLength(1));
    expect(interactionCues(harness), const [InteractionFeedbackCue.confirm]);
    expect(
      harness.bridge.requests.single.soundId,
      MargaritavilleSoundAsset.uiRolloverTick.id,
    );
    routeCompleter.complete();
    await tester.pump();
    semanticsHandle.dispose();
  });

  testWidgets('settings route does not start before exact native suspension', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    tester.view.physicalSize = const Size(440, 956);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final semanticsHandle = tester.ensureSemantics();
    final harness = SummaryHeaderFeedbackHarness();
    final bridge = _DeferredSettingsEdrBridge();
    final edrController = EdrOverlayController(bridge: bridge, supported: true);
    addTearDown(harness.dispose);
    addTearDown(edrController.dispose);
    var routeCalls = 0;
    await tester.pumpWidget(
      harness.summaryApp(
        edrController: edrController,
        visualPolicy: const SummaryVisualPolicy(statusPulseEnabled: true),
        onOpenSettings: () async {
          routeCalls += 1;
        },
      ),
    );
    for (var frame = 0; frame < 8; frame += 1) {
      await tester.pump();
    }
    expect(bridge.configureCount, greaterThan(0));

    tester.semantics.longPress(find.semantics.byLabel('Открыть настройки'));
    await tester.pump(const Duration(milliseconds: 249));
    expect(bridge.suspendCompleter, isNotNull);
    expect(routeCalls, 0);

    bridge.suspendCompleter!.complete();
    await tester.pump();
    expect(routeCalls, 1);
    debugDefaultTargetPlatformOverride = null;
    semanticsHandle.dispose();
  });
}

final class _DeferredSettingsEdrBridge implements EdrOverlayBridge {
  Completer<void>? suspendCompleter;
  var configureCount = 0;

  @override
  Future<void> configureWindow(
    int surfaceSessionId,
    int activationId,
    int layoutGeneration,
    int contentRevision,
    int presentationRevision,
    int geometryRevision,
    double viewportLeft,
    double viewportTop,
    double viewportWidth,
    double viewportHeight,
    double scrollOffsetX,
    double scrollOffsetY,
    List<EdrTileSnapshot> tiles,
  ) async {
    configureCount += 1;
  }

  @override
  Future<void> updateWindowGeometry(
    int surfaceSessionId,
    int activationId,
    int layoutGeneration,
    int presentationRevision,
    int geometryRevision,
    double viewportLeft,
    double viewportTop,
    double viewportWidth,
    double viewportHeight,
    double scrollOffsetX,
    double scrollOffsetY,
  ) async {}

  @override
  Future<EdrPresentationAck> suspendWindow(
    int surfaceSessionId,
    int activationId,
    int presentationRevision,
  ) async {
    suspendCompleter = Completer<void>();
    await suspendCompleter!.future;
    return EdrPresentationAck(
      surfaceSessionId: surfaceSessionId,
      activationId: activationId,
      presentationRevision: presentationRevision,
      suppressed: true,
      outcome: EdrPresentationOutcome.structurallyDetached,
      nativeGeneration: presentationRevision + 1,
      presentedAtNanos: 0,
    );
  }

  @override
  Future<void> clearWindow(
    int surfaceSessionId,
    int activationId,
    int contentRevision,
  ) async {}
}
