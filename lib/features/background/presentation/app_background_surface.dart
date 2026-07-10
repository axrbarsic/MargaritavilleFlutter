import 'package:flutter/material.dart';

import '../../settings/domain/models/app_background_mode.dart';
import 'matrix_rain_background.dart';

final class AppBackgroundSurface extends StatelessWidget {
  const AppBackgroundSurface({
    required this.mode,
    required this.matrixSpeed,
    super.key,
  });

  final AppBackgroundMode mode;
  final double matrixSpeed;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: switch (mode) {
        AppBackgroundMode.matrixRain => MatrixRainBackground(
          speed: matrixSpeed,
        ),
        _ => const ColoredBox(color: Colors.black),
      },
    );
  }
}
