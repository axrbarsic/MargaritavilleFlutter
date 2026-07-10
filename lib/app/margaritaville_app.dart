import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/background/presentation/app_background_surface.dart';
import '../features/settings/domain/models/appearance_settings.dart';
import '../features/settings/presentation/controllers/appearance_settings_controller.dart';
import '../features/work_session/presentation/work_session_shell.dart';
import '../shared/visual_runtime/visual_frame_clock.dart';
import '../shared/visual_runtime/visual_runtime_scope.dart';
import 'margaritaville_theme.dart';

final class MargaritavilleApp extends ConsumerWidget {
  const MargaritavilleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appearanceSettingsControllerProvider).value;
    final backgroundSettings = settings ?? AppearanceSettings.defaults;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Margaritaville',
      theme: MargaritavilleTheme.dark,
      builder: (context, child) => VisualRuntimeScope(
        policy: const VisualFramePolicy(maxFramesPerSecond: 30),
        enabled: true,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppBackgroundSurface(
              mode: backgroundSettings.backgroundMode,
              matrixSpeed: backgroundSettings.matrixSpeed,
            ),
            child!,
          ],
        ),
      ),
      home: const WorkSessionShell(),
    );
  }
}
