part of 'edr_viewport_controller_test.dart';

void _registerEdrPresentationFenceTests() {
  testWidgets(
    'nested presentation acquires share one exact native suspension',
    (tester) async {
      final bridge = _DeferredSuspendEdrBridge();
      final controller = EdrOverlayController(bridge: bridge, supported: true);
      final renderKey = GlobalKey();
      addTearDown(controller.dispose);

      await tester.pumpWidget(_controllerHost(controller, renderKey));
      _registerTile(controller, renderKey);
      controller.attachWindow();
      await tester.pump();

      var firstCompleted = false;
      var secondCompleted = false;
      final first = controller.acquirePresentationOcclusion().then((value) {
        firstCompleted = true;
        return value;
      });
      final second = controller.acquirePresentationOcclusion().then((value) {
        secondCompleted = true;
        return value;
      });
      await tester.pump();

      expect(bridge.suspensions, hasLength(1));
      expect(firstCompleted, isFalse);
      expect(secondCompleted, isFalse);

      bridge.pendingSuspend!.complete();
      final firstOcclusion = await first;
      final secondOcclusion = await second;
      expect(firstCompleted, isTrue);
      expect(secondCompleted, isTrue);

      firstOcclusion.release();
      await tester.pump();
      expect(bridge.configurations, hasLength(1));
      secondOcclusion.release();
      await tester.pump();
      expect(bridge.configurations, hasLength(2));
    },
  );

  testWidgets('rejected exact suspension blocks route and reacquires owner', (
    tester,
  ) async {
    final bridge = _RejectedSuspendEdrBridge();
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
    _dispatchReady(
      controller.surfaceSessionId,
      configuration.activationId,
      configuration.contentRevision,
      configuration.presentationRevision,
    );
    await tester.pump();
    expect(renderState.value, isTrue);

    await expectLater(
      controller.acquirePresentationOcclusion(),
      throwsA(isA<StateError>()),
    );
    expect(renderState.value, isFalse);
    expect(bridge.suspensions, hasLength(1));
    await tester.pump();
    await tester.pump();
    expect(bridge.configurations, hasLength(2));
    expect(
      bridge.configurations.last.activationId,
      greaterThan(configuration.activationId),
    );
    expect(bridge.suspensions, hasLength(1));
  });

  testWidgets('rejected suppression never poisons a later visible owner', (
    tester,
  ) async {
    final bridge = _RejectedSuspendEdrBridge();
    final controller = EdrOverlayController(bridge: bridge, supported: true);
    final renderKey = GlobalKey();
    addTearDown(controller.dispose);

    await tester.pumpWidget(_controllerHost(controller, renderKey));
    _registerTile(controller, renderKey);
    controller.attachWindow();
    await tester.pump();
    final configuration = bridge.configurations.single;
    final ready = EdrReadyRouter.instance.windowReady(
      controller.surfaceSessionId,
      configuration.activationId,
      configuration.contentRevision,
      configuration.presentationRevision,
    );
    await tester.pump();
    await ready;

    await expectLater(
      controller.acquirePresentationOcclusion(),
      throwsA(isA<StateError>()),
    );
    await tester.pump();
    await tester.pump();

    expect(bridge.suspensions, hasLength(1));
    expect(bridge.configurations, hasLength(2));
    expect(
      bridge.configurations.last.activationId,
      greaterThan(configuration.activationId),
    );
  });

  testWidgets('resume awaits rejection then reacquires without suspend retry', (
    tester,
  ) async {
    final bridge = _RejectThenAcceptDeferredSuspendBridge();
    final controller = EdrOverlayController(bridge: bridge, supported: true);
    final renderKey = GlobalKey();
    addTearDown(controller.dispose);

    await tester.pumpWidget(_controllerHost(controller, renderKey));
    _registerTile(controller, renderKey);
    controller.attachWindow();
    await tester.pump();
    final configuration = bridge.configurations.single;
    final ready = EdrReadyRouter.instance.windowReady(
      controller.surfaceSessionId,
      configuration.activationId,
      configuration.contentRevision,
      configuration.presentationRevision,
    );
    await tester.pump();
    await ready;

    controller.setWindowVisible(false);
    await tester.pump();
    controller.setWindowVisible(true);
    await tester.pump();
    expect(bridge.configurations, hasLength(1));

    bridge.completeNext();
    await tester.pump();
    await tester.pump();
    expect(bridge.suspensions, hasLength(1));
    expect(bridge.configurations, hasLength(2));
    expect(
      bridge.configurations.last.activationId,
      greaterThan(configuration.activationId),
    );
  });

  testWidgets(
    'removed fallback still awaits last native membership suppression',
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
      final configuration = bridge.configurations.single;
      final ready = EdrReadyRouter.instance.windowReady(
        controller.surfaceSessionId,
        configuration.activationId,
        configuration.contentRevision,
        configuration.presentationRevision,
      );
      await tester.pump();
      await ready;
      expect(renderState.value, isTrue);

      controller.removeTile('101', renderKey: renderKey);
      expect(renderState.value, isFalse);

      var acquired = false;
      final acquisition = controller.acquirePresentationOcclusion().then((v) {
        acquired = true;
        return v;
      });
      await tester.pump(EdrOverlayController.presentationSuspendDeadline);

      expect(acquired, isFalse);
      expect(bridge.suspensions, hasLength(1));

      bridge.pendingSuspend!.complete();
      await tester.pump();
      final occlusion = await acquisition;
      expect(acquired, isTrue);
      occlusion.release();
    },
  );

  testWidgets(
    'interactive pop cancel keeps the covered native surface suppressed',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final bridge = _RecordingEdrBridge();
      final controller = EdrOverlayController(bridge: bridge, supported: true);
      final navigatorKey = GlobalKey<NavigatorState>();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: Scaffold(body: EdrWindowSurface(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();
      final uncoveredConfigurations = bridge.configurations.length;

      unawaited(
        navigatorKey.currentState!.push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: Text('Настройки')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(bridge.suspensions, isNotEmpty);
      expect(bridge.configurations.length, uncoveredConfigurations);

      final gesture = await tester.startGesture(const Offset(1, 320));
      await gesture.moveBy(const Offset(80, 0));
      await tester.pump();
      await gesture.cancel();
      await tester.pumpAndSettle();

      expect(navigatorKey.currentState!.canPop(), isTrue);
      expect(bridge.configurations.length, uncoveredConfigurations);
      debugDefaultTargetPlatformOverride = null;
    },
  );

  testWidgets('rapid push-pop resumes only after terminal stable frames', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final bridge = _RecordingEdrBridge();
    final controller = EdrOverlayController(bridge: bridge, supported: true);
    final navigatorKey = GlobalKey<NavigatorState>();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: Scaffold(body: EdrWindowSurface(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();
    final initialConfigurations = bridge.configurations.length;

    unawaited(
      navigatorKey.currentState!.push<void>(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('Настройки')),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 32));
    navigatorKey.currentState!.pop();
    await tester.pump();
    expect(bridge.configurations.length, initialConfigurations);
    await tester.pumpAndSettle();
    expect(bridge.configurations.length, initialConfigurations + 1);
    debugDefaultTargetPlatformOverride = null;
  });
}
