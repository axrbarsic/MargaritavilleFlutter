import 'dart:math' as math;

import 'package:flutter/material.dart';

final class RoomStatusLightPainter extends CustomPainter {
  const RoomStatusLightPainter({
    required this.color,
    required this.intensity,
    required this.seed,
    required this.cornerRadius,
    this.fullFill = false,
  });

  final Color color;
  final double intensity;
  final double seed;
  final double cornerRadius;
  final bool fullFill;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || intensity <= 0) return;
    final rect = Offset.zero & size;
    final shape = RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius));
    canvas
      ..save()
      ..clipRRect(shape);

    if (fullFill) {
      canvas.drawRect(
        rect,
        Paint()
          ..blendMode = BlendMode.plus
          ..color = color.withValues(alpha: intensity.clamp(0, 1)),
      );
    }

    final centerX = 0.30 + 0.08 * math.sin(seed * math.pi * 2);
    final gradient = RadialGradient(
      center: Alignment(centerX * 2 - 1, -0.56),
      radius: 0.90,
      colors: [
        color.withValues(alpha: 0.34 * intensity),
        color.withValues(alpha: 0.10 * intensity),
        Colors.transparent,
      ],
      stops: const [0, 0.46, 1],
    );
    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = gradient.createShader(rect),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(RoomStatusLightPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.intensity != intensity ||
        oldDelegate.seed != seed ||
        oldDelegate.cornerRadius != cornerRadius ||
        oldDelegate.fullFill != fullFill;
  }
}
