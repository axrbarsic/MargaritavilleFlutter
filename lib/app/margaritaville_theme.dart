import 'package:flutter/material.dart';

abstract final class MargaritavilleTheme {
  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF27C4A6),
      brightness: Brightness.dark,
      surface: const Color(0xFF07140F),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF07140F),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF07140F),
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
