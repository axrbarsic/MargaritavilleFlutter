import 'package:flutter/material.dart';

import '../../../../design/margaritaville_colors.dart';
import '../../../work_session/domain/catalogs/margaritaville_room_catalog.dart';
import '../../../work_session/domain/models/room_state.dart';
import '../../../work_session/domain/models/work_assignment.dart';
import '../summary_layout_tokens.dart';
import 'room_status_tile.dart';

final class SummaryAssignmentSection extends StatelessWidget {
  const SummaryAssignmentSection({
    required this.assignment,
    required this.onAdvance,
    required this.onReset,
    this.rooms,
    super.key,
  });

  final WorkAssignment assignment;
  final ValueChanged<RoomState> onAdvance;
  final ValueChanged<RoomState> onReset;
  final List<RoomState>? rooms;

  @override
  Widget build(BuildContext context) {
    final visibleRooms = (rooms ?? assignment.activeRooms.toList()).toList()
      ..sort((first, second) => first.roomNumber.compareTo(second.roomNumber));
    final palette = MargaritavilleColors.housekeeper(
      assignment.housekeeper.paletteKey,
    );
    return Padding(
      padding: const EdgeInsets.all(SummaryLayoutTokens.sectionPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Color.alphaBlend(
                      Colors.black.withValues(alpha: 0.34),
                      palette.withValues(alpha: 0.20),
                    ),
                    border: Border.all(
                      color: palette.withValues(alpha: 0.72),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    assignment.housekeeper.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      color: palette,
                      shadows: const [
                        Shadow(
                          color: Color(0xEB000000),
                          blurRadius: 3.2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _territoryLabel(visibleRooms),
                      maxLines: 1,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SummaryLayoutTokens.sectionHeaderGridGap),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visibleRooms.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: SummaryLayoutTokens.gridColumns,
              crossAxisSpacing: SummaryLayoutTokens.gridSpacing,
              mainAxisSpacing: SummaryLayoutTokens.gridSpacing,
              mainAxisExtent: SummaryLayoutTokens.tileHeight,
            ),
            itemBuilder: (context, index) {
              final room = visibleRooms[index];
              return RoomStatusTile(
                room: room,
                onAdvance: () => onAdvance(room),
                onReset: () => onReset(room),
              );
            },
          ),
        ],
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
    return territoryIds.join(' ');
  }
}
