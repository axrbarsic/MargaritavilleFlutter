import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../shared/visual_runtime/visual_runtime_activity.dart';
import '../../../../shared/visual_runtime/visual_runtime_scope.dart';
import '../../../work_session/domain/models/room_state.dart';
import '../summary_layout_tokens.dart';
import '../summary_visual_policy.dart';
import '../summary_visual_pulse.dart';
import 'vip_jelly_shape_clipper.dart';

final class RoomVisualEffectSurface extends StatelessWidget {
  const RoomVisualEffectSurface({
    required this.room,
    required this.baseColor,
    required this.policy,
    required this.child,
    this.pulseEvent,
    super.key,
  });

  final RoomState room;
  final Color baseColor;
  final SummaryVisualPolicy policy;
  final SummaryVisualPulseEvent? pulseEvent;
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
    final brightColor = Color.lerp(baseColor, Colors.white, 0.48)!;
    final vipGlow = vipLightActive && policy.sdrGlowEnabled ? 0.34 : 0.0;
    final pulseGlow = policy.sdrGlowEnabled && policy.statusPulseEnabled
        ? pulseHeat * 0.58
        : 0.0;
    final glow = math.max(vipGlow, pulseGlow).clamp(0.0, 0.72).toDouble();

    final effectContent = Stack(
      children: [
        child,
        if (vipLightActive && policy.sdrGlowEnabled)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                key: Key('vip-light-layer-${room.roomNumber}'),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      -0.40 + 0.16 * math.sin(seed * math.pi * 2),
                      -0.56,
                    ),
                    radius: 0.90,
                    colors: [
                      brightColor.withValues(alpha: 0.34),
                      brightColor.withValues(alpha: 0.10),
                      Colors.transparent,
                    ],
                    stops: const [0, 0.46, 1],
                  ),
                  borderRadius: BorderRadius.circular(
                    SummaryLayoutTokens.tileCornerRadius,
                  ),
                ),
              ),
            ),
          ),
        if (pulseHeat > 0 && policy.statusPulseEnabled)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                key: Key('status-pulse-layer-${room.roomNumber}'),
                decoration: BoxDecoration(
                  color: brightColor.withValues(
                    alpha: (pulseHeat * 0.50).clamp(0, 0.50).toDouble(),
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: pulseHeat * 0.45),
                  ),
                  borderRadius: BorderRadius.circular(
                    SummaryLayoutTokens.tileCornerRadius,
                  ),
                ),
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
                        color: brightColor.withValues(alpha: glow),
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
