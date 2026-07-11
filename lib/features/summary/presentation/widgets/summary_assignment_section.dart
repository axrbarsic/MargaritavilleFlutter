import 'package:flutter/material.dart';

import '../../../../design/margaritaville_colors.dart';
import '../../../work_session/domain/catalogs/margaritaville_room_catalog.dart';
import '../../../work_session/domain/models/room_state.dart';
import '../../../work_session/domain/models/work_assignment.dart';
import '../summary_layout_tokens.dart';
import '../summary_tile_geometry.dart';
import '../summary_typography.dart';
import '../summary_visual_policy.dart';
import '../summary_visual_pulse.dart';
import 'room_status_tile.dart';
import 'summary_minimum_scale_text.dart';

final class SummaryAssignmentSection extends StatelessWidget {
  const SummaryAssignmentSection({
    required this.assignment,
    required this.onAdvance,
    required this.onReset,
    required this.onToggleVip,
    required this.onSchedule,
    required this.onOpenMedia,
    this.rooms,
    this.visualPolicy = SummaryVisualPolicy.balanced,
    this.pulseEventFor,
    super.key,
  });

  final WorkAssignment assignment;
  final ValueChanged<RoomState> onAdvance;
  final ValueChanged<RoomState> onReset;
  final ValueChanged<RoomState> onToggleVip;
  final ValueChanged<RoomState> onSchedule;
  final ValueChanged<RoomState> onOpenMedia;
  final List<RoomState>? rooms;
  final SummaryVisualPolicy visualPolicy;
  final SummaryVisualPulseEvent? Function(String roomNumber)? pulseEventFor;

  @override
  Widget build(BuildContext context) {
    final visibleRooms = (rooms ?? assignment.activeRooms.toList()).toList()
      ..sort((first, second) => first.roomNumber.compareTo(second.roomNumber));
    return MediaQuery.withNoTextScaling(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tileGeometry = SummaryTileGeometryResolver.resolve(
            sectionWidth: constraints.maxWidth,
            columns: visualPolicy.gridColumns,
            platform: Theme.of(context).platform,
          );
          if (tileGeometry.size.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.all(SummaryLayoutTokens.sectionPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SummaryAssignmentHeader(
                  assignment: assignment,
                  rooms: visibleRooms,
                ),
                const SizedBox(
                  height: SummaryLayoutTokens.sectionHeaderGridGap,
                ),
                Wrap(
                  spacing: SummaryLayoutTokens.gridSpacing,
                  runSpacing: SummaryLayoutTokens.gridSpacing,
                  children: [
                    for (final room in visibleRooms)
                      SizedBox(
                        width: tileGeometry.size.width,
                        height: tileGeometry.size.height,
                        child: RoomStatusTile(
                          room: room,
                          onAdvance: () => onAdvance(room),
                          onReset: () => onReset(room),
                          onToggleVip: () => onToggleVip(room),
                          onSchedule: () => onSchedule(room),
                          onOpenMedia: () => onOpenMedia(room),
                          visualPolicy: visualPolicy,
                          pulseEvent: pulseEventFor?.call(room.roomNumber),
                          contentScale: tileGeometry.contentScale,
                          fontScale: tileGeometry.fontScale,
                          compressTextVertically:
                              tileGeometry.compressTextVertically,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

final class SummaryAssignmentHeader extends StatelessWidget {
  const SummaryAssignmentHeader({
    required this.assignment,
    required this.rooms,
    super.key,
  });

  final WorkAssignment assignment;
  final List<RoomState> rooms;

  @override
  Widget build(BuildContext context) {
    final palette = MargaritavilleColors.housekeeper(
      assignment.housekeeper.paletteKey,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Flexible(
          child: DecoratedBox(
            key: Key('summary-housekeeper-name-${assignment.housekeeper.id}'),
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                Colors.black.withValues(alpha: 0.34),
                palette.withValues(alpha: 0.20),
              ),
              border: Border.all(
                color: palette.withValues(alpha: 0.72),
                width: 1.5,
                strokeAlign: BorderSide.strokeAlignCenter,
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: SummaryMinimumScaleText(
                text: assignment.housekeeper.displayName,
                style: SummaryTypography.housekeeperName(palette),
                minimumScaleFactor: 0.62,
                alignment: Alignment.centerLeft,
                textAlign: TextAlign.start,
                shrinkWrap: true,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: SummaryMinimumScaleText(
              text: _territoryLabel(rooms),
              style: SummaryTypography.territory,
              minimumScaleFactor: 0.58,
              alignment: Alignment.centerRight,
              textAlign: TextAlign.end,
            ),
          ),
        ),
      ],
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
