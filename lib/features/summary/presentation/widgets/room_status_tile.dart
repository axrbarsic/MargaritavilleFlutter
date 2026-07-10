import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../design/margaritaville_colors.dart';
import '../../../work_session/domain/models/room_state.dart';
import '../summary_layout_tokens.dart';
import '../summary_swipe_commit_policy.dart';
import '../summary_visual_policy.dart';
import '../summary_visual_pulse.dart';
import 'room_visual_effect_surface.dart';

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
  var _horizontalDrag = 0.0;
  var _horizontalDragStart = 0.0;

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    final color = switch (room.displayStatus) {
      RoomDisplayStatus.pending => MargaritavilleColors.pending,
      RoomDisplayStatus.open => MargaritavilleColors.open,
      RoomDisplayStatus.ready => MargaritavilleColors.ready,
      RoomDisplayStatus.scheduled => MargaritavilleColors.scheduled,
    };
    final label = switch (room.displayStatus) {
      RoomDisplayStatus.pending => 'ожидает',
      RoomDisplayStatus.open => 'открыт',
      RoomDisplayStatus.ready => 'готов',
      RoomDisplayStatus.scheduled => 'назначен',
    };

    return Semantics(
      button: true,
      label: 'Номер ${room.roomNumber}',
      value: '$label${room.isVip ? ', VIP' : ''}',
      hint: 'Удерживайте для следующего статуса, свайпните вправо для действий',
      child: GestureDetector(
        key: Key('summary-room-${room.roomNumber}'),
        behavior: HitTestBehavior.opaque,
        dragStartBehavior: DragStartBehavior.down,
        onLongPress: widget.onAdvance,
        onHorizontalDragStart: (details) {
          _horizontalDrag = 0;
          _horizontalDragStart = details.localPosition.dx;
        },
        onHorizontalDragUpdate: (details) {
          _horizontalDrag = (details.localPosition.dx - _horizontalDragStart)
              .clamp(0, double.infinity);
        },
        onHorizontalDragEnd: (details) {
          final width = context.size?.width ?? 88;
          if (_horizontalDrag >= 38 &&
              SummarySwipeCommitPolicy.compactArmed(
                translation: _horizontalDrag,
                velocity: details.primaryVelocity ?? 0,
                cellWidth: width,
              )) {
            unawaited(_showActionMenu(context));
          }
          _horizontalDrag = 0;
        },
        child: RoomVisualEffectSurface(
          room: room,
          baseColor: color,
          policy: widget.visualPolicy,
          pulseEvent: widget.pulseEvent,
          child: DecoratedBox(
            key: Key('summary-room-surface-${room.roomNumber}'),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(
                SummaryLayoutTokens.tileCornerRadius,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        room.roomNumber,
                        maxLines: 1,
                        style: const TextStyle(
                          color: MargaritavilleColors.roomForeground,
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _time(_timestamp),
                      maxLines: 1,
                      style: const TextStyle(
                        color: MargaritavilleColors.roomForeground,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
    final action = await showModalBottomSheet<_RoomAction>(
      context: context,
      backgroundColor: MargaritavilleColors.surface,
      showDragHandle: true,
      builder: (context) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 6),
              child: Text(
                'Комната ${widget.room.roomNumber}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            _actionTile(
              context,
              action: _RoomAction.media,
              key: const Key('room-action-media'),
              icon: Icons.mic_rounded,
              label: 'Голос/медиа',
            ),
            _actionTile(
              context,
              action: _RoomAction.vip,
              key: const Key('room-action-vip'),
              icon: widget.room.isVip
                  ? Icons.diamond_rounded
                  : Icons.diamond_outlined,
              label: widget.room.isVip ? 'VIP выключить' : 'VIP включить',
            ),
            _actionTile(
              context,
              action: _RoomAction.schedule,
              key: const Key('room-action-schedule'),
              icon: Icons.schedule_rounded,
              label: 'Назначить время',
            ),
            if (_canReset)
              _actionTile(
                context,
                action: _RoomAction.reset,
                key: const Key('room-action-reset'),
                icon: Icons.restart_alt_rounded,
                label: 'Вернуть в жёлтый',
              ),
          ],
        ),
      ),
    );
    switch (action) {
      case _RoomAction.media:
        widget.onOpenMedia();
        break;
      case _RoomAction.vip:
        widget.onToggleVip();
        break;
      case _RoomAction.schedule:
        widget.onSchedule();
        break;
      case _RoomAction.reset:
        widget.onReset();
        break;
      case null:
        break;
    }
  }

  Widget _actionTile(
    BuildContext context, {
    required _RoomAction action,
    required Key key,
    required IconData icon,
    required String label,
  }) {
    return ListTile(
      key: key,
      leading: Icon(icon),
      title: Text(label),
      onTap: () => Navigator.pop(context, action),
    );
  }

  String _time(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final suffix = local.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $suffix';
  }
}

enum _RoomAction { media, vip, schedule, reset }
