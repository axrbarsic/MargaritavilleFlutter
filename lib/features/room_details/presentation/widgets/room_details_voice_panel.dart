import 'package:flutter/material.dart';

import '../../../../design/margaritaville_colors.dart';

final class RoomDetailsVoicePanel extends StatelessWidget {
  const RoomDetailsVoicePanel({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          key: const Key('room-details-record-voice'),
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: MargaritavilleColors.accent.withValues(alpha: 0.28),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.mic_rounded,
                  size: 34,
                  color: MargaritavilleColors.accent,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Новая голосовая заметка',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Готово к записи',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: MargaritavilleColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Голосовые заметки появятся здесь пузырями после записи.',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: MargaritavilleColors.secondaryText.withValues(alpha: 0.70),
          ),
        ),
      ],
    );
  }
}
