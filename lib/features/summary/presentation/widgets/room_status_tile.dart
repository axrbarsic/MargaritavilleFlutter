import 'package:flutter/material.dart';

import '../../../../design/margaritaville_colors.dart';
import '../../../work_session/domain/models/room_state.dart';
import '../summary_layout_tokens.dart';

final class RoomStatusTile extends StatefulWidget {
  const RoomStatusTile({
    required this.room,
    required this.onAdvance,
    required this.onReset,
    super.key,
  });

  final RoomState room;
  final VoidCallback onAdvance;
  final VoidCallback onReset;

  @override
  State<RoomStatusTile> createState() => _RoomStatusTileState();
}

final class _RoomStatusTileState extends State<RoomStatusTile> {
  var _horizontalDrag = 0.0;

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
      hint: 'Удерживайте для следующего статуса',
      child: GestureDetector(
        key: Key('summary-room-${room.roomNumber}'),
        behavior: HitTestBehavior.opaque,
        onLongPress: widget.onAdvance,
        onHorizontalDragStart: (_) => _horizontalDrag = 0,
        onHorizontalDragUpdate: (details) {
          _horizontalDrag = (_horizontalDrag + details.delta.dx).clamp(
            0,
            double.infinity,
          );
        },
        onHorizontalDragEnd: (_) {
          if (_horizontalDrag >= 48 && _canReset) {
            _showActionMenu(context);
          }
          _horizontalDrag = 0;
        },
        child: DecoratedBox(
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
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: MargaritavilleColors.surface,
      builder: (context) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.restart_alt_rounded),
          title: const Text('Вернуть в жёлтый'),
          onTap: () {
            Navigator.pop(context);
            widget.onReset();
          },
        ),
      ),
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
