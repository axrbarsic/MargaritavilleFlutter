import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../interaction/domain/margaritaville_interaction_intent.dart';
import '../../../interaction/domain/margaritaville_sound_routing.dart';
import '../../../interaction/presentation/controllers/interaction_sound_settings_controller.dart';
import '../../../interaction/presentation/margaritaville_feedback_scope.dart';
import 'appearance_settings_panel.dart';

final class InteractionSoundSettingsPanel extends ConsumerWidget {
  const InteractionSoundSettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(interactionSoundSettingsControllerProvider);
    return AppearanceSettingsPanel(
      title: 'Звуки',
      subtitle:
          'Три назначения: общий интерфейс, ячейка и финальная зелёная ячейка.',
      child: state.when(
        data: (assignments) => Column(
          children: [
            for (final slot in MargaritavilleSoundSlot.values)
              _SoundAssignmentRow(
                slot: slot,
                asset: assignments.assetForSlot(slot),
                onSelected: (asset) {
                  MargaritavilleFeedbackScope.dispatcherOf(context).accept(
                    MargaritavilleInteractionIntent.select,
                    () => unawaited(
                      ref
                          .read(
                            interactionSoundSettingsControllerProvider.notifier,
                          )
                          .setAsset(slot, asset),
                    ),
                  );
                  MargaritavilleFeedbackScope.dispatcherOf(
                    context,
                  ).previewSound(asset);
                },
                onPreview: () {
                  final interactions = MargaritavilleFeedbackScope.dispatcherOf(
                    context,
                  );
                  interactions.accept(
                    MargaritavilleInteractionIntent.tap,
                    () => interactions.previewSound(
                      assignments.assetForSlot(slot),
                    ),
                  );
                },
              ),
          ],
        ),
        error: (error, _) => Row(
          children: [
            Expanded(child: Text('Не удалось загрузить звуки: $error')),
            IconButton(
              tooltip: 'Повторить',
              onPressed: () =>
                  MargaritavilleFeedbackScope.dispatcherOf(context).accept(
                    MargaritavilleInteractionIntent.retry,
                    () => ref.invalidate(
                      interactionSoundSettingsControllerProvider,
                    ),
                  ),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

final class _SoundAssignmentRow extends StatelessWidget {
  const _SoundAssignmentRow({
    required this.slot,
    required this.asset,
    required this.onSelected,
    required this.onPreview,
  });

  final MargaritavilleSoundSlot slot;
  final MargaritavilleSoundAsset asset;
  final ValueChanged<MargaritavilleSoundAsset> onSelected;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: PopupMenuButton<MargaritavilleSoundAsset>(
              key: Key('sound-picker-${slot.id}'),
              initialValue: asset,
              onSelected: onSelected,
              itemBuilder: (context) => [
                for (final candidate in MargaritavilleSoundAsset.values)
                  PopupMenuItem(
                    value: candidate,
                    child: Row(
                      children: [
                        Icon(
                          candidate == asset
                              ? Icons.check_rounded
                              : Icons.volume_up_rounded,
                          size: 19,
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(candidate.title)),
                      ],
                    ),
                  ),
              ],
              child: _SoundAssignmentInfo(slot: slot, asset: asset),
            ),
          ),
          const SizedBox(width: 10),
          IconButton.filledTonal(
            key: Key('sound-preview-${slot.id}'),
            tooltip: 'Прослушать ${asset.title}',
            onPressed: asset == MargaritavilleSoundAsset.none
                ? null
                : onPreview,
            constraints: const BoxConstraints.tightFor(width: 44, height: 44),
            icon: const Icon(Icons.play_arrow_rounded, size: 24),
          ),
        ],
      ),
    );
  }
}

final class _SoundAssignmentInfo extends StatelessWidget {
  const _SoundAssignmentInfo({required this.slot, required this.asset});

  final MargaritavilleSoundSlot slot;
  final MargaritavilleSoundAsset asset;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 3),
          child: Icon(
            Icons.volume_up_rounded,
            color: Color(0xFF7BFFA4),
            size: 23,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                slot.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                asset.title,
                style: const TextStyle(
                  color: Color(0xFF8DFFA8),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                slot.subtitle,
                style: const TextStyle(
                  color: Color(0xFFB8C9BD),
                  fontSize: 12,
                  height: 1.22,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.arrow_drop_down_rounded),
      ],
    );
  }
}
