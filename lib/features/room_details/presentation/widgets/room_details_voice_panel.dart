import 'package:flutter/material.dart';

import '../../../../design/margaritaville_colors.dart';
import '../../application/voice/room_voice_capture_state.dart';
import '../../domain/models/room_media_item.dart';

final class RoomDetailsVoicePanel extends StatelessWidget {
  const RoomDetailsVoicePanel({
    required this.state,
    required this.voiceNotes,
    required this.onPressed,
    super.key,
  });

  final RoomVoiceCaptureState state;
  final List<RoomMediaItem> voiceNotes;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Opacity(
          opacity: state.acceptsTap ? 1 : 0.72,
          child: InkWell(
            key: const Key('room-details-record-voice'),
            onTap: state.acceptsTap ? onPressed : null,
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
              child: Row(
                children: [
                  Icon(
                    state.isRecording
                        ? Icons.stop_circle_rounded
                        : Icons.mic_rounded,
                    size: 34,
                    color: state.isRecording
                        ? Colors.redAccent
                        : MargaritavilleColors.accent,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.isRecording
                              ? 'Остановить запись'
                              : 'Новая голосовая заметка',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          state.statusText,
                          key: const Key('room-details-voice-status'),
                          style: const TextStyle(
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
        ),
        const SizedBox(height: 10),
        const Text(
          'Говори по-русски. Текст появится после остановки записи.',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: MargaritavilleColors.secondaryText,
          ),
        ),
        if (voiceNotes.isEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Голосовые заметки появятся здесь пузырями после записи.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: MargaritavilleColors.secondaryText.withValues(alpha: 0.70),
            ),
          ),
        ] else ...[
          const SizedBox(height: 14),
          for (final note in voiceNotes) ...[
            _VoiceBubble(note: note),
            const SizedBox(height: 9),
          ],
        ],
      ],
    );
  }
}

final class _VoiceBubble extends StatelessWidget {
  const _VoiceBubble({required this.note});

  final RoomMediaItem note;

  @override
  Widget build(BuildContext context) {
    final transcript = note.transcript?.trim();
    return Container(
      key: Key('room-details-voice-${note.id}'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: MargaritavilleColors.accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MargaritavilleColors.accent.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.graphic_eq_rounded,
            size: 26,
            color: MargaritavilleColors.accent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transcript == null || transcript.isEmpty
                      ? 'Голосовая заметка'
                      : transcript,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatVoiceTime(note.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: MargaritavilleColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatVoiceTime(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${local.hour < 12 ? 'AM' : 'PM'}';
}
