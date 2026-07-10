import 'package:flutter/material.dart';

import 'matrix_rain_sprite.dart';

final class MatrixRainPainter extends CustomPainter {
  const MatrixRainPainter({required this.motionTime, required this.sprites});

  static const backgroundColor = Color(0xFF020804);

  final double motionTime;
  final List<MatrixRainSprite> sprites;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..drawColor(backgroundColor, BlendMode.src)
      ..save()
      ..clipRect(Offset.zero & size);
    for (final sprite in sprites) {
      final drop = sprite.drop;
      final traveledY = drop.startY + drop.velocity * 0.5 * motionTime;
      final normalizedY = traveledY <= 1.3
          ? traveledY
          : -0.3 + (traveledY - 1.3) % 1.6;
      final headY = normalizedY * size.height;
      final x = drop.x * size.width - MatrixRainSprite.cellSize / 2;
      final trailTop = headY - sprite.trail.height + MatrixRainSprite.cellSize;
      if (trailTop > size.height || headY < -MatrixRainSprite.cellSize) {
        continue;
      }
      for (final offset in const [
        Offset(1, 0),
        Offset(-1, 0),
        Offset(0, 1),
        Offset(0, -1),
      ]) {
        sprite.headGlow.paint(canvas, Offset(x + offset.dx, headY + offset.dy));
      }
      sprite.trail.paint(canvas, Offset(x, trailTop));
    }
    canvas.restore();

    final radius = size.width * 0.82;
    final vignetteBounds = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: radius,
    );
    final vignette = const RadialGradient(
      colors: [Colors.transparent, Color(0xBD020804)],
    ).createShader(vignetteBounds);
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = vignette
        ..blendMode = BlendMode.srcOver,
    );
  }

  @override
  bool shouldRepaint(MatrixRainPainter oldDelegate) {
    return oldDelegate.motionTime != motionTime ||
        !identical(oldDelegate.sprites, sprites);
  }
}
