import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../design/margaritaville_colors.dart';
import '../../../../shared/edr/edr_overlay_controller.dart';
import '../../../../shared/edr/edr_overlay_scope.dart';
import '../../../interaction/presentation/margaritaville_feedback_scope.dart';
import '../../../work_session/domain/models/room_state.dart';
import '../summary_layout_tokens.dart';
import '../summary_typography.dart';
import '../summary_visual_policy.dart';
import '../summary_visual_pulse.dart';
import 'room_action_sheet.dart';
import 'room_gesture_arena_target.dart';
import 'room_visual_effect_surface.dart';
import 'summary_minimum_scale_text.dart';

final class RoomStatusTile extends StatefulWidget {
  const RoomStatusTile({
    required this.room,
    required this.onAdvance,
    required this.onReset,
    required this.onToggleVip,
    required this.onSchedule,
    required this.onOpenMedia,
    this.visualPolicy = SummaryVisualPolicy.balanced,
    this.pulseEvent,
    this.contentScale = 1,
    this.fontScale = 1,
    this.compressTextVertically = false,
    super.key,
  }) : assert(contentScale > 0 && contentScale <= 1),
       assert(fontScale > 0 && fontScale <= 1);

  final RoomState room;
  final VoidCallback onAdvance;
  final VoidCallback onReset;
  final VoidCallback onToggleVip;
  final VoidCallback onSchedule;
  final VoidCallback onOpenMedia;
  final SummaryVisualPolicy visualPolicy;
  final SummaryVisualPulseEvent? pulseEvent;
  final double contentScale;
  final double fontScale;
  final bool compressTextVertically;

  @override
  State<RoomStatusTile> createState() => _RoomStatusTileState();
}

final class _RoomStatusTileState extends State<RoomStatusTile> {
  final GlobalKey _edrRenderKey = GlobalKey();
  final ValueNotifier<bool> _nativeEdrActive = ValueNotifier(false);
  EdrOverlayController? _edrController;
  String? _edrRoomId;

  @override
  void dispose() {
    final roomId = _edrRoomId;
    if (roomId != null) {
      _edrController?.removeTile(roomId, renderKey: _edrRenderKey);
    }
    _nativeEdrActive.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    final color = widget.visualPolicy.vividStatusPaletteEnabled
        ? MargaritavilleColors.vividStatus(room.displayStatus)
        : MargaritavilleColors.status(room.displayStatus);
    final feedback = MargaritavilleFeedbackScope.maybeControllerOf(context);
    final edrController = EdrViewportScope.maybeControllerOf(context);
    final pulse = widget.visualPolicy.transientPulseEnabled
        ? widget.pulseEvent
        : null;
    final nativeEdrManaged =
        edrController?.supported == true &&
        ((room.isVip &&
                (widget.visualPolicy.vipHdrLightEnabled ||
                    widget.visualPolicy.vipJellyEnabled)) ||
            (pulse != null && widget.visualPolicy.statusPulseEnabled));
    _updateEdrRegistration(edrController, room.roomNumber, color);
    final label = switch (room.displayStatus) {
      RoomDisplayStatus.pending => 'ожидает',
      RoomDisplayStatus.open => 'открыт',
      RoomDisplayStatus.ready => 'готов',
      RoomDisplayStatus.scheduled => 'назначен',
    };

    return ValueListenableBuilder<bool>(
      valueListenable: _nativeEdrActive,
      builder: (context, nativeEdrActive, _) => KeyedSubtree(
        key: _edrRenderKey,
        child: Semantics(
          button: true,
          label: 'Номер ${room.roomNumber}',
          value: '$label${room.isVip ? ', VIP' : ''}',
          hint:
              'Удерживайте для следующего статуса, свайпните вправо для действий',
          child: RoomGestureArenaTarget(
            key: Key('summary-room-${room.roomNumber}'),
            onHoldCommit: () {
              feedback?.holdCommitHapticOnly();
              widget.onAdvance();
            },
            onSwipeStart: () => feedback?.holdStartHapticOnly(),
            onSwipeWarning: () => feedback?.holdWarningHapticOnly(),
            onSwipeCommit: () => feedback?.holdCommitHapticOnly(),
            onOpenActions: () {
              feedback?.actionMenuOpened();
              unawaited(_showActionMenu(context));
            },
            child: SizedBox.expand(
              child: RoomVisualEffectSurface(
                room: room,
                baseColor: color,
                policy: widget.visualPolicy,
                pulseEvent: widget.pulseEvent,
                nativeEdrActive: nativeEdrActive,
                nativeEdrManaged: nativeEdrManaged,
                child: Opacity(
                  opacity: nativeEdrActive ? 0 : 1,
                  child: DecoratedBox(
                    key: Key('summary-room-surface-${room.roomNumber}'),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(
                        SummaryLayoutTokens.tileCornerRadius,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 10 * widget.contentScale,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: SummaryMinimumScaleText(
                              key: Key(
                                'summary-room-number-text-${room.roomNumber}',
                              ),
                              text: room.roomNumber,
                              style: SummaryTypography.roomNumberAtScale(
                                widget.fontScale,
                              ),
                              minimumScaleFactor: 0.50,
                              compressHeightOnly: widget.compressTextVertically,
                            ),
                          ),
                          SizedBox(height: 6 * widget.contentScale),
                          SummaryMinimumScaleText(
                            key: Key(
                              'summary-room-time-text-${room.roomNumber}',
                            ),
                            text: _time(_timestamp),
                            style: SummaryTypography.roomTimeAtScale(
                              widget.fontScale,
                            ),
                            minimumScaleFactor: 0.62,
                            compressHeightOnly: widget.compressTextVertically,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _updateEdrRegistration(
    EdrOverlayController? controller,
    String roomId,
    Color baseColor,
  ) {
    if (_edrController != controller || _edrRoomId != roomId) {
      final oldRoomId = _edrRoomId;
      if (oldRoomId != null) {
        _edrController?.removeTile(oldRoomId, renderKey: _edrRenderKey);
      }
      _edrController = controller;
      _edrRoomId = roomId;
    }
    if (controller == null) return;
    final pulse = widget.visualPolicy.transientPulseEnabled
        ? widget.pulseEvent
        : null;
    final wantsNativeViewport =
        (widget.room.isVip &&
            (widget.visualPolicy.vipHdrLightEnabled ||
                widget.visualPolicy.vipJellyEnabled)) ||
        (pulse != null && widget.visualPolicy.statusPulseEnabled);
    if (!wantsNativeViewport) {
      controller.removeTile(roomId, renderKey: _edrRenderKey);
      return;
    }
    final pulseColor = pulse == null
        ? null
        : widget.visualPolicy.vividStatusPaletteEnabled
        ? MargaritavilleColors.vividStatus(pulse.status)
        : MargaritavilleColors.status(pulse.status);
    controller.upsertTile(
      roomId: roomId,
      timeText: _time(_timestamp),
      renderKey: _edrRenderKey,
      renderState: _nativeEdrActive,
      baseColorArgb: baseColor.toARGB32(),
      cornerRadius: SummaryLayoutTokens.tileCornerRadius,
      vipHdrEnabled:
          widget.room.isVip && widget.visualPolicy.vipHdrLightEnabled,
      vipJellyEnabled: widget.room.isVip && widget.visualPolicy.vipJellyEnabled,
      vipJellySpeed: widget.visualPolicy.vipJellySpeed,
      pulseGeneration: pulse?.generation,
      pulseColorArgb: widget.visualPolicy.statusPulseEnabled
          ? pulseColor?.toARGB32()
          : null,
      pulseBoostColorArgb:
          widget.visualPolicy.statusPulseEnabled && pulse != null
          ? MargaritavilleColors.vividStatus(pulse.status).toARGB32()
          : null,
      pulseStartedAtMicros: pulse?.startedAt.microsecondsSinceEpoch,
      springIntensity: widget.visualPolicy.springIntensity,
    );
  }

  DateTime get _timestamp {
    if (widget.room.displayStatus == RoomDisplayStatus.scheduled) {
      return widget.room.scheduledFor!;
    }
    return widget.room.timestamps.phaseUpdatedAt;
  }

  bool get _canReset =>
      widget.room.phase != RoomPhase.pending ||
      widget.room.scheduledFor != null;

  Future<void> _showActionMenu(BuildContext context) async {
    final feedback = MargaritavilleFeedbackScope.maybeControllerOf(context);
    final action = await showRoomActionSheet(
      context,
      room: widget.room,
      canReset: _canReset,
    );
    switch (action) {
      case RoomAction.media:
        feedback?.tap();
        widget.onOpenMedia();
        break;
      case RoomAction.vip:
        feedback?.confirm();
        widget.onToggleVip();
        break;
      case RoomAction.schedule:
        feedback?.tap();
        widget.onSchedule();
        break;
      case RoomAction.reset:
        feedback?.deselect();
        widget.onReset();
        break;
      case null:
        break;
    }
  }

  String _time(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final suffix = local.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $suffix';
  }
}
