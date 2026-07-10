import 'package:flutter/material.dart';

import '../domain/matrix_rain_field.dart';

final class MatrixRainSprite {
  MatrixRainSprite._({
    required this.drop,
    required this.trail,
    required this.headGlow,
  });

  factory MatrixRainSprite.fromDrop(MatrixRainDrop drop) {
    final spans = <InlineSpan>[];
    for (var index = drop.glyphs.length - 1; index >= 0; index--) {
      final brightness = index < 3 ? 0.9 : 0.4;
      final alpha = index == 0
          ? drop.opacity
          : drop.opacity * (1 - index / drop.glyphs.length) * 0.7;
      spans.add(
        TextSpan(
          text: index == 0 ? drop.glyphs[index] : '${drop.glyphs[index]}\n',
          style: _glyphStyle(
            Color.fromRGBO(
              (130 * brightness).round(),
              (255 * brightness).round(),
              (100 * brightness).round(),
              alpha.clamp(0, 1),
            ),
          ),
        ),
      );
    }
    final trail = TextPainter(
      text: TextSpan(children: spans),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: cellSize);
    final headGlow = TextPainter(
      text: TextSpan(
        text: drop.glyphs.first,
        style: _glyphStyle(
          Color.fromRGBO(128, 255, 128, (drop.opacity * 0.6).clamp(0, 1)),
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: cellSize);
    return MatrixRainSprite._(drop: drop, trail: trail, headGlow: headGlow);
  }

  static const cellSize = 24.0;

  final MatrixRainDrop drop;
  final TextPainter trail;
  final TextPainter headGlow;

  static TextStyle _glyphStyle(Color color) {
    return TextStyle(
      color: color,
      fontFamily: 'monospace',
      fontSize: 18,
      fontWeight: FontWeight.w700,
      height: 1.2,
    );
  }
}
