import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/appearance_summary_visual_policy.dart';
import '../../../shared/edr/edr_overlay_controller.dart';
import '../../../shared/edr/edr_window_surface.dart';
import '../../cell_calibration/domain/models/room_cell_typography_profile.dart';
import '../../cell_calibration/presentation/controllers/room_cell_calibration_controller.dart';
import '../../cell_calibration/presentation/room_cell_calibration_screen.dart';
import '../../housekeeper_catalog/presentation/controllers/housekeeper_catalog_controller.dart';
import '../../interaction/domain/margaritaville_interaction_intent.dart';
import '../../interaction/presentation/margaritaville_feedback_scope.dart';
import '../../settings/domain/models/appearance_settings.dart';
import '../../settings/presentation/appearance_settings_screen.dart';
import '../../settings/presentation/controllers/appearance_settings_controller.dart';
import '../../summary/presentation/summary_screen.dart';
import '../../summary/presentation/summary_visual_policy.dart';
import '../../work_setup/presentation/work_setup_screen.dart';
import 'controllers/work_session_controller.dart';

final class WorkSessionShell extends ConsumerStatefulWidget {
  const WorkSessionShell({super.key});

  @override
  ConsumerState<WorkSessionShell> createState() => _WorkSessionShellState();
}

final class _WorkSessionShellState extends ConsumerState<WorkSessionShell> {
  late final EdrOverlayController _edrController;
  var _showCellCalibration = false;

  @override
  void initState() {
    super.initState();
    _edrController = EdrOverlayController();
  }

  @override
  void dispose() {
    _edrController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workSessionControllerProvider);
    final appearance = ref.watch(appearanceSettingsControllerProvider);
    final calibration = EdrWindowSurface.supported
        ? ref.watch(roomCellCalibrationControllerProvider)
        : null;
    final catalogById = ref.watch(housekeeperCatalogByIdProvider);
    final visualPolicy = AppearanceSummaryVisualPolicy.fromSettings(
      appearance.value ?? AppearanceSettings.defaults,
    );
    return state.when(
      data: (session) => session.workdayLocked
          ? _showCellCalibration
                ? RoomCellCalibrationScreen(
                    edrController: _edrController,
                    baseVisualPolicy: visualPolicy,
                    onClose: () => setState(() => _showCellCalibration = false),
                  )
                : SummaryScreen(
                    session: session,
                    enableSchedulePolling: true,
                    visualPolicy: visualPolicy,
                    housekeeperCatalogById: catalogById,
                    edrController: _edrController,
                    typographyProfile: _appliedProfile(
                      calibration?.value,
                      visualPolicy,
                    ),
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
                      MargaritavilleFeedbackScope.dispatcherOf(context).accept(
                        MargaritavilleInteractionIntent.retry,
                        () => ref.invalidate(workSessionControllerProvider),
                      ),
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

  RoomCellTypographyProfile _appliedProfile(
    RoomCellCalibrationState? calibration,
    SummaryVisualPolicy policy,
  ) {
    final layout = policy.gridColumns == SummaryGridColumns.three
        ? RoomCellLayoutProfile.three
        : RoomCellLayoutProfile.four;
    return calibration?.appliedFor(layout) ??
        RoomCellTypographyProfile.defaults;
  }

  Future<void> _openSettings(BuildContext context) async {
    final result = await Navigator.of(context).push<AppearanceSettingsResult>(
      MaterialPageRoute(builder: (_) => const AppearanceSettingsScreen()),
    );
    if (!mounted || result != AppearanceSettingsResult.openCellCalibration) {
      return;
    }
    setState(() => _showCellCalibration = true);
  }
}
