abstract final class SummaryLayoutTokens {
  static const headerHeight = 48.0;
  static const screenTopPadding = 18.0;
  static const headerContentGap = 18.0;
  static const contentHorizontalPadding = 8.0;
  static const contentBottomPadding = 28.0;
  static const sectionSpacing = 20.0;
  static const sectionPadding = 8.0;
  static const sectionHeaderGridGap = 14.0;
  static const gridSpacing = 8.0;
  static const gridColumns = 4;
  static const tileHeight = 98.0;
  static const tileCornerRadius = 16.0;
  static double tileWidthForSection(double width, {int columns = gridColumns}) {
    const horizontalInsets = sectionPadding * 2;
    final interColumnGaps = gridSpacing * (columns - 1);
    return ((width - horizontalInsets - interColumnGaps) / columns)
        .clamp(0, double.infinity)
        .toDouble();
  }
}
