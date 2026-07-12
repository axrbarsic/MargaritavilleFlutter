import 'package:flutter/material.dart';

import '../../../interaction/domain/margaritaville_interaction_intent.dart';
import '../../../interaction/presentation/margaritaville_feedback_scope.dart';
import 'appearance_settings_panel.dart';

final class TestDataSettingsPanel extends StatefulWidget {
  const TestDataSettingsPanel({required this.onActivateAllRooms, super.key});

  final Future<void> Function() onActivateAllRooms;

  @override
  State<TestDataSettingsPanel> createState() => _TestDataSettingsPanelState();
}

final class _TestDataSettingsPanelState extends State<TestDataSettingsPanel> {
  var _isRunning = false;

  @override
  Widget build(BuildContext context) {
    return AppearanceSettingsPanel(
      title: 'Тестирование',
      subtitle:
          'Явные инструменты для проверки интерфейса на большом объёме данных.',
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.tonalIcon(
          key: const Key('settings-use-all-hotel-rooms'),
          onPressed: _isRunning
              ? null
              : () => MargaritavilleFeedbackScope.dispatcherOf(context).accept(
                  MargaritavilleInteractionIntent.tap,
                  _confirmAndActivate,
                ),
          icon: _isRunning
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.hotel_rounded),
          label: const Text('Задействовать все номера отеля для теста'),
        ),
      ),
    );
  }

  Future<void> _confirmAndActivate() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Заменить текущие назначения?'),
        content: const Text(
          'Текущие тележки будут заменены, а абсолютно все номера каталога '
          'перемешаны и распределены между уборщицами. Уже существующие '
          'статусы, VIP и расписание номеров сохранятся.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                MargaritavilleFeedbackScope.dispatcherOf(context).accept(
                  MargaritavilleInteractionIntent.deselect,
                  () => Navigator.pop(context, false),
                ),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () =>
                MargaritavilleFeedbackScope.dispatcherOf(context).accept(
                  MargaritavilleInteractionIntent.destructive,
                  () => Navigator.pop(context, true),
                ),
            child: const Text('Заменить и перемешать'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isRunning = true);
    try {
      await widget.onActivateAllRooms();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Все номера отеля назначены в случайном порядке'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось заменить назначения: $error')),
      );
    } finally {
      if (mounted) setState(() => _isRunning = false);
    }
  }
}
