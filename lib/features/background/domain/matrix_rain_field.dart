final class MatrixRainField {
  const MatrixRainField(this.drops);

  factory MatrixRainField.seeded({required int seed, int dropCount = 80}) {
    final random = _MatrixRandom(seed);
    return MatrixRainField([
      for (var index = 0; index < dropCount; index++)
        MatrixRainDrop(
          x: random.nextDouble(),
          startY: -2 * random.nextDouble(),
          velocity: 0.3 + random.nextDouble() * 1.2,
          opacity: 0.28 + random.nextDouble() * 0.58,
          glyphs: [
            for (
              var glyphIndex = 0;
              glyphIndex < 8 + random.nextInt(25);
              glyphIndex++
            )
              _glyphs[random.nextInt(_glyphs.length)],
          ],
        ),
    ]);
  }

  final List<MatrixRainDrop> drops;

  @override
  bool operator ==(Object other) {
    if (other is! MatrixRainField || other.drops.length != drops.length) {
      return false;
    }
    for (var index = 0; index < drops.length; index++) {
      if (other.drops[index] != drops[index]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(drops);
}

final class MatrixRainDrop {
  const MatrixRainDrop({
    required this.x,
    required this.startY,
    required this.velocity,
    required this.opacity,
    required this.glyphs,
  });

  final double x;
  final double startY;
  final double velocity;
  final double opacity;
  final List<String> glyphs;

  @override
  bool operator ==(Object other) {
    return other is MatrixRainDrop &&
        other.x == x &&
        other.startY == startY &&
        other.velocity == velocity &&
        other.opacity == opacity &&
        other.glyphs.join() == glyphs.join();
  }

  @override
  int get hashCode => Object.hash(x, startY, velocity, opacity, glyphs.join());
}

final class _MatrixRandom {
  _MatrixRandom(int seed) : _state = seed & 0xFFFFFFFF;

  var _state = 0;

  double nextDouble() {
    _state = (1664525 * _state + 1013904223) & 0xFFFFFFFF;
    return _state / 0x100000000;
  }

  int nextInt(int upperBound) => (nextDouble() * upperBound).floor();
}

final _glyphs =
    ('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
            'ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃ'
            '日田大木本山川空海風火水金土月星')
        .split('');
