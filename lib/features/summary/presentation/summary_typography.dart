import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../design/margaritaville_colors.dart';
import '../../cell_calibration/domain/models/room_cell_typography_profile.dart';

abstract final class SummaryTypography {
  static TextStyle housekeeperName(Color color) {
    return _role(
      size: 25,
      color: color,
      androidWidth: 102,
      shadows: const [
        Shadow(color: Color(0xEB000000), blurRadius: 1.6, offset: Offset(0, 1)),
      ],
    );
  }

  static TextStyle get territory =>
      _role(size: 22, color: Colors.white, androidWidth: 97);

  static TextStyle get roomNumber => _role(
    size: 44,
    color: MargaritavilleColors.roomForeground,
    androidWidth: 117,
    tabularFigures: true,
  );

  static TextStyle roomNumberAtScale(
    double scale, {
    RoomCellTypographyProfile profile = RoomCellTypographyProfile.defaults,
  }) => roomNumber.copyWith(fontSize: profile.roomNumberSize * scale);

  static TextStyle get roomTime => _role(
    size: 16,
    color: MargaritavilleColors.roomForeground,
    androidWidth: 110,
    tabularFigures: true,
  );

  static TextStyle roomTimeAtScale(
    double scale, {
    RoomCellTypographyProfile profile = RoomCellTypographyProfile.defaults,
  }) => roomTime.copyWith(fontSize: profile.roomTimeSize * scale);

  static TextStyle _role({
    required double size,
    required Color color,
    required double androidWidth,
    bool tabularFigures = false,
    List<Shadow>? shadows,
  }) {
    final apple = switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.macOS => true,
      _ => false,
    };
    return TextStyle(
      color: color,
      fontFamily: apple ? '.AppleSystemUIFontRounded' : 'MargaritavilleRounded',
      fontSize: size,
      fontWeight: FontWeight.w900,
      letterSpacing: 0,
      fontFeatures: tabularFigures
          ? const [ui.FontFeature.tabularFigures()]
          : null,
      fontVariations: apple
          ? null
          : [
              const ui.FontVariation('wght', 900),
              ui.FontVariation('wdth', androidWidth),
            ],
      shadows: shadows,
    );
  }
}
