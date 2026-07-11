import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'summary_layout_tokens.dart';
import 'summary_visual_policy.dart';

@immutable
final class SummaryTileGeometry {
  const SummaryTileGeometry({
    required this.size,
    required this.contentScale,
    required this.fontScale,
    required this.compressTextVertically,
  });

  final Size size;
  final double contentScale;
  final double fontScale;
  final bool compressTextVertically;
}

abstract final class SummaryTileGeometryResolver {
  static SummaryTileGeometry resolve({
    required double sectionWidth,
    required SummaryGridColumns columns,
    required TargetPlatform platform,
  }) {
    final width = SummaryLayoutTokens.tileWidthForSection(
      sectionWidth,
      columns: columns.count,
    );
    final height = switch (platform) {
      TargetPlatform.android => SummaryLayoutTokens.tileWidthForSection(
        sectionWidth,
      ),
      TargetPlatform.iOS when columns == SummaryGridColumns.three =>
        SummaryLayoutTokens.donorTileHeight *
            SummaryLayoutTokens.iosHeightScale,
      TargetPlatform.iOS => SummaryLayoutTokens.donorTileHeight,
      _ => SummaryLayoutTokens.donorTileHeight,
    };
    if (width <= 0 || height <= 0) {
      return const SummaryTileGeometry(
        size: Size.zero,
        contentScale: 1,
        fontScale: 1,
        compressTextVertically: false,
      );
    }
    final contentScale = math
        .min(1.0, height / SummaryLayoutTokens.donorTileHeight)
        .toDouble();
    return SummaryTileGeometry(
      size: Size(width, height),
      contentScale: contentScale,
      fontScale: platform == TargetPlatform.iOS ? 1.0 : contentScale,
      compressTextVertically:
          platform == TargetPlatform.iOS && columns == SummaryGridColumns.three,
    );
  }
}
