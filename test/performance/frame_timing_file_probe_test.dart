import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import '../../integration_test/support/frame_timing_file_probe.dart';

void main() {
  test('probe summary reports percentiles, budget misses and vsync gaps', () {
    final timings = [
      for (var index = 0; index < 100; index++)
        _timing(index, slow: index >= 95),
    ];

    final summary = FrameTimingSummary.from(timings, label: 'contract');

    expect(summary.frameCount, 100);
    expect(summary.p95BuildMicros, 2000);
    expect(summary.p95RasterMicros, 3000);
    expect(summary.p99BuildMicros, 20000);
    expect(summary.p99RasterMicros, 22000);
    expect(summary.maxBuildMicros, 20000);
    expect(summary.maxRasterMicros, 22000);
    expect(summary.overBudgetFrames, 5);
    expect(summary.largeVsyncGaps, 1);
    expect(summary.toJson()['state'], 'complete');
  });
}

FrameTiming _timing(int index, {required bool slow}) {
  final vsync = index * 16666 + (index >= 50 ? 40000 : 0);
  final buildDuration = slow ? 20000 : 2000;
  final rasterDuration = slow ? 22000 : 3000;
  return FrameTiming(
    vsyncStart: vsync,
    buildStart: vsync + 100,
    buildFinish: vsync + 100 + buildDuration,
    rasterStart: vsync + 200,
    rasterFinish: vsync + 200 + rasterDuration,
    rasterFinishWallTime: vsync + 200 + rasterDuration,
  );
}
