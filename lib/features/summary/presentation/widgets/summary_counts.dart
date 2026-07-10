import 'package:flutter/material.dart';

import '../../../work_session/domain/models/work_session.dart';

final class SummaryCountsView extends StatelessWidget {
  const SummaryCountsView({required this.session, super.key});

  final WorkSession session;

  @override
  Widget build(BuildContext context) {
    final rooms = session.activeRooms.toList();
    final ready = rooms.where((room) => room.phase.name == 'ready').length;
    final values = [
      ('Всего ${rooms.length}', const Color(0xFFE7C94D)),
      ('Готово $ready', const Color(0xFF55D889)),
      ('Осталось ${rooms.length - ready}', const Color(0xFFFF6B6B)),
    ];

    return Row(
      children: [
        for (var index = 0; index < values.length; index++) ...[
          if (index > 0) const SizedBox(width: 8),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: values[index].$2.withValues(alpha: 0.12),
                border: Border.all(
                  color: values[index].$2.withValues(alpha: 0.6),
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 4,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    values[index].$1,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
