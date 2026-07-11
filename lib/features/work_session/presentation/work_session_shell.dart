import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/appearance_summary_visual_policy.dart';
import '../../housekeeper_catalog/presentation/controllers/housekeeper_catalog_controller.dart';
import '../../settings/domain/models/appearance_settings.dart';
import '../../settings/presentation/appearance_settings_screen.dart';
import '../../settings/presentation/controllers/appearance_settings_controller.dart';
import '../../summary/presentation/summary_screen.dart';
import '../../work_setup/presentation/work_setup_screen.dart';
import 'controllers/work_session_controller.dart';

final class WorkSessionShell extends ConsumerWidget {
  const WorkSessionShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workSessionControllerProvider);
    final appearance = ref.watch(appearanceSettingsControllerProvider);
    final catalogById = ref.watch(housekeeperCatalogByIdProvider);
    final visualPolicy = AppearanceSummaryVisualPolicy.fromSettings(
      appearance.value ?? AppearanceSettings.defaults,
    );
    return state.when(
      data: (session) => session.workdayLocked
          ? SummaryScreen(
              session: session,
              enableSchedulePolling: true,
              visualPolicy: visualPolicy,
              housekeeperCatalogById: catalogById,
              onOpenSettings: () => _openSettings(context),
            )
          : WorkSetupScreen(session: session),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Margaritaville')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.storage_rounded, size: 44),
                const SizedBox(height: 16),
                const Text(
                  'Не удалось открыть локальную смену',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () =>
                      ref.invalidate(workSessionControllerProvider),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Повторить'),
                ),
              ],
            ),
          ),
        ),
      ),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }

  Future<void> _openSettings(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AppearanceSettingsScreen()),
    );
  }
}
