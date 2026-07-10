import 'package:flutter/material.dart';

import '../../../work_session/domain/models/room_state.dart';

final class RoomStatusTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final color = switch (room.displayStatus) {
      RoomDisplayStatus.pending => const Color(0xFFE4C33F),
      RoomDisplayStatus.open => const Color(0xFFE95757),
      RoomDisplayStatus.ready => const Color(0xFF38B96E),
      RoomDisplayStatus.scheduled => const Color(0xFFE15B9D),
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
        onLongPress: onAdvance,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: room.isVip ? const Color(0xFFFFE88C) : Colors.white24,
              width: room.isVip ? 3 : 1,
            ),
            boxShadow: room.isVip
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.55),
                      blurRadius: 13,
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      room.roomNumber,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: const Color(0xFF08120F),
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                ),
              ),
              if (room.displayStatus == RoomDisplayStatus.scheduled)
                Positioned(
                  left: 7,
                  right: 7,
                  bottom: 5,
                  child: Text(
                    _time(room.scheduledFor!),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF08120F),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              if (room.phase == RoomPhase.ready)
                Positioned(
                  right: 2,
                  top: 2,
                  child: Semantics(
                    button: true,
                    label: 'Сбросить номер ${room.roomNumber}',
                    hint: 'Удерживайте для явного сброса',
                    child: GestureDetector(
                      key: Key('reset-room-${room.roomNumber}'),
                      onLongPress: onReset,
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Icons.restart_alt_rounded,
                          size: 17,
                          color: Color(0xFF08120F),
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
  }

  String _time(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final suffix = local.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $suffix';
  }
}
