import 'package:flutter/material.dart';

import '../../../../design/margaritaville_colors.dart';
import '../../domain/models/room_media_item.dart';
import 'room_media_thumbnail.dart';

final class RoomDetailsMediaSection extends StatelessWidget {
  const RoomDetailsMediaSection({
    required this.media,
    required this.onPhoto,
    required this.onVideo,
    required this.onOpen,
    required this.onDelete,
    required this.resolvePath,
    this.statusText,
    this.statusIsError = false,
    super.key,
  });

  final List<RoomMediaItem> media;
  final VoidCallback onPhoto;
  final VoidCallback onVideo;
  final ValueChanged<RoomMediaItem> onOpen;
  final ValueChanged<RoomMediaItem>? onDelete;
  final ResolveRoomMediaPath resolvePath;
  final String? statusText;
  final bool statusIsError;

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
        if (statusText case final status?) ...[
          const SizedBox(height: 10),
          Text(
            status,
            key: const Key('room-details-photo-status'),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: statusIsError
                  ? MargaritavilleColors.pending
                  : MargaritavilleColors.secondaryText,
            ),
          ),
        ],
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
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: RoomMediaThumbnail.height,
            ),
            itemCount: visual.length,
            itemBuilder: (context, index) {
              final item = visual[index];
              return Center(
                child: SizedBox(
                  width: RoomMediaThumbnail.width,
                  height: RoomMediaThumbnail.height,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: InkWell(
                          key: ValueKey('room-media-open-${item.id}'),
                          onTap: () => onOpen(item),
                          borderRadius: BorderRadius.circular(14),
                          child: RoomMediaThumbnail(
                            media: item,
                            resolvePath: resolvePath,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 7,
                        top: 7,
                        child: IconButton(
                          key: ValueKey('room-media-delete-${item.id}'),
                          tooltip: 'Удалить медиа',
                          onPressed: onDelete == null
                              ? null
                              : () => onDelete!(item),
                          icon: const Icon(Icons.delete_rounded),
                          iconSize: 12,
                          color: Colors.white,
                          style: IconButton.styleFrom(
                            fixedSize: const Size(30, 30),
                            minimumSize: const Size(30, 30),
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            backgroundColor: MargaritavilleColors.pending
                                .withValues(alpha: 0.94),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
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
