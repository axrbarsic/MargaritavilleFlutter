part of 'edr_viewport_controller_test.dart';

void _registerEdrPresentationReadinessTests() {
  testWidgets('readiness awaits Flutter frame and rejects stale presentation', (
    tester,
  ) async {
    final bridge = _RecordingEdrBridge();
    final controller = EdrOverlayController(bridge: bridge, supported: true);
    final renderKey = GlobalKey();
    final renderState = ValueNotifier(false);
    addTearDown(controller.dispose);
    addTearDown(renderState.dispose);

    await tester.pumpWidget(_controllerHost(controller, renderKey));
    _registerTile(controller, renderKey, renderState: renderState);
    controller.attachWindow();
    await tester.pump();
    final configuration = bridge.configurations.single;

    final stale = await EdrReadyRouter.instance.windowReady(
      controller.surfaceSessionId,
      configuration.activationId,
      configuration.contentRevision,
      configuration.presentationRevision - 1,
    );
    expect(stale.accepted, isFalse);

    var completed = false;
    final ready = EdrReadyRouter.instance
        .windowReady(
          controller.surfaceSessionId,
          configuration.activationId,
          configuration.contentRevision,
          configuration.presentationRevision,
        )
        .then((value) {
          completed = true;
          return value;
        });
    expect(completed, isFalse);
    await tester.pump();
    expect((await ready).accepted, isTrue);
    expect(renderState.value, isTrue);
  });

  testWidgets('duplicate exact ready has one in-flight fallback owner', (
    tester,
  ) async {
    final bridge = _RecordingEdrBridge();
    final controller = EdrOverlayController(bridge: bridge, supported: true);
    final renderKey = GlobalKey();
    final renderState = ValueNotifier(false);
    addTearDown(controller.dispose);
    addTearDown(renderState.dispose);

    await tester.pumpWidget(_controllerHost(controller, renderKey));
    _registerTile(controller, renderKey, renderState: renderState);
    controller.attachWindow();
    await tester.pump();
    final configuration = bridge.configurations.single;

    final first = EdrReadyRouter.instance.windowReady(
      controller.surfaceSessionId,
      configuration.activationId,
      configuration.contentRevision,
      configuration.presentationRevision,
    );
    final duplicate = await EdrReadyRouter.instance.windowReady(
      controller.surfaceSessionId,
      configuration.activationId,
      configuration.contentRevision,
      configuration.presentationRevision,
    );
    expect(duplicate.accepted, isFalse);

    await tester.pump();
    expect((await first).accepted, isTrue);
    expect(renderState.value, isTrue);
  });

  testWidgets('content change rejects ready before Flutter frame ack', (
    tester,
  ) async {
    final bridge = _RecordingEdrBridge();
    final controller = EdrOverlayController(bridge: bridge, supported: true);
    final renderKey = GlobalKey();
    final renderState = ValueNotifier(false);
    addTearDown(controller.dispose);
    addTearDown(renderState.dispose);

    await tester.pumpWidget(_controllerHost(controller, renderKey));
    _registerTile(controller, renderKey, renderState: renderState);
    controller.attachWindow();
    await tester.pump();
    final configuration = bridge.configurations.single;

    final ready = EdrReadyRouter.instance.windowReady(
      controller.surfaceSessionId,
      configuration.activationId,
      configuration.contentRevision,
      configuration.presentationRevision,
    );
    controller.upsertTile(
      roomId: '101',
      timeText: '9:41 PM',
      renderKey: renderKey,
      renderState: renderState,
      baseColorArgb: 0xFF00E524,
      cornerRadius: 16,
      vipHdrEnabled: true,
      vipJellyEnabled: true,
      vipJellySpeed: 0.75,
      springIntensity: 0.72,
    );
    await tester.pump();
    expect((await ready).accepted, isFalse);
    expect(renderState.value, isFalse);
  });

  testWidgets('superseded configurations retain only the current ready fence', (
    tester,
  ) async {
    final bridge = _RecordingEdrBridge();
    final controller = EdrOverlayController(bridge: bridge, supported: true);
    final renderKey = GlobalKey();
    final renderState = ValueNotifier(false);
    addTearDown(controller.dispose);
    addTearDown(renderState.dispose);

    await tester.pumpWidget(_controllerHost(controller, renderKey));
    _registerTile(controller, renderKey, renderState: renderState);
    controller.attachWindow();
    await tester.pump();

    for (var update = 0; update < 8; update++) {
      controller.upsertTile(
        roomId: '101',
        timeText: '9:${40 + update} PM',
        renderKey: renderKey,
        renderState: renderState,
        baseColorArgb: 0xFF00E524,
        cornerRadius: 16,
        vipHdrEnabled: true,
        vipJellyEnabled: true,
        vipJellySpeed: 0.75,
        springIntensity: 0.72,
      );
      await tester.pump();
      expect(controller.debugPendingConfigurationCount, 1);
    }

    expect(bridge.configurations, hasLength(9));
    expect(renderState.value, isFalse);
  });

  testWidgets(
    'never-owned scene timeout and reacquire share outstanding suppression',
    (tester) async {
      final bridge = _DeferredSuspendEdrBridge();
      final controller = EdrOverlayController(bridge: bridge, supported: true);
      final renderKey = GlobalKey();
      final renderState = ValueNotifier(false);
      addTearDown(controller.dispose);
      addTearDown(renderState.dispose);

      await tester.pumpWidget(_controllerHost(controller, renderKey));
      _registerTile(controller, renderKey, renderState: renderState);
      controller.attachWindow();
      await tester.pump();
      final firstFuture = controller.acquirePresentationOcclusion();
      await tester.pump(const Duration(milliseconds: 250));
      final first = await firstFuture;
      first.release();

      var secondCompleted = false;
      final secondFuture = controller.acquirePresentationOcclusion().then((v) {
        secondCompleted = true;
        return v;
      });
      await tester.pump(const Duration(milliseconds: 249));
      expect(secondCompleted, isFalse);
      expect(bridge.suspensions, hasLength(1));
      expect(bridge.configurations, hasLength(1));

      await tester.pump(const Duration(milliseconds: 1));
      final second = await secondFuture;
      expect(secondCompleted, isTrue);
      expect(bridge.configurations, hasLength(1));

      bridge.pendingSuspend!.complete();
      await tester.pump();
      second.release();
      await tester.pump();
      expect(bridge.configurations, hasLength(2));
    },
  );
}
