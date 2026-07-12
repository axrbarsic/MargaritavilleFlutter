import 'package:flutter/material.dart';

import '../../../../design/margaritaville_colors.dart';
import '../../../interaction/domain/margaritaville_interaction_intent.dart';
import '../../../interaction/presentation/margaritaville_feedback_scope.dart';

final class RoomDetailsHeader extends StatelessWidget {
  const RoomDetailsHeader({required this.roomNumber, super.key});

  final String roomNumber;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          key: const Key('room-details-back'),
          onPressed: () =>
              MargaritavilleFeedbackScope.dispatcherOf(context).accept(
                MargaritavilleInteractionIntent.navigate,
                () => Navigator.pop(context),
              ),
          icon: const Icon(Icons.chevron_left_rounded, size: 24),
          color: MargaritavilleColors.secondaryText,
          style: IconButton.styleFrom(
            fixedSize: const Size(48, 48),
            backgroundColor: MargaritavilleColors.surface.withValues(
              alpha: 0.82,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          roomNumber,
          key: const Key('room-details-room-number'),
          style: const TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

final class RoomDetailsLoadError extends StatelessWidget {
  const RoomDetailsLoadError({
    required this.error,
    required this.onRetry,
    super.key,
  });

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Не удалось открыть комнату: $error'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => MargaritavilleFeedbackScope.dispatcherOf(
                context,
              ).accept(MargaritavilleInteractionIntent.retry, onRetry),
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}
