import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:margaritaville_flutter/app/margaritaville_theme.dart';
import 'package:margaritaville_flutter/features/background/presentation/app_background_surface.dart';
import 'package:margaritaville_flutter/features/settings/domain/models/app_background_mode.dart';
import 'package:margaritaville_flutter/features/summary/presentation/summary_screen.dart';
import 'package:margaritaville_flutter/features/summary/presentation/summary_visual_policy.dart';
import 'package:margaritaville_flutter/shared/visual_runtime/visual_frame_clock.dart';
import 'package:margaritaville_flutter/shared/visual_runtime/visual_runtime_scope.dart';

import 'support/summary_performance_fixture.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const strictPerformance = bool.fromEnvironment(
    'MARGARITAVILLE_STRICT_PERFORMANCE',
    defaultValue: true,
  );

  testWidgets('Summary scroll follows the physical display frame budget', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: MargaritavilleTheme.dark,
          builder: (context, child) => VisualRuntimeScope(
            policy: const VisualFramePolicy(),
            enabled: true,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const AppBackgroundSurface(
                  mode: AppBackgroundMode.matrixRain,
                  matrixSpeed: 1,
                ),
                child!,
              ],
            ),
          ),
          home: SummaryScreen(
            session: summaryPerformanceSession(),
            visualPolicy: const SummaryVisualPolicy(
              liveCellsEnabled: true,
              vipJellyEnabled: true,
              vipHdrLightEnabled: true,
              statusPulseEnabled: true,
              vividStatusPaletteEnabled: true,
            ),
          ),
        ),
      ),
    );
    await binding.delayed(const Duration(seconds: 3));

    final scrollable = find.byType(SingleChildScrollView);
    expect(scrollable, findsOneWidget);
    await _exerciseScroll(tester, binding, passes: 2);

    const measuredPasses = 8;
    const passDuration = Duration(milliseconds: 800);
    await binding.watchPerformance(
      () => _exerciseScroll(
        tester,
        binding,
        passes: measuredPasses,
        passDuration: passDuration,
      ),
      reportKey: 'summary_scroll',
    );

    final report = Map<String, Object?>.from(
      binding.reportData!['summary_scroll']! as Map,
    );
    final buildTimes = List<int>.from(report['frame_build_times']! as List);
    final rasterTimes = List<int>.from(
      report['frame_rasterizer_times']! as List,
    );
    final refreshRate =
        ui.PlatformDispatcher.instance.views.first.display.refreshRate;
    final frameBudgetMicros = (Duration.microsecondsPerSecond / refreshRate)
        .floor();
    final p95Build = _percentile(buildTimes, 0.95);
    final p95Raster = _percentile(rasterTimes, 0.95);
    final measuredSeconds = measuredPasses * passDuration.inMilliseconds / 1000;
    final minimumFrameCount = (refreshRate * measuredSeconds * 0.70).floor();

    debugPrint(
      'SUMMARY_SCROLL refresh=${refreshRate.toStringAsFixed(1)}Hz '
      'budget=${frameBudgetMicros}us frames=${buildTimes.length} '
      'p95Build=${p95Build}us p95Raster=${p95Raster}us',
    );

    if (strictPerformance) {
      expect(buildTimes.length, greaterThanOrEqualTo(minimumFrameCount));
      expect(
        math.max(p95Build, p95Raster),
        lessThanOrEqualTo(frameBudgetMicros),
      );
    } else {
      expect(buildTimes, isNotEmpty);
      expect(rasterTimes, isNotEmpty);
    }
  });
}

Future<void> _exerciseScroll(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding, {
  required int passes,
  Duration passDuration = const Duration(milliseconds: 600),
}) async {
  final scrollable = find.byType(SingleChildScrollView);
  for (var pass = 0; pass < passes; pass++) {
    await tester.fling(scrollable, Offset(0, pass.isEven ? -900 : 900), 2800);
    await binding.delayed(passDuration);
  }
}

int _percentile(List<int> values, double percentile) {
  final sorted = [...values]..sort();
  return sorted[((sorted.length - 1) * percentile).round()];
}
