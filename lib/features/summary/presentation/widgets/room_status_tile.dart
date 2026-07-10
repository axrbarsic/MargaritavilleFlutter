import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../design/margaritaville_colors.dart';
import '../../../../shared/edr/edr_overlay_controller.dart';
import '../../../../shared/edr/edr_overlay_scope.dart';
import '../../../interaction/application/margaritaville_feedback_controller.dart';
import '../../../interaction/presentation/margaritaville_feedback_scope.dart';
import '../../../work_session/domain/models/room_state.dart';
import '../summary_layout_tokens.dart';
import '../summary_swipe_commit_policy.dart';
import '../summary_typography.dart';
import '../summary_visual_policy.dart';
import '../summary_visual_pulse.dart';
import 'room_action_sheet.dart';
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
    super.key,
  });

  final RoomState room;
  final VoidCallback onAdvance;
  final VoidCallback onReset;
  final VoidCallback onToggleVip;
  final VoidCallback onSchedule;
  final VoidCallback onOpenMedia;
  final SummaryVisualPolicy visualPolicy;
  final SummaryVisualPulseEvent? pulseEvent;

  @override
  State<RoomStatusTile> createState() => _RoomStatusTileState();
}

final class _RoomStatusTileState extends State<RoomStatusTile> {
  final GlobalKey _edrRenderKey = GlobalKey();
  var _horizontalDrag = 0.0;
  var _horizontalDragStart = 0.0;
  var _swipeStartFeedbackSent = false;
  var _swipeWarningFeedbackSent = false;
  var _swipeCommitFeedbackSent = false;
  EdrOverlayController? _edrController;
  String? _edrRoomId;

  @override
  void dispose() {
    final roomId = _edrRoomId;
    if (roomId != null) _edrController?.removeTile(roomId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    final color = widget.visualPolicy.vividStatusPaletteEnabled
        ? MargaritavilleColors.vividStatus(room.displayStatus)
        : MargaritavilleColors.status(room.displayStatus);
    final edrController = EdrOverlayScope.maybeControllerOf(context);
    final feedback = MargaritavilleFeedbackScope.maybeControllerOf(context);
    _updateEdrRegistration(edrController, room.roomNumber, color);
    final nativeEdrActive =
        edrController?.isTileRendered(room.roomNumber) ?? false;
    final label = switch (room.displayStatus) {
      RoomDisplayStatus.pending => 'ожидает',
      RoomDisplayStatus.open => 'открыт',
      RoomDisplayStatus.ready => 'готов',
      RoomDisplayStatus.scheduled => 'назначен',
    };

    return KeyedSubtree(
      key: _edrRenderKey,
      child: Semantics(
        button: true,
        label: 'Номер ${room.roomNumber}',
        value: '$label${room.isVip ? ', VIP' : ''}',
        hint:
            'Удерживайте для следующего статуса, свайпните вправо для действий',
        child: GestureDetector(
          key: Key('summary-room-${room.roomNumber}'),
          behavior: HitTestBehavior.opaque,
          dragStartBehavior: DragStartBehavior.down,
          onLongPress: () {
            feedback?.holdCommitHapticOnly();
            widget.onAdvance();
          },
          onHorizontalDragStart: (details) {
            _horizontalDrag = 0;
            _horizontalDragStart = details.localPosition.dx;
            _resetSwipeFeedback();
          },
          onHorizontalDragUpdate: (details) {
            _horizontalDrag = (details.localPosition.dx - _horizontalDragStart)
                .clamp(0, double.infinity);
            _updateSwipeFeedback(feedback, context.size?.width ?? 88);
          },
          onHorizontalDragEnd: (details) {
            final width = context.size?.width ?? 88;
            if (_horizontalDrag >= 38 &&
                SummarySwipeCommitPolicy.compactArmed(
                  translation: _horizontalDrag,
                  velocity: details.primaryVelocity ?? 0,
                  cellWidth: width,
                )) {
              feedback?.actionMenuOpened();
              unawaited(_showActionMenu(context));
            }
            _horizontalDrag = 0;
            _resetSwipeFeedback();
          },
          onHorizontalDragCancel: () {
            _horizontalDrag = 0;
            _resetSwipeFeedback();
          },
          child: SizedBox.expand(
            child: RoomVisualEffectSurface(
              room: room,
              baseColor: color,
              policy: widget.visualPolicy,
              pulseEvent: widget.pulseEvent,
              nativeEdrActive: nativeEdrActive,
              child: DecoratedBox(
                key: Key('summary-room-surface-${room.roomNumber}'),
                decoration: BoxDecoration(
                  color: nativeEdrActive ? Colors.transparent : color,
                  borderRadius: BorderRadius.circular(
                    SummaryLayoutTokens.tileCornerRadius,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 10,
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
                          style: SummaryTypography.roomNumber,
                          minimumScaleFactor: 0.50,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SummaryMinimumScaleText(
                        key: Key('summary-room-time-text-${room.roomNumber}'),
                        text: _time(_timestamp),
                        style: SummaryTypography.roomTime,
                        minimumScaleFactor: 0.62,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _updateSwipeFeedback(
    MargaritavilleFeedbackController? feedback,
    double cellWidth,
  ) {
    final threshold = SummarySwipeCommitPolicy.compactThreshold(cellWidth);
    if (_horizontalDrag >= threshold * 0.86 && !_swipeStartFeedbackSent) {
      _swipeStartFeedbackSent = true;
      feedback?.holdStartHapticOnly();
    }
    if (_horizontalDrag >= threshold * 0.94 && !_swipeWarningFeedbackSent) {
      _swipeWarningFeedbackSent = true;
      feedback?.holdWarningHapticOnly();
    }
    if (_horizontalDrag >= threshold && !_swipeCommitFeedbackSent) {
      _swipeCommitFeedbackSent = true;
      feedback?.holdCommitHapticOnly();
    }
  }

  void _resetSwipeFeedback() {
    _swipeStartFeedbackSent = false;
    _swipeWarningFeedbackSent = false;
    _swipeCommitFeedbackSent = false;
  }

  void _updateEdrRegistration(
    EdrOverlayController? controller,
    String roomId,
    Color baseColor,
  ) {
    if (_edrController != controller || _edrRoomId != roomId) {
      final oldRoomId = _edrRoomId;
      if (oldRoomId != null) _edrController?.removeTile(oldRoomId);
      _edrController = controller;
      _edrRoomId = roomId;
    }
    if (controller == null) return;
    final pulse = widget.visualPolicy.transientPulseEnabled
        ? widget.pulseEvent
        : null;
    final wantsNativeEdr =
        (widget.visualPolicy.statusPulseEnabled && pulse != null) ||
        (widget.room.isVip && widget.visualPolicy.vipHdrLightEnabled);
    if (!wantsNativeEdr) {
      controller.removeTile(roomId);
      return;
    }
    controller.upsertTile(
      roomId: roomId,
      renderKey: _edrRenderKey,
      baseColorArgb: baseColor.toARGB32(),
      cornerRadius: SummaryLayoutTokens.tileCornerRadius,
      vipHdrEnabled:
          widget.room.isVip && widget.visualPolicy.vipHdrLightEnabled,
      vipJellyEnabled: widget.room.isVip && widget.visualPolicy.vipJellyEnabled,
      vipJellySpeed: widget.visualPolicy.vipJellySpeed,
      pulseGeneration: pulse?.generation,
      pulseColorArgb: widget.visualPolicy.statusPulseEnabled && pulse != null
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
