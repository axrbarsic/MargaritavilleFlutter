import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/appearance_settings.dart';
import 'controllers/appearance_settings_controller.dart';
import 'widgets/appearance_settings_controls.dart';
import 'widgets/appearance_settings_panel.dart';
import 'widgets/background_settings_panel.dart';

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
                  state.when(
                    data: (settings) => Column(
                      children: [
                        _content(ref, settings),
                        const SizedBox(height: 18),
                        BackgroundSettingsPanel(
                          settings: settings,
                          controller: ref.read(
                            appearanceSettingsControllerProvider.notifier,
                          ),
                        ),
                      ],
                    ),
                    error: (error, _) => _error(ref, error),
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
              ? () => Navigator.pop(context)
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

  Widget _content(WidgetRef ref, AppearanceSettings settings) {
    final controller = ref.read(appearanceSettingsControllerProvider.notifier);
    return AppearanceSettingsPanel(
      title: 'Экспериментальное',
      subtitle:
          'Только активные режимы, которые можно реально оценить на основном экране.',
      child: Column(
        children: [
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
          if (settings.liveCellsEnabled)
            AppearanceSettingSliderRow(
              key: const Key('setting-spring-intensity'),
              title: 'Сила пружины',
              icon: Icons.open_with_rounded,
              value: settings.cellSpringIntensity,
              minimum: 0,
              maximum: 1,
              defaultValue: 0.72,
              valueLabel: (value) => '${(value * 100).round()}%',
              onChanged: (value) =>
                  unawaited(controller.setCellSpringIntensity(value)),
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
          if (settings.vipJellyEnabled)
            AppearanceSettingSliderRow(
              key: const Key('setting-vip-jelly-speed'),
              title: 'Скорость желе',
              icon: Icons.speed_rounded,
              value: settings.vipJellySpeed,
              minimum: 0.2,
              maximum: 2.5,
              defaultValue: 0.75,
              valueLabel: (value) => '${value.toStringAsFixed(2)}x',
              onChanged: (value) =>
                  unawaited(controller.setVipJellySpeed(value)),
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
              onPressed: () => unawaited(controller.resetVisualEffects()),
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text('Сбросить эффекты'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _error(WidgetRef ref, Object error) {
    return AppearanceSettingsPanel(
      title: 'Не удалось открыть настройки',
      subtitle: '$error',
      child: FilledButton.icon(
        onPressed: () => ref.invalidate(appearanceSettingsControllerProvider),
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Повторить'),
      ),
    );
  }
}
