import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

final class FrameTimingFileProbe {
  FrameTimingFileProbe({
    required this.label,
    required this.warmup,
    required this.duration,
  });

  static const fileName = 'margaritaville_frame_probe.json';

  final String label;
  final Duration warmup;
  final Duration duration;
  final List<FrameTiming> _timings = [];
  Timer? _startTimer;
  Timer? _finishTimer;
  var _collecting = false;

  void start() {
    WidgetsBinding.instance.addTimingsCallback(_record);
    unawaited(_write({'state': 'warming_up', 'label': label}));
    _startTimer = Timer(warmup, () async {
      _timings.clear();
      await _write({'state': 'collecting', 'label': label});
      _collecting = true;
    });
    _finishTimer = Timer(warmup + duration, finish);
  }

  Future<void> finish() async {
    if (!_collecting && _finishTimer == null) return;
    _collecting = false;
    _startTimer?.cancel();
    _finishTimer?.cancel();
    _startTimer = null;
    _finishTimer = null;
    WidgetsBinding.instance.removeTimingsCallback(_record);
    await _write(FrameTimingSummary.from(_timings, label: label).toJson());
  }

  void _record(List<FrameTiming> timings) {
    if (_collecting) _timings.addAll(timings);
  }

  Future<void> _write(Map<String, Object?> payload) async {
    try {
      final file = File('${Directory.systemTemp.path}/$fileName');
      await file.writeAsString(jsonEncode(payload), flush: true);
    } catch (error) {
      debugPrint('Не удалось записать performance probe: $error');
    }
  }
}

@immutable
final class FrameTimingSummary {
  const FrameTimingSummary({
    required this.label,
    required this.refreshRate,
    required this.frameBudgetMicros,
    required this.frameCount,
    required this.effectiveFps,
    required this.p95BuildMicros,
    required this.p95RasterMicros,
    required this.p99BuildMicros,
    required this.p99RasterMicros,
    required this.maxBuildMicros,
    required this.maxRasterMicros,
    required this.overBudgetFrames,
    required this.largeVsyncGaps,
  });

  factory FrameTimingSummary.from(
    List<FrameTiming> timings, {
    required String label,
  }) {
    final refreshRate =
        PlatformDispatcher.instance.views.first.display.refreshRate;
    final normalizedRefreshRate = refreshRate > 0 ? refreshRate : 60.0;
    final budget = (Duration.microsecondsPerSecond / normalizedRefreshRate)
        .floor();
    final build = timings
        .map((timing) => timing.buildDuration.inMicroseconds)
        .toList();
    final raster = timings
        .map((timing) => timing.rasterDuration.inMicroseconds)
        .toList();
    final starts =
        timings
            .map(
              (timing) => timing.timestampInMicroseconds(FramePhase.vsyncStart),
            )
            .toList()
          ..sort();
    final elapsedMicros = starts.length < 2 ? 0 : starts.last - starts.first;
    final effectiveFps = elapsedMicros <= 0
        ? 0.0
        : (starts.length - 1) * Duration.microsecondsPerSecond / elapsedMicros;
    var largeVsyncGaps = 0;
    for (var index = 1; index < starts.length; index++) {
      if (starts[index] - starts[index - 1] > budget * 1.5) {
        largeVsyncGaps++;
      }
    }

    return FrameTimingSummary(
      label: label,
      refreshRate: normalizedRefreshRate,
      frameBudgetMicros: budget,
      frameCount: timings.length,
      effectiveFps: effectiveFps,
      p95BuildMicros: _percentile(build, 0.95),
      p95RasterMicros: _percentile(raster, 0.95),
      p99BuildMicros: _percentile(build, 0.99),
      p99RasterMicros: _percentile(raster, 0.99),
      maxBuildMicros: _maximum(build),
      maxRasterMicros: _maximum(raster),
      overBudgetFrames: [
        for (var index = 0; index < timings.length; index++)
          if (build[index] > budget || raster[index] > budget) index,
      ].length,
      largeVsyncGaps: largeVsyncGaps,
    );
  }

  final String label;
  final double refreshRate;
  final int frameBudgetMicros;
  final int frameCount;
  final double effectiveFps;
  final int p95BuildMicros;
  final int p95RasterMicros;
  final int p99BuildMicros;
  final int p99RasterMicros;
  final int maxBuildMicros;
  final int maxRasterMicros;
  final int overBudgetFrames;
  final int largeVsyncGaps;

  Map<String, Object?> toJson() => {
    'state': 'complete',
    'label': label,
    'refreshRate': refreshRate,
    'frameBudgetMicros': frameBudgetMicros,
    'frameCount': frameCount,
    'effectiveFps': effectiveFps,
    'p95BuildMicros': p95BuildMicros,
    'p95RasterMicros': p95RasterMicros,
    'p99BuildMicros': p99BuildMicros,
    'p99RasterMicros': p99RasterMicros,
    'maxBuildMicros': maxBuildMicros,
    'maxRasterMicros': maxRasterMicros,
    'overBudgetFrames': overBudgetFrames,
    'largeVsyncGaps': largeVsyncGaps,
  };
}

int _percentile(List<int> values, double percentile) {
  if (values.isEmpty) return 0;
  final sorted = [...values]..sort();
  return sorted[((sorted.length - 1) * percentile).round()];
}

int _maximum(List<int> values) {
  if (values.isEmpty) return 0;
  return values.reduce((first, second) => first > second ? first : second);
}
