import 'dart:async';

import 'package:flutter/material.dart';

import '../../../interaction/domain/margaritaville_interaction_intent.dart';
import '../../../interaction/presentation/margaritaville_feedback_scope.dart';
import '../../domain/models/app_background_mode.dart';
import '../../domain/models/appearance_settings.dart';
import '../controllers/appearance_settings_controller.dart';
import 'appearance_settings_controls.dart';
import 'appearance_settings_panel.dart';

final class BackgroundSettingsPanel extends StatelessWidget {
  const BackgroundSettingsPanel({
    required this.settings,
    required this.controller,
    super.key,
  });

  final AppearanceSettings settings;
  final AppearanceSettingsController controller;

  @override
  Widget build(BuildContext context) {
    final selected = settings.backgroundMode == AppBackgroundMode.matrixRain
        ? AppBackgroundMode.matrixRain
        : AppBackgroundMode.off;
    return AppearanceSettingsPanel(
      title: 'Фон приложения',
      subtitle: 'Matrix Rain как единая живая заставка под всеми экранами.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<AppBackgroundMode>(
            key: const Key('setting-background-mode'),
            segments: const [
              ButtonSegment(
                value: AppBackgroundMode.off,
                label: Text('Выкл'),
                icon: Icon(Icons.dark_mode_rounded),
              ),
              ButtonSegment(
                value: AppBackgroundMode.matrixRain,
                label: Text('Matrix'),
                icon: Icon(Icons.grid_on_rounded),
              ),
            ],
            selected: {selected},
            onSelectionChanged: (selection) =>
                MargaritavilleFeedbackScope.dispatcherOf(context).accept(
                  MargaritavilleInteractionIntent.select,
                  () =>
                      unawaited(controller.setBackgroundMode(selection.single)),
                ),
          ),
          const SizedBox(height: 12),
          Text(
            selected.description,
            style: const TextStyle(
              color: Color(0xFF8DFFA8),
              fontWeight: FontWeight.w900,
            ),
          ),
          if (selected == AppBackgroundMode.matrixRain) ...[
            const SizedBox(height: 10),
            AppearanceSettingSliderRow(
              key: const Key('setting-matrix-speed'),
              title: 'Скорость',
              icon: Icons.speed_rounded,
              value: settings.matrixSpeed,
              minimum: 0.08,
              maximum: 3,
              defaultValue: 1,
              valueLabel: (value) => '${value.toStringAsFixed(2)}x',
              onChanged: (value) => unawaited(controller.setMatrixSpeed(value)),
            ),
          ],
          const SizedBox(height: 4),
          const Text(
            'TV и локальное видео появятся только вместе с рабочими renderer/adapters.',
            style: TextStyle(color: Color(0xFF8A9A8F), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
