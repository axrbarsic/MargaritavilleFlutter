import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../design/margaritaville_colors.dart';
import '../../../../shared/visual_runtime/visual_runtime_activity.dart';
import '../../../../shared/visual_runtime/visual_runtime_scope.dart';
import '../../../work_session/domain/models/room_state.dart';
import '../summary_layout_tokens.dart';
import '../summary_visual_policy.dart';
import '../summary_visual_pulse.dart';
import 'room_status_light_painter.dart';
import 'vip_jelly_shape_clipper.dart';

final class RoomVisualEffectSurface extends StatelessWidget {
  const RoomVisualEffectSurface({
    required this.room,
    required this.baseColor,
    required this.policy,
    required this.child,
    this.pulseEvent,
    this.nativeEdrActive = false,
    super.key,
  });

  final RoomState room;
  final Color baseColor;
  final SummaryVisualPolicy policy;
  final SummaryVisualPulseEvent? pulseEvent;
  final bool nativeEdrActive;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final clock = VisualRuntimeScope.maybeClockOf(context);
    final shouldAnimate =
        (room.isVip && policy.vipJellyEnabled) ||
        (pulseEvent != null && policy.transientPulseEnabled);
    final surface = !shouldAnimate || clock == null
        ? _frame(now: DateTime.now(), seconds: 0)
        : AnimatedBuilder(
            animation: clock,
            builder: (context, _) {
              return _frame(now: clock.now, seconds: clock.seconds);
            },
          );
    return VisualRuntimeActivity(active: shouldAnimate, child: surface);
  }

  Widget _frame({required DateTime now, required double seconds}) {
    final vipJellyActive = room.isVip && policy.vipJellyEnabled;
    final vipLightActive = room.isVip && policy.vipHdrLightEnabled;
    final pulseHeat = policy.transientPulseEnabled ? _pulseHeat(now) : 0.0;
    final seed = _stableSeed(room.roomNumber);
    final speed = policy.vipJellySpeed.clamp(0.2, 2.5).toDouble();
    final time = seconds * speed + seed * 11;
    final jellyScaleX = vipJellyActive ? 1 + 0.012 * math.sin(time * 1.7) : 1.0;
    final jellyScaleY = vipJellyActive ? 1 + 0.018 * math.cos(time * 1.4) : 1.0;
    final jellyOffsetX = vipJellyActive ? 1.2 * math.sin(time * 1.1) : 0.0;
    final jellyOffsetY = vipJellyActive ? 0.8 * math.cos(time * 1.3) : 0.0;
    final pulseRubber =
        pulseHeat * SummaryStatusPulseTiming.rubberAmplitudeMultiplier;
    final pulseScale = 1 + 0.10 * policy.springIntensity * pulseRubber;
    final pulseOffsetY = -7.5 * policy.springIntensity * pulseRubber;
    final pulseColor = pulseEvent == null
        ? baseColor
        : MargaritavilleColors.vividStatus(pulseEvent!.status);
    final vipGlow = !nativeEdrActive && vipLightActive && policy.sdrGlowEnabled
        ? 0.34
        : 0.0;
    final pulseGlow =
        !nativeEdrActive && policy.sdrGlowEnabled && policy.statusPulseEnabled
        ? pulseHeat * 0.58
        : 0.0;
    final glow = math.max(vipGlow, pulseGlow).clamp(0.0, 0.72).toDouble();
    final glowColor = pulseGlow > vipGlow ? pulseColor : baseColor;

    final effectContent = Stack(
      fit: StackFit.expand,
      children: [
        child,
        if (!nativeEdrActive && vipLightActive && policy.sdrGlowEnabled)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                key: Key('vip-light-layer-${room.roomNumber}'),
                painter: RoomStatusLightPainter(
                  color: baseColor,
                  intensity: 1,
                  seed: seed,
                  cornerRadius: SummaryLayoutTokens.tileCornerRadius,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        if (!nativeEdrActive && pulseHeat > 0 && policy.statusPulseEnabled)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                key: Key('status-pulse-layer-${room.roomNumber}'),
                painter: RoomStatusLightPainter(
                  color: pulseColor,
                  intensity: pulseHeat,
                  seed: seed,
                  cornerRadius: SummaryLayoutTokens.tileCornerRadius,
                  fullFill: true,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
      ],
    );
    final shapedContent = vipJellyActive
        ? PhysicalShape(
            key: Key('vip-jelly-shape-${room.roomNumber}'),
            clipper: VipJellyShapeClipper(
              seconds: seconds,
              speed: speed,
              seed: seed,
              cornerRadius: SummaryLayoutTokens.tileCornerRadius,
            ),
            color: Colors.transparent,
            shadowColor: Colors.black,
            elevation: 4,
            clipBehavior: Clip.antiAlias,
            child: effectContent,
          )
        : effectContent;

    return RepaintBoundary(
      child: Transform.translate(
        offset: Offset(jellyOffsetX, jellyOffsetY + pulseOffsetY),
        child: Transform.scale(
          scaleX: jellyScaleX * pulseScale,
          scaleY: jellyScaleY * pulseScale,
          alignment: Alignment.center,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                SummaryLayoutTokens.tileCornerRadius,
              ),
              boxShadow: glow <= 0
                  ? null
                  : [
                      BoxShadow(
                        color: glowColor.withValues(alpha: glow),
                        blurRadius: 8 + 12 * glow,
                        spreadRadius: 0.5 + 1.5 * glow,
                      ),
                    ],
            ),
            child: shapedContent,
          ),
        ),
      ),
    );
  }

  double _pulseHeat(DateTime now) {
    final event = pulseEvent;
    if (event == null) return 0;
    return SummaryStatusPulseTiming.heat(now.difference(event.startedAt));
  }

  double _stableSeed(String value) {
    var hash = 2166136261;
    for (final codeUnit in value.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 16777619) & 0xFFFFFFFF;
    }
    return (hash & 0xFFFF) / 0xFFFF;
  }
}
