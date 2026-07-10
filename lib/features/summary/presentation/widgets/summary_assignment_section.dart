import 'package:flutter/material.dart';

import '../../../work_session/domain/catalogs/margaritaville_room_catalog.dart';
import '../../../work_session/domain/models/room_state.dart';
import '../../../work_session/domain/models/work_assignment.dart';
import 'room_status_tile.dart';

final class SummaryAssignmentSection extends StatelessWidget {
  const SummaryAssignmentSection({
    required this.assignment,
    required this.onAdvance,
    required this.onReset,
    super.key,
  });

  final WorkAssignment assignment;
  final ValueChanged<RoomState> onAdvance;
  final ValueChanged<RoomState> onReset;

  @override
  Widget build(BuildContext context) {
    final rooms = assignment.activeRooms.toList()
      ..sort((first, second) => first.roomNumber.compareTo(second.roomNumber));
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF0C1C17),
        border: Border.all(color: const Color(0xFF25473E)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    assignment.housekeeper.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF7FE6CF),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  _territoryLabel(rooms),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rooms.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.04,
              ),
              itemBuilder: (context, index) {
                final room = rooms[index];
                return RoomStatusTile(
                  room: room,
                  onAdvance: () => onAdvance(room),
                  onReset: () => onReset(room),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _territoryLabel(List<RoomState> rooms) {
    final territoryIds = <String>{};
    for (final room in rooms) {
      for (final territory in MargaritavilleRoomCatalog.territories) {
        if (territory.rooms.contains(room.roomNumber)) {
          territoryIds.add(territory.id);
          break;
        }
      }
    }
    return territoryIds.join(' · ');
  }
}
