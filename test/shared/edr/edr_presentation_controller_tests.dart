part of 'edr_viewport_controller_test.dart';

void _registerEdrPresentationTests() {
  testWidgets(
    'pending configure cannot cross presentation suspend before late ready',
    (tester) async {
      final bridge = _DeferredSuspendEdrBridge();
      final controller = EdrOverlayController(bridge: bridge, supported: true);
      final renderKey = GlobalKey();
      addTearDown(controller.dispose);

      await tester.pumpWidget(_controllerHost(controller, renderKey));
      _registerTile(controller, renderKey);
      controller.attachWindow();
      await tester.pump();

      final configuration = bridge.configurations.single;
      var acquireCompleted = false;
      EdrPresentationOcclusion? occlusion;
      final acquire = controller.acquirePresentationOcclusion().then((value) {
        acquireCompleted = true;
        occlusion = value;
      });
      await tester.pump();

      expect(bridge.suspensions, hasLength(1));
      expect(bridge.pendingSuspend, isNotNull);
      expect(acquireCompleted, isFalse);

      bridge.pendingSuspend!.complete();
      await acquire;
      EdrReadyRouter.instance.windowReady(
        controller.surfaceSessionId,
        configuration.activationId,
        configuration.contentRevision,
        configuration.presentationRevision,
      );
      await tester.pump();
      expect(controller.isTileRendered('101', renderKey), isFalse);
      occlusion!.release();
    },
  );

  testWidgets(
    'committed native frame cannot hold navigation past suspend deadline',
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
      EdrReadyRouter.instance.windowReady(
        controller.surfaceSessionId,
        configuration.activationId,
        configuration.contentRevision,
        configuration.presentationRevision,
      );
      await tester.pump();
      expect(renderState.value, isTrue);

      var acquireCompleted = false;
      EdrPresentationOcclusion? occlusion;
      final acquire = controller.acquirePresentationOcclusion().then((value) {
        acquireCompleted = true;
        occlusion = value;
      });
      await tester.pump();
      expect(renderState.value, isFalse);
      expect(acquireCompleted, isFalse);

      await tester.pump(const Duration(milliseconds: 249));
      expect(acquireCompleted, isFalse);
      await tester.pump(const Duration(milliseconds: 1));
      await acquire;
      expect(acquireCompleted, isTrue);

      occlusion!.release();
      bridge.pendingSuspend!.complete();
      await tester.pump();
    },
  );

  testWidgets('readiness from another Summary session is ignored', (
    tester,
  ) async {
    final bridge = _RecordingEdrBridge();
    final controller = EdrOverlayController(bridge: bridge, supported: true);
    final renderKey = GlobalKey();
    addTearDown(controller.dispose);

    await tester.pumpWidget(_controllerHost(controller, renderKey));
    _registerTile(controller, renderKey);
    controller.attachWindow();
    await tester.pump();
    final configuration = bridge.configurations.single;

    EdrReadyRouter.instance.windowReady(
      controller.surfaceSessionId + 1,
      configuration.activationId,
      configuration.contentRevision,
      configuration.presentationRevision,
    );
    await tester.pump();

    expect(controller.isTileRendered('101', renderKey), isFalse);
  });

  testWidgets(
    'readiness with stale presentation revision cannot hide fallback',
    (tester) async {
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

      EdrReadyRouter.instance.windowReady(
        controller.surfaceSessionId,
        configuration.activationId,
        configuration.contentRevision,
        configuration.presentationRevision - 1,
      );
      await tester.pump();
      expect(renderState.value, isFalse);

      EdrReadyRouter.instance.windowReady(
        controller.surfaceSessionId,
        configuration.activationId,
        configuration.contentRevision,
        configuration.presentationRevision,
      );
      await tester.pump();
      expect(renderState.value, isTrue);
    },
  );

  testWidgets(
    '100 rapid scroll updates keep one geometry in flight and latest offset',
    (tester) async {
      final bridge = _DeferredGeometryEdrBridge();
      final controller = EdrOverlayController(bridge: bridge, supported: true);
      final renderKey = GlobalKey();
      addTearDown(controller.dispose);

      await tester.pumpWidget(_controllerHost(controller, renderKey));
      _registerTile(controller, renderKey);
      controller.attachWindow();
      await tester.pump();
      final configuration = bridge.configurations.single;
      EdrReadyRouter.instance.windowReady(
        controller.surfaceSessionId,
        configuration.activationId,
        configuration.contentRevision,
        configuration.presentationRevision,
      );
      await tester.pump();

      for (var offset = 1; offset <= 100; offset += 1) {
        controller.updateScrollOffset(Offset(0, offset.toDouble()));
      }
      await tester.pump();

      expect(bridge.pendingGeometryCount, 1);
      expect(bridge.maximumActiveGeometryCalls, 1);
      expect(bridge.geometries, hasLength(1));

      bridge.completeNextGeometry();
      await tester.pump();

      expect(bridge.pendingGeometryCount, 1);
      expect(bridge.maximumActiveGeometryCalls, 1);
      expect(bridge.geometries, hasLength(2));
      expect(bridge.geometries.last.scrollOffset, const Offset(0, 100));

      bridge.completeNextGeometry();
      await tester.pump();
      expect(bridge.pendingGeometryCount, 0);
      expect(bridge.maximumActiveGeometryCalls, 1);
    },
  );

  testWidgets(
    'manual presentation occlusion awaits suspend and restores when eligible',
    (tester) async {
      final bridge = _DeferredSuspendEdrBridge();
      final controller = EdrOverlayController(bridge: bridge, supported: true);
      final renderKey = GlobalKey();
      addTearDown(controller.dispose);

      await tester.pumpWidget(_controllerHost(controller, renderKey));
      _registerTile(controller, renderKey);
      controller.attachWindow();
      await tester.pump();
      final firstConfiguration = bridge.configurations.single;
      EdrReadyRouter.instance.windowReady(
        controller.surfaceSessionId,
        firstConfiguration.activationId,
        firstConfiguration.contentRevision,
        firstConfiguration.presentationRevision,
      );
      await tester.pump();

      var acquireCompleted = false;
      EdrPresentationOcclusion? occlusion;
      final acquire = controller.acquirePresentationOcclusion().then((value) {
        acquireCompleted = true;
        occlusion = value;
      });
      await tester.pump();

      expect(bridge.suspensions, hasLength(1));
      expect(acquireCompleted, isFalse);
      expect(bridge.configurations, hasLength(1));

      bridge.pendingSuspend!.complete();
      await acquire;
      expect(acquireCompleted, isTrue);

      controller.setWindowVisible(false);
      occlusion!.release();
      await tester.pump();
      await tester.pump();
      expect(bridge.configurations, hasLength(1));

      controller.setWindowVisible(true);
      await tester.pump();
      expect(bridge.configurations, hasLength(2));
      expect(
        bridge.configurations.last.activationId,
        greaterThan(firstConfiguration.activationId),
      );
    },
  );

  testWidgets(
    'real route push suspends and pop waits for transition plus stable frames',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
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
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(bridge.configurations, hasLength(1));

      unawaited(
        navigatorKey.currentState!.push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: Text('Поверх EDR')),
          ),
        ),
      );
      await tester.pump();
      expect(bridge.suspensions, hasLength(1));
      await tester.pumpAndSettle();
      final countWhileCovered = bridge.configurations.length;

      navigatorKey.currentState!.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 299));
      expect(bridge.configurations, hasLength(countWhileCovered));

      await tester.pump(const Duration(milliseconds: 1));
      expect(bridge.configurations, hasLength(countWhileCovered));
      await tester.pump();
      expect(bridge.configurations, hasLength(countWhileCovered));
      await tester.pump();
      expect(bridge.configurations, hasLength(countWhileCovered));
      await tester.pump();
      expect(bridge.configurations, hasLength(countWhileCovered));
      await tester.pumpAndSettle();
      expect(bridge.configurations, hasLength(countWhileCovered + 1));
      debugDefaultTargetPlatformOverride = null;
    },
  );
}
