import 'package:flutter/material.dart';

import '../design/margaritaville_colors.dart';

abstract final class MargaritavilleTheme {
  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: MargaritavilleColors.accent,
      brightness: Brightness.dark,
      surface: MargaritavilleColors.surface,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: MargaritavilleColors.background,
      fontFamily: 'MargaritavilleRounded',
      fontFamilyFallback: const ['Roboto', 'sans-serif'],
      appBarTheme: const AppBarTheme(
        backgroundColor: MargaritavilleColors.background,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(letterSpacing: -0.4),
        titleLarge: TextStyle(letterSpacing: -0.2),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
