import 'package:flutter/material.dart';

import '../../../../design/margaritaville_colors.dart';
import '../../domain/models/room_media_item.dart';

final class RoomDetailsMediaSection extends StatelessWidget {
  const RoomDetailsMediaSection({
    required this.media,
    required this.onPhoto,
    required this.onVideo,
    super.key,
  });

  final List<RoomMediaItem> media;
  final VoidCallback onPhoto;
  final VoidCallback onVideo;

  @override
  Widget build(BuildContext context) {
    final visual = media
        .where(
          (item) =>
              item.kind == RoomMediaKind.photo ||
              item.kind == RoomMediaKind.video,
        )
        .toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _MediaAction(
                key: const Key('room-details-photo'),
                icon: Icons.camera_alt_rounded,
                label: 'Фото',
                onPressed: onPhoto,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MediaAction(
                key: const Key('room-details-video'),
                icon: Icons.videocam_rounded,
                label: 'Видео',
                onPressed: onVideo,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (visual.isEmpty)
          const Text(
            'Фото и видео сохраняются локально и не синхронизируются.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: MargaritavilleColors.secondaryText,
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: visual.length,
            itemBuilder: (context, index) => DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                visual[index].kind == RoomMediaKind.photo
                    ? Icons.photo_rounded
                    : Icons.play_circle_fill_rounded,
                size: 36,
                color: MargaritavilleColors.secondaryText,
              ),
            ),
          ),
      ],
    );
  }
}

final class _MediaAction extends StatelessWidget {
  const _MediaAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 86,
        decoration: BoxDecoration(
          color: MargaritavilleColors.accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: MargaritavilleColors.accent.withValues(alpha: 0.20),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26, color: MargaritavilleColors.secondaryText),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: MargaritavilleColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
