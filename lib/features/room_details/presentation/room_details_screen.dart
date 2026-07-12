import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/margaritaville_colors.dart';
import '../../../shared/media/capture/captured_photo_artifact.dart';
import '../../interaction/application/margaritaville_interaction_dispatcher.dart';
import '../../interaction/domain/margaritaville_interaction_intent.dart';
import '../../interaction/presentation/margaritaville_feedback_scope.dart';
import '../application/media/room_photo_capture_state.dart';
import '../domain/models/room_media_item.dart';
import 'camera/room_photo_camera_screen.dart';
import 'controllers/room_details_controller.dart';
import 'controllers/room_photo_capture_controller.dart';
import 'controllers/room_voice_capture_controller.dart';
import 'room_media_viewer_screen.dart';
import 'widgets/room_details_media_section.dart';
import 'widgets/room_details_shell_widgets.dart';
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
    MargaritavilleInteractionDispatcher interactions() =>
        MargaritavilleFeedbackScope.dispatcherOf(context);
    final request = (sessionId: sessionId, roomNumber: roomNumber);
    final details = ref.watch(roomDetailsControllerProvider(request));
    final voice = ref.watch(roomVoiceCaptureControllerProvider(request));
    final photo = ref.watch(roomPhotoCaptureControllerProvider(request));
    final mediaStore = ref.watch(roomMediaArtifactStoreProvider);
    return Scaffold(
      key: const Key('room-details-screen'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RoomDetailsHeader(roomNumber: roomNumber),
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
                          onPressed: () => interactions().acceptAsyncOnce(
                            'room-voice-$sessionId-$roomNumber',
                            MargaritavilleInteractionIntent.confirm,
                            () => ref
                                .read(
                                  roomVoiceCaptureControllerProvider(
                                    request,
                                  ).notifier,
                                )
                                .toggle(),
                          ),
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
                          statusText: photo.phase == RoomPhotoCapturePhase.idle
                              ? null
                              : photo.statusText,
                          statusIsError:
                              photo.phase == RoomPhotoCapturePhase.failed,
                          onPhoto: photo.isBusy
                              ? () {}
                              : () => interactions().acceptAsyncOnce(
                                  'room-photo-route-$sessionId-$roomNumber',
                                  MargaritavilleInteractionIntent.navigate,
                                  () => _capturePhoto(context, ref, request),
                                ),
                          onVideo: () => interactions().accept(
                            MargaritavilleInteractionIntent.invalid,
                            () => _showNativeServiceNotice(context),
                          ),
                          resolvePath: mediaStore.resolveFinalPath,
                          onOpen: (item) => interactions().accept(
                            MargaritavilleInteractionIntent.navigate,
                            () => _openMediaViewer(
                              context,
                              snapshot.media,
                              item,
                              mediaStore.resolveFinalPath,
                            ),
                          ),
                          onDelete: photo.isBusy
                              ? null
                              : (item) => interactions().acceptAsyncOnce(
                                  'room-media-delete-${item.id}',
                                  MargaritavilleInteractionIntent.destructive,
                                  () => ref
                                      .read(
                                        roomPhotoCaptureControllerProvider(
                                          request,
                                        ).notifier,
                                      )
                                      .delete(item),
                                ),
                        ),
                      ],
                    ),
                    loading: () => const SizedBox(
                      height: 240,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, _) => RoomDetailsLoadError(
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

  static Future<void> _capturePhoto(
    BuildContext context,
    WidgetRef ref,
    RoomDetailsRequest request,
  ) async {
    try {
      final capture = await Navigator.of(context).push<CapturedPhotoArtifact>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => const RoomPhotoCameraScreen(),
        ),
      );
      if (capture == null || !context.mounted) return;
      await ref
          .read(roomPhotoCaptureControllerProvider(request).notifier)
          .save(capture);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Не удалось открыть камеру')),
        );
    }
  }

  static void _openMediaViewer(
    BuildContext context,
    List<RoomMediaItem> media,
    RoomMediaItem selected,
    Future<String> Function(String) resolvePath,
  ) {
    final visual = media
        .where(
          (item) =>
              item.kind == RoomMediaKind.photo ||
              item.kind == RoomMediaKind.video,
        )
        .toList(growable: false);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => RoomMediaViewerScreen(
          media: visual,
          initialMediaId: selected.id,
          resolvePath: resolvePath,
        ),
      ),
    );
  }
}
