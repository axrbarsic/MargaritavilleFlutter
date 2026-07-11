import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../design/margaritaville_colors.dart';
import '../../domain/models/room_media_item.dart';

typedef ResolveRoomMediaPath = Future<String> Function(String relativePath);

final class RoomMediaThumbnail extends StatelessWidget {
  const RoomMediaThumbnail({
    required this.media,
    required this.resolvePath,
    super.key,
  });

  static const width = 132.0;
  static const height = 182.0;

  final RoomMediaItem media;
  final ResolveRoomMediaPath resolvePath;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(14),
    child: DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: MargaritavilleColors.accent.withValues(alpha: 0.18),
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            FutureBuilder<String>(
              future: resolvePath(media.relativePath),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Image.file(
                    File(snapshot.data!),
                    fit: BoxFit.cover,
                    cacheWidth: (width * 2).round(),
                    cacheHeight: (height * 2).round(),
                    filterQuality: FilterQuality.medium,
                    errorBuilder: (_, _, _) => const _MissingMedia(),
                  );
                }
                if (snapshot.hasError) return const _MissingMedia();
                return const ColoredBox(
                  color: Color(0x52000000),
                  child: Center(child: CircularProgressIndicator()),
                );
              },
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.66),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          media.kind == RoomMediaKind.photo
                              ? Icons.camera_alt_rounded
                              : Icons.play_arrow_rounded,
                          size: 10,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _time(media.createdAt),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  static String _time(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${local.hour < 12 ? 'AM' : 'PM'}';
  }
}

final class _MissingMedia extends StatelessWidget {
  const _MissingMedia();

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: Color(0x52000000),
    child: Center(
      child: Icon(
        Icons.broken_image_rounded,
        color: MargaritavilleColors.secondaryText,
      ),
    ),
  );
}
