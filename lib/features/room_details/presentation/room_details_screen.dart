import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/margaritaville_colors.dart';
import '../domain/models/room_media_item.dart';
import 'controllers/room_details_controller.dart';
import 'controllers/room_voice_capture_controller.dart';
import 'widgets/room_details_media_section.dart';
import 'widgets/room_details_voice_panel.dart';

final class RoomDetailsScreen extends ConsumerWidget {
  const RoomDetailsScreen({
    required this.sessionId,
    required this.roomNumber,
    super.key,
  });

  final String sessionId;
  final String roomNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = (sessionId: sessionId, roomNumber: roomNumber);
    final details = ref.watch(roomDetailsControllerProvider(request));
    final voice = ref.watch(roomVoiceCaptureControllerProvider(request));
    return Scaffold(
      key: const Key('room-details-screen'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(roomNumber: roomNumber),
              const SizedBox(height: 18),
              DecoratedBox(
                key: const Key('room-details-card'),
                decoration: BoxDecoration(
                  color: MargaritavilleColors.surface.withValues(alpha: 0.84),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: MargaritavilleColors.accent.withValues(alpha: 0.22),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: details.when(
                    data: (snapshot) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Голос/медиа',
                          key: Key('room-details-title'),
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        if (snapshot.updatedAt case final updatedAt?) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Обновлено: ${_formatUpdatedAt(updatedAt)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: MargaritavilleColors.secondaryText,
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        RoomDetailsVoicePanel(
                          state: voice,
                          voiceNotes: snapshot.media
                              .where((item) => item.kind == RoomMediaKind.voice)
                              .toList(growable: false),
                          onPressed: () => ref
                              .read(
                                roomVoiceCaptureControllerProvider(
                                  request,
                                ).notifier,
                              )
                              .toggle(),
                        ),
                        const SizedBox(height: 18),
                        Divider(
                          color: MargaritavilleColors.accent.withValues(
                            alpha: 0.18,
                          ),
                        ),
                        const SizedBox(height: 18),
                        RoomDetailsMediaSection(
                          media: snapshot.media,
                          onPhoto: () => _showNativeServiceNotice(context),
                          onVideo: () => _showNativeServiceNotice(context),
                        ),
                      ],
                    ),
                    loading: () => const SizedBox(
                      height: 240,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, _) => _LoadError(
                      error: error,
                      onRetry: () => ref
                          .read(roomDetailsControllerProvider(request).notifier)
                          .reload(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatUpdatedAt(DateTime value) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final local = value.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final suffix = local.hour < 12 ? 'AM' : 'PM';
    return '${months[local.month - 1]} ${local.day}, $hour:$minute $suffix';
  }

  static void _showNativeServiceNotice(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Камера, запись и русская расшифровка подключаются следующим нативным checkpoint.',
          ),
        ),
      );
  }
}

final class _Header extends StatelessWidget {
  const _Header({required this.roomNumber});

  final String roomNumber;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          key: const Key('room-details-back'),
          onPressed: () => Navigator.pop(context),
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

final class _LoadError extends StatelessWidget {
  const _LoadError({required this.error, required this.onRetry});

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
            FilledButton(onPressed: onRetry, child: const Text('Повторить')),
          ],
        ),
      ),
    );
  }
}
