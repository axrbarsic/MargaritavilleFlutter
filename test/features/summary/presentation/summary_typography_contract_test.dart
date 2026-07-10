import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/summary/presentation/summary_typography.dart';

void main() {
  test('iOS roles use the exact SwiftUI rounded-black contract', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    final styles = <TextStyle>[
      SummaryTypography.housekeeperName(Colors.purple),
      SummaryTypography.territory,
      SummaryTypography.roomNumber,
      SummaryTypography.roomTime,
    ];

    expect(styles.map((style) => style.fontSize), [25, 22, 44, 16]);
    expect(
      styles.map((style) => style.fontFamily),
      everyElement('.AppleSystemUIFontRounded'),
    );
    expect(
      styles.map((style) => style.fontWeight),
      everyElement(FontWeight.w900),
    );
    expect(styles.map((style) => style.letterSpacing), everyElement(0));
    expect(styles.map((style) => style.height), everyElement(isNull));
    expect(SummaryTypography.roomNumber.fontFeatures, const [
      ui.FontFeature.tabularFigures(),
    ]);
    expect(SummaryTypography.roomTime.fontFeatures, const [
      ui.FontFeature.tabularFigures(),
    ]);

    // flutter_test intentionally substitutes the Ahem test font, so real Apple
    // glyph widths are verified from physical-device screenshots, not here.
  });

  test('Android fallback locks the measured Nunito variable axes', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    expect(
      SummaryTypography.housekeeperName(Colors.purple).fontVariations,
      const [ui.FontVariation('wght', 900), ui.FontVariation('wdth', 102)],
    );
    expect(SummaryTypography.territory.fontVariations, const [
      ui.FontVariation('wght', 900),
      ui.FontVariation('wdth', 97),
    ]);
    expect(SummaryTypography.roomNumber.fontVariations, const [
      ui.FontVariation('wght', 900),
      ui.FontVariation('wdth', 117),
    ]);
    expect(SummaryTypography.roomTime.fontVariations, const [
      ui.FontVariation('wght', 900),
      ui.FontVariation('wdth', 110),
    ]);
  });
}
