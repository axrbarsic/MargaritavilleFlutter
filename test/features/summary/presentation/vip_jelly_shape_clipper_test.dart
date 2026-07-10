import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/summary/presentation/widgets/vip_jelly_shape_clipper.dart';

void main() {
  test('VIP jelly contour changes deterministically with shared time', () {
    const size = Size(96, 98);
    const first = VipJellyShapeClipper(
      seconds: 10,
      speed: 0.75,
      seed: 0.42,
      cornerRadius: 16,
    );
    const same = VipJellyShapeClipper(
      seconds: 10,
      speed: 0.75,
      seed: 0.42,
      cornerRadius: 16,
    );
    const later = VipJellyShapeClipper(
      seconds: 11,
      speed: 0.75,
      seed: 0.42,
      cornerRadius: 16,
    );

    final firstMetrics = first
        .getClip(size)
        .computeMetrics()
        .map((metric) => metric.length)
        .toList();
    final sameMetrics = same
        .getClip(size)
        .computeMetrics()
        .map((metric) => metric.length)
        .toList();
    final laterMetrics = later
        .getClip(size)
        .computeMetrics()
        .map((metric) => metric.length)
        .toList();

    expect(firstMetrics, sameMetrics);
    expect(laterMetrics.single, isNot(closeTo(firstMetrics.single, 0.001)));
    expect(first.shouldReclip(same), isFalse);
    expect(later.shouldReclip(first), isTrue);
  });
}
