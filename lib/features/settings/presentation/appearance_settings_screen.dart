import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../housekeeper_catalog/presentation/widgets/housekeeper_catalog_settings_panel.dart';
import '../../interaction/domain/margaritaville_interaction_intent.dart';
import '../../interaction/presentation/margaritaville_feedback_scope.dart';
import '../../work_session/presentation/controllers/work_session_controller.dart';
import '../domain/models/appearance_settings.dart';
import '../domain/models/summary_grid_preference.dart';
import 'controllers/appearance_settings_controller.dart';
import 'widgets/appearance_settings_controls.dart';
import 'widgets/appearance_settings_panel.dart';
import 'widgets/background_settings_panel.dart';
import 'widgets/interaction_sound_settings_panel.dart';
import 'widgets/test_data_settings_panel.dart';

final class AppearanceSettingsScreen extends ConsumerWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appearanceSettingsControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
              sliver: SliverList.list(
                children: [
                  _header(context),
                  const SizedBox(height: 18),
                  const HousekeeperCatalogSettingsPanel(),
                  const SizedBox(height: 18),
                  state.when(
                    data: (settings) => Column(
                      children: [
                        _content(context, ref, settings),
                        const SizedBox(height: 18),
                        BackgroundSettingsPanel(
                          settings: settings,
                          controller: ref.read(
                            appearanceSettingsControllerProvider.notifier,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const InteractionSoundSettingsPanel(),
                        const SizedBox(height: 18),
                        TestDataSettingsPanel(
                          onActivateAllRooms: () async {
                            await ref
                                .read(workSessionControllerProvider.notifier)
                                .activateAllRoomsForTesting();
                          },
                        ),
                      ],
                    ),
                    error: (error, _) => _error(context, ref, error),
                    loading: () => const Padding(
                      padding: EdgeInsets.all(48),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      key: const Key('appearance-settings-header'),
      children: [
        IconButton.filledTonal(
          key: const Key('appearance-settings-back'),
          onPressed: Navigator.of(context).canPop()
              ? () => MargaritavilleFeedbackScope.dispatcherOf(context).accept(
                  MargaritavilleInteractionIntent.navigate,
                  () => Navigator.pop(context),
                )
              : null,
          iconSize: 24,
          constraints: const BoxConstraints.tightFor(width: 48, height: 48),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'Настройки',
              maxLines: 1,
              style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }

  Widget _content(
    BuildContext context,
    WidgetRef ref,
    AppearanceSettings settings,
  ) {
    final controller = ref.read(appearanceSettingsControllerProvider.notifier);
    return AppearanceSettingsPanel(
      title: 'Экспериментальное',
      subtitle:
          'Только активные режимы, которые можно реально оценить на основном экране.',
      child: Column(
        children: [
          AppearanceSettingSegmentedRow<SummaryGridPreference>(
            key: const Key('setting-summary-grid-columns'),
            title: 'Ячеек в ряд',
            subtitle:
                '4 — точная donor-сетка; 3 — более широкие ячейки той же высоты.',
            icon: Icons.grid_view_rounded,
            segments: const [
              ButtonSegment(
                value: SummaryGridPreference.four,
                label: Text('4'),
              ),
              ButtonSegment(
                value: SummaryGridPreference.three,
                label: Text('3'),
              ),
            ],
            value: settings.summaryGridPreference,
            onChanged: (value) =>
                unawaited(controller.setSummaryGridPreference(value)),
          ),
          const Divider(height: 18),
          AppearanceSettingToggleRow(
            key: const Key('setting-live-cells'),
            title: 'Живые ячейки',
            subtitle:
                'Пружинящий отклик ячеек на изменения статуса, задач и VIP.',
            icon: Icons.graphic_eq_rounded,
            value: settings.liveCellsEnabled,
            onChanged: (value) =>
                unawaited(controller.setLiveCellsEnabled(value)),
          ),
          const Divider(height: 18),
          AppearanceSettingToggleRow(
            key: const Key('setting-vip-jelly'),
            title: 'VIP-желе',
            subtitle:
                'Живая форма VIP-ячейки: двигается сам контур, а не внутренняя линия.',
            icon: Icons.water_rounded,
            value: settings.vipJellyEnabled,
            onChanged: (value) =>
                unawaited(controller.setVipJellyEnabled(value)),
          ),
          const Divider(height: 18),
          AppearanceSettingToggleRow(
            key: const Key('setting-vip-hdr-light'),
            title: 'VIP HDR-свет',
            subtitle:
                'VIP-ячейка просит EDR/HDR headroom и светится отдельно от общей яркости интерфейса.',
            icon: Icons.wb_sunny_rounded,
            value: settings.vipHdrLightEnabled,
            onChanged: (value) =>
                unawaited(controller.setVipHdrLightEnabled(value)),
          ),
          AppearanceSettingToggleRow(
            key: const Key('setting-status-hdr-pulse'),
            title: 'HDR-всплеск статуса',
            subtitle:
                'После смены статуса ячейка разгорается и две секунды плавно остывает из максимальной HDR-яркости нового цвета.',
            icon: Icons.bolt_rounded,
            value: settings.statusHdrPulseEnabled,
            onChanged: (value) =>
                unawaited(controller.setStatusHdrPulseEnabled(value)),
          ),
          AppearanceSettingToggleRow(
            key: const Key('setting-vivid-status-palette'),
            title: 'Сочная палитра',
            subtitle:
                'Фиксирует яркие цвета ячеек как на текущем скриншоте Swift-донора.',
            icon: Icons.palette_rounded,
            value: settings.vividStatusPaletteEnabled,
            onChanged: (value) =>
                unawaited(controller.setVividStatusPaletteEnabled(value)),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: const Key('appearance-settings-reset'),
              onPressed: () =>
                  MargaritavilleFeedbackScope.dispatcherOf(context).accept(
                    MargaritavilleInteractionIntent.destructive,
                    () => unawaited(controller.resetVisualEffects()),
                  ),
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text('Сбросить эффекты'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _error(BuildContext context, WidgetRef ref, Object error) {
    return AppearanceSettingsPanel(
      title: 'Не удалось открыть настройки',
      subtitle: '$error',
      child: FilledButton.icon(
        onPressed: () =>
            MargaritavilleFeedbackScope.dispatcherOf(context).accept(
              MargaritavilleInteractionIntent.retry,
              () => ref.invalidate(appearanceSettingsControllerProvider),
            ),
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Повторить'),
      ),
    );
  }
}
