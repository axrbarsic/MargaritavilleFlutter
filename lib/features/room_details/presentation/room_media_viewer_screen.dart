import 'dart:io';

import 'package:flutter/material.dart';

import '../../interaction/domain/margaritaville_interaction_intent.dart';
import '../../interaction/presentation/margaritaville_feedback_scope.dart';

import '../domain/models/room_media_item.dart';
import 'widgets/room_media_thumbnail.dart';

final class RoomMediaViewerScreen extends StatefulWidget {
  const RoomMediaViewerScreen({
    required this.media,
    required this.initialMediaId,
    required this.resolvePath,
    super.key,
  });

  final List<RoomMediaItem> media;
  final String initialMediaId;
  final ResolveRoomMediaPath resolvePath;

  @override
  State<RoomMediaViewerScreen> createState() => _RoomMediaViewerScreenState();
}

final class _RoomMediaViewerScreenState extends State<RoomMediaViewerScreen> {
  late final PageController _pages;
  late int _index;

  @override
  void initState() {
    super.initState();
    final initial = widget.media.indexWhere(
      (item) => item.id == widget.initialMediaId,
    );
    _index = initial < 0 ? 0 : initial;
    _pages = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.media[_index];
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            key: const Key('room-media-viewer-pages'),
            controller: _pages,
            itemCount: widget.media.length,
            onPageChanged: (index) => setState(() => _index = index),
            itemBuilder: (context, index) => _PhotoPage(
              media: widget.media[index],
              resolvePath: widget.resolvePath,
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 14, top: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      key: const Key('room-media-viewer-close'),
                      onPressed: () =>
                          MargaritavilleFeedbackScope.dispatcherOf(
                            context,
                          ).accept(
                            MargaritavilleInteractionIntent.navigate,
                            () => Navigator.pop(context),
                          ),
                      icon: const Icon(Icons.close_rounded),
                      iconSize: 18,
                      color: Colors.white,
                      style: IconButton.styleFrom(
                        fixedSize: const Size(44, 44),
                        backgroundColor: Colors.black.withValues(alpha: 0.62),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_index + 1} / ${widget.media.length}',
                          key: const Key('room-media-viewer-counter'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _timestamp(selected.createdAt),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _timestamp(DateTime value) {
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
}

final class _PhotoPage extends StatelessWidget {
  const _PhotoPage({required this.media, required this.resolvePath});

  final RoomMediaItem media;
  final ResolveRoomMediaPath resolvePath;

  @override
  Widget build(BuildContext context) {
    if (media.kind != RoomMediaKind.photo) {
      return const Center(
        child: Icon(Icons.play_circle_fill_rounded, size: 64),
      );
    }
    return FutureBuilder<String>(
      future: resolvePath(media.relativePath),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return InteractiveViewer(
            key: ValueKey('room-media-zoom-${media.id}'),
            minScale: 1,
            maxScale: 5,
            clipBehavior: Clip.hardEdge,
            child: SizedBox.expand(
              child: Image.file(
                File(snapshot.data!),
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const _MissingPhoto(),
              ),
            ),
          );
        }
        if (snapshot.hasError) return const _MissingPhoto();
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

final class _MissingPhoto extends StatelessWidget {
  const _MissingPhoto();

  @override
  Widget build(BuildContext context) => const Center(
    child: Text(
      'Файл фото не найден',
      style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
    ),
  );
}
