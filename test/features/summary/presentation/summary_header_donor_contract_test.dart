import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/app/margaritaville_theme.dart';
import 'package:margaritaville_flutter/features/summary/presentation/summary_screen.dart';
import 'package:margaritaville_flutter/features/summary/presentation/summary_visual_policy.dart';
import 'package:margaritaville_flutter/shared/edr/edr_window_surface.dart';

import '../../../../integration_test/support/summary_performance_fixture.dart';

import 'support/summary_test_fixture.dart';

void main() {
  testWidgets('summary replaces Material app bar with donor header', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(440, 956);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: MargaritavilleTheme.dark,
          home: SummaryScreen(session: donorSession()),
        ),
      ),
    );

    final header = find.byKey(const Key('summary-header'));
    expect(header, findsOneWidget);
    expect(tester.getSize(header).height, 48);
    expect(find.text('Текущая смена'), findsNothing);
    expect(find.byKey(const Key('summary-filter-open')), findsOneWidget);
    expect(find.byKey(const Key('summary-filter-ready')), findsOneWidget);
    expect(find.byKey(const Key('summary-filter-scheduled')), findsOneWidget);
    expect(find.byKey(const Key('summary-filter-pending')), findsOneWidget);
  });

  testWidgets('summary restores the original platform scroll behavior', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(440, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: MargaritavilleTheme.dark.copyWith(
            platform: TargetPlatform.iOS,
          ),
          home: SummaryScreen(session: donorSession()),
        ),
      ),
    );

    expect(find.byType(SingleChildScrollView), findsNothing);
    final scrollView = tester.widget<ListView>(find.byType(ListView));
    expect(scrollView.physics, isA<AlwaysScrollableScrollPhysics>());
    expect(find.byType(EdrWindowSurface), findsNothing);
  });

  testWidgets('one stable EDR window runtime stays outside the scroll tree', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(440, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: MargaritavilleTheme.dark,
          home: SummaryScreen(
            session: donorSession(),
            visualPolicy: const SummaryVisualPolicy(
              vipHdrLightEnabled: true,
              statusPulseEnabled: true,
            ),
          ),
        ),
      ),
    );

    final surface = find.byType(EdrWindowSurface);
    final list = find.byType(ListView);
    expect(surface, findsOneWidget);
    expect(list, findsOneWidget);
    expect(
      find.ancestor(of: surface, matching: find.byType(ListView)),
      findsNothing,
    );
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('complete hotel owns exactly one stable EDR window runtime', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(440, 956);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    final session = summaryPerformanceSession(
      vipRoomCount: summaryPerformanceRoomCount,
    );
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: MargaritavilleTheme.dark,
          home: SummaryScreen(
            session: session,
            visualPolicy: const SummaryVisualPolicy(
              vipHdrLightEnabled: true,
              vipJellyEnabled: true,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(EdrWindowSurface), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -1600));
    await tester.pump();
    expect(find.byType(EdrWindowSurface), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('summary stays intact at physical Pixel width and font scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(346, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: MargaritavilleTheme.dark,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.15)),
            child: child!,
          ),
          home: SummaryScreen(session: donorSession()),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byKey(const Key('summary-header'))).height, 48);
    expect(find.byKey(const Key('summary-filter-pending')), findsOneWidget);
    expect(find.byKey(const Key('summary-room-101')), findsOneWidget);
  });
}
