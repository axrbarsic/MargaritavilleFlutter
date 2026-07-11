import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/summary/presentation/summary_tile_geometry.dart';
import 'package:margaritaville_flutter/features/summary/presentation/summary_visual_policy.dart';

void main() {
  test('Android four and three columns share the exact square-row height', () {
    final four = SummaryTileGeometryResolver.resolve(
      sectionWidth: 329.6,
      columns: SummaryGridColumns.four,
      platform: TargetPlatform.android,
    );
    final three = SummaryTileGeometryResolver.resolve(
      sectionWidth: 329.6,
      columns: SummaryGridColumns.three,
      platform: TargetPlatform.android,
    );

    expect(four.size.width, closeTo(72.4, 0.001));
    expect(four.size.height, closeTo(72.4, 0.001));
    expect(three.size.width, closeTo(99.2, 0.001));
    expect(three.size.height, closeTo(72.4, 0.001));
    expect(three.size.height, four.size.height);
  });

  test('iOS restores donor four-column height and compacts only three', () {
    final four = SummaryTileGeometryResolver.resolve(
      sectionWidth: 424,
      columns: SummaryGridColumns.four,
      platform: TargetPlatform.iOS,
    );
    final three = SummaryTileGeometryResolver.resolve(
      sectionWidth: 424,
      columns: SummaryGridColumns.three,
      platform: TargetPlatform.iOS,
    );

    expect(four.size, const Size(96, 98));
    expect(three.size.width, closeTo(130.6666667, 0.001));
    expect(three.size.height, 73.5);
    expect(four.contentScale, 1);
    expect(three.contentScale, 0.75);
    expect(four.fontScale, 1);
    expect(three.fontScale, 1);
    expect(four.compressTextVertically, isFalse);
    expect(three.compressTextVertically, isTrue);
  });

  test('an unusably narrow section returns a safe empty geometry', () {
    final geometry = SummaryTileGeometryResolver.resolve(
      sectionWidth: 40,
      columns: SummaryGridColumns.four,
      platform: TargetPlatform.android,
    );

    expect(geometry.size, Size.zero);
    expect(geometry.contentScale, 1);
    expect(geometry.fontScale, 1);
  });
}
