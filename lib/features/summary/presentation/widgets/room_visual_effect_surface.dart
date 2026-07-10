import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../shared/visual_runtime/visual_runtime_scope.dart';
import '../../../work_session/domain/models/room_state.dart';
import '../summary_layout_tokens.dart';
import '../summary_visual_policy.dart';
import '../summary_visual_pulse.dart';

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
        (pulseEvent != null && policy.statusPulseEnabled);
    if (!shouldAnimate || clock == null) {
      return _frame(now: DateTime.now(), seconds: 0);
    }
    return AnimatedBuilder(
      animation: clock,
      builder: (context, _) {
        return _frame(now: clock.now, seconds: clock.seconds);
      },
    );
  }

  Widget _frame({required DateTime now, required double seconds}) {
    final vipActive = room.isVip && policy.vipJellyEnabled;
    final pulseHeat = policy.statusPulseEnabled ? _pulseHeat(now) : 0.0;
    final seed = _stableSeed(room.roomNumber);
    final speed = policy.vipJellySpeed.clamp(0.2, 2.5).toDouble();
    final time = seconds * speed + seed * 11;
    final jellyScaleX = vipActive ? 1 + 0.012 * math.sin(time * 1.7) : 1.0;
    final jellyScaleY = vipActive ? 1 + 0.018 * math.cos(time * 1.4) : 1.0;
    final jellyOffsetX = vipActive ? 1.2 * math.sin(time * 1.1) : 0.0;
    final jellyOffsetY = vipActive ? 0.8 * math.cos(time * 1.3) : 0.0;
    final pulseRubber =
        pulseHeat * SummaryStatusPulseTiming.rubberAmplitudeMultiplier;
    final pulseScale = 1 + 0.10 * policy.springIntensity * pulseRubber;
    final pulseOffsetY = -7.5 * policy.springIntensity * pulseRubber;
    final brightColor = Color.lerp(baseColor, Colors.white, 0.48)!;
    final vipGlow = vipActive && policy.sdrGlowEnabled
        ? 0.30 + 0.08 * math.sin(time * 1.25)
        : 0.0;
    final pulseGlow = policy.sdrGlowEnabled ? pulseHeat * 0.58 : 0.0;
    final glow = math.max(vipGlow, pulseGlow).clamp(0.0, 0.72).toDouble();

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
            child: Stack(
              children: [
                child,
                if (pulseHeat > 0)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: brightColor.withValues(
                            alpha: (pulseHeat * 0.50).clamp(0, 0.50).toDouble(),
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(
                              alpha: pulseHeat * 0.45,
                            ),
                          ),
                          borderRadius: BorderRadius.circular(
                            SummaryLayoutTokens.tileCornerRadius,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
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
