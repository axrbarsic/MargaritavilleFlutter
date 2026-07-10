import 'package:flutter/material.dart';

import '../../../../design/margaritaville_colors.dart';
import '../../../work_session/domain/models/room_state.dart';

enum RoomAction { media, vip, schedule, reset }

Future<RoomAction?> showRoomActionSheet(
  BuildContext context, {
  required RoomState room,
  required bool canReset,
}) {
  return showModalBottomSheet<RoomAction>(
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
              'Комната ${room.roomNumber}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
          ),
          _actionTile(
            context,
            action: RoomAction.media,
            key: const Key('room-action-media'),
            icon: Icons.mic_rounded,
            label: 'Голос/медиа',
          ),
          _actionTile(
            context,
            action: RoomAction.vip,
            key: const Key('room-action-vip'),
            icon: room.isVip ? Icons.diamond_rounded : Icons.diamond_outlined,
            label: room.isVip ? 'VIP выключить' : 'VIP включить',
          ),
          _actionTile(
            context,
            action: RoomAction.schedule,
            key: const Key('room-action-schedule'),
            icon: Icons.schedule_rounded,
            label: 'Назначить время',
          ),
          if (canReset)
            _actionTile(
              context,
              action: RoomAction.reset,
              key: const Key('room-action-reset'),
              icon: Icons.restart_alt_rounded,
              label: 'Вернуть в жёлтый',
            ),
        ],
      ),
    ),
  );
}

Widget _actionTile(
  BuildContext context, {
  required RoomAction action,
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
