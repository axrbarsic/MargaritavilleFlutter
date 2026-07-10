import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/background/domain/matrix_rain_field.dart';

void main() {
  test('preallocates a deterministic donor-shaped Matrix field', () {
    final first = MatrixRainField.seeded(seed: 42);
    final second = MatrixRainField.seeded(seed: 42);

    expect(first.drops.length, 80);
    expect(first, second);
    expect(first.drops.every((drop) => drop.x >= 0 && drop.x < 1), isTrue);
    expect(
      first.drops.every(
        (drop) =>
            drop.velocity >= 0.3 &&
            drop.velocity <= 1.5 &&
            drop.opacity >= 0.28 &&
            drop.opacity <= 0.86 &&
            drop.glyphs.length >= 8 &&
            drop.glyphs.length <= 32,
      ),
      isTrue,
    );
  });
}
