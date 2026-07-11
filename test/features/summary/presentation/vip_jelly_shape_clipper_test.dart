import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/summary/presentation/widgets/vip_jelly_shape_clipper.dart';

void main() {
  for (final size in const [
    Size(72.4, 72.4),
    Size(99.2, 72.4),
    Size(96, 98),
    Size(130.6666667, 73.5),
  ]) {
    test('VIP jelly contour is deterministic inside $size', () {
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

      final firstPath = first.getClip(size);
      final firstMetrics = firstPath
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
      expect(firstMetrics, hasLength(1));
      expect(firstMetrics.single, greaterThan(0));
      expect(firstPath.contains(size.center(Offset.zero)), isTrue);
      expect(laterMetrics.single, isNot(closeTo(firstMetrics.single, 0.001)));
      expect(first.shouldReclip(same), isFalse);
      expect(later.shouldReclip(first), isTrue);
    });
  }
}
