import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:margaritaville_flutter/app/margaritaville_theme.dart';
import 'package:margaritaville_flutter/features/background/presentation/app_background_surface.dart';
import 'package:margaritaville_flutter/features/settings/domain/models/app_background_mode.dart';
import 'package:margaritaville_flutter/features/summary/presentation/summary_screen.dart';
import 'package:margaritaville_flutter/features/summary/presentation/summary_visual_policy.dart';
import 'package:margaritaville_flutter/shared/visual_runtime/visual_frame_clock.dart';
import 'package:margaritaville_flutter/shared/visual_runtime/visual_runtime_scope.dart';

import 'support/frame_timing_file_probe.dart';
import 'support/summary_performance_fixture.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  const requestedVipCount = int.fromEnvironment(
    'MARGARITAVILLE_PERF_VIP_COUNT',
    defaultValue: -1,
  );
  const requestedRoomCount = int.fromEnvironment(
    'MARGARITAVILLE_PERF_ROOM_COUNT',
    defaultValue: -1,
  );
  const edrEnabled = bool.fromEnvironment(
    'MARGARITAVILLE_PERF_EDR',
    defaultValue: true,
  );
  const jellyEnabled = bool.fromEnvironment(
    'MARGARITAVILLE_PERF_JELLY',
    defaultValue: true,
  );
  const sweepSeconds = int.fromEnvironment(
    'MARGARITAVILLE_PERF_SWEEP_SECONDS',
    defaultValue: 15,
  );
  const probeSeconds = int.fromEnvironment(
    'MARGARITAVILLE_PERF_PROBE_SECONDS',
    defaultValue: 34,
  );
  final roomCount = requestedRoomCount < 0
      ? summaryPerformanceRoomCount
      : requestedRoomCount.clamp(1, summaryPerformanceRoomCount);
  final vipCount = requestedVipCount < 0
      ? roomCount
      : requestedVipCount.clamp(0, roomCount);
  FrameTimingFileProbe(
    label:
        'ios-rooms-$roomCount-vip-$vipCount-edr-$edrEnabled-jelly-$jellyEnabled-sweep-$sweepSeconds',
    warmup: const Duration(seconds: 4),
    duration: Duration(seconds: probeSeconds.clamp(8, 120)),
  ).start();
  runApp(
    ProviderScope(
      child: _StressApp(
        roomCount: roomCount,
        vipCount: vipCount,
        edrEnabled: edrEnabled,
        jellyEnabled: jellyEnabled,
        sweepDuration: Duration(seconds: sweepSeconds.clamp(1, 60)),
      ),
    ),
  );
}

final class _StressApp extends StatelessWidget {
  const _StressApp({
    required this.roomCount,
    required this.vipCount,
    required this.edrEnabled,
    required this.jellyEnabled,
    required this.sweepDuration,
  });

  final int roomCount;
  final int vipCount;
  final bool edrEnabled;
  final bool jellyEnabled;
  final Duration sweepDuration;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: _StressSummary(
        roomCount: roomCount,
        vipCount: vipCount,
        edrEnabled: edrEnabled,
        jellyEnabled: jellyEnabled,
        sweepDuration: sweepDuration,
      ),
    );
  }
}

final class _StressSummary extends StatefulWidget {
  const _StressSummary({
    required this.roomCount,
    required this.vipCount,
    required this.edrEnabled,
    required this.jellyEnabled,
    required this.sweepDuration,
  });

  final int roomCount;
  final int vipCount;
  final bool edrEnabled;
  final bool jellyEnabled;
  final Duration sweepDuration;

  @override
  State<_StressSummary> createState() => _StressSummaryState();
}

final class _StressSummaryState extends State<_StressSummary> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), _sweepFullCatalog);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SummaryScreen(
      session: summaryPerformanceSession(
        roomCount: widget.roomCount,
        vipRoomCount: widget.vipCount,
      ),
      scrollController: _scrollController,
      visualPolicy: SummaryVisualPolicy(
        liveCellsEnabled: true,
        vipJellyEnabled: widget.jellyEnabled,
        vipHdrLightEnabled: widget.edrEnabled,
        statusPulseEnabled: widget.edrEnabled,
        vividStatusPaletteEnabled: true,
      ),
    );
  }

  Future<void> _sweepFullCatalog() async {
    if (!mounted || !_scrollController.hasClients) return;
    await _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: widget.sweepDuration,
      curve: Curves.linear,
    );
    if (!mounted || !_scrollController.hasClients) return;
    await _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: widget.sweepDuration,
      curve: Curves.linear,
    );
  }
}
