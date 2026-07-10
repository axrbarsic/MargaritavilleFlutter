import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../shared/visual_runtime/visual_runtime_activity.dart';
import '../../../shared/visual_runtime/visual_runtime_scope.dart';
import '../domain/matrix_rain_field.dart';
import 'matrix_rain_painter.dart';
import 'matrix_rain_sprite.dart';

final class MatrixRainBackground extends StatefulWidget {
  const MatrixRainBackground({required this.speed, this.seed, super.key});

  final double speed;
  final int? seed;

  @override
  State<MatrixRainBackground> createState() => _MatrixRainBackgroundState();
}

final class _MatrixRainBackgroundState extends State<MatrixRainBackground> {
  late final List<MatrixRainSprite> _sprites;
  DateTime? _lastFrameAt;
  var _motionTime = 0.0;

  @override
  void initState() {
    super.initState();
    final field = MatrixRainField.seeded(
      seed: widget.seed ?? DateTime.now().millisecondsSinceEpoch,
    );
    _sprites = field.drops
        .map(MatrixRainSprite.fromDrop)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final clock = VisualRuntimeScope.maybeClockOf(context);
    final surface = clock == null
        ? _paintSurface()
        : AnimatedBuilder(
            animation: clock,
            builder: (context, _) {
              _advance(clock.now);
              return _paintSurface();
            },
          );
    return VisualRuntimeActivity(
      active: true,
      child: RepaintBoundary(child: surface),
    );
  }

  Widget _paintSurface() {
    return CustomPaint(
      key: const Key('matrix-rain-canvas'),
      painter: MatrixRainPainter(motionTime: _motionTime, sprites: _sprites),
      child: const SizedBox.expand(),
    );
  }

  void _advance(DateTime now) {
    final previous = _lastFrameAt;
    _lastFrameAt = now;
    if (previous == null) return;
    final elapsed = now.difference(previous).inMicroseconds / 1000000;
    final step = math.min(math.max(elapsed, 0), 1 / 30);
    _motionTime += step * widget.speed.clamp(0.08, 3);
  }
}
