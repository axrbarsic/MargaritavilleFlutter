import 'package:flutter/material.dart';

import '../../../interaction/domain/margaritaville_interaction_intent.dart';
import '../../../interaction/presentation/margaritaville_feedback_scope.dart';
import '../../../settings/presentation/widgets/appearance_settings_panel.dart';
import '../housekeeper_catalog_editor_screen.dart';

final class HousekeeperCatalogSettingsPanel extends StatelessWidget {
  const HousekeeperCatalogSettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return AppearanceSettingsPanel(
      title: 'Уборщицы',
      subtitle:
          'Имена, цвета и назначения тележек для первого экрана Margaritaville.',
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: FilledButton.icon(
          key: const Key('open-housekeeper-catalog'),
          onPressed: () =>
              MargaritavilleFeedbackScope.dispatcherOf(context).accept(
                MargaritavilleInteractionIntent.navigate,
                () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const HousekeeperCatalogEditorScreen(),
                  ),
                ),
              ),
          icon: const Icon(Icons.groups_rounded),
          label: const Text('Изменить имена и цвета'),
        ),
      ),
    );
  }
}
