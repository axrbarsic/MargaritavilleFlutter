import 'package:flutter/material.dart';

import '../../../work_session/domain/catalogs/margaritaville_room_catalog.dart';
import '../../../work_session/domain/models/work_assignment.dart';
import '../../../work_session/domain/models/work_session.dart';
import 'setup_room_grid.dart';

final class WorkSetupAssignmentCard extends StatelessWidget {
  const WorkSetupAssignmentCard({
    required this.session,
    required this.assignment,
    required this.focused,
    required this.onFocus,
    required this.onRemove,
    required this.onTerritoryChanged,
    required this.onRoomTap,
    super.key,
  });

  final WorkSession session;
  final WorkAssignment assignment;
  final bool focused;
  final VoidCallback onFocus;
  final VoidCallback onRemove;
  final ValueChanged<String> onTerritoryChanged;
  final ValueChanged<String> onRoomTap;

  @override
  Widget build(BuildContext context) {
    final territory = MargaritavilleRoomCatalog.territory(
      assignment.territoryId,
    )!;
    return Card(
      key: Key('setup-assignment-${assignment.id}'),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: focused
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.primary.withValues(alpha: 0.22),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onFocus,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      assignment.housekeeper.displayName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    key: Key('setup-remove-${assignment.id}'),
                    tooltip: 'Убрать уборщицу из смены',
                    onPressed: onRemove,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final candidate
                        in MargaritavilleRoomCatalog.territories) ...[
                      ChoiceChip(
                        key: Key(
                          'setup-territory-${assignment.id}-${candidate.id}',
                        ),
                        label: Text(candidate.id),
                        selected: candidate.id == territory.id,
                        onSelected: (_) => onTerritoryChanged(candidate.id),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              if (_offTerritoryLabel(territory.id) case final label?) ...[
                const SizedBox(height: 8),
                Text(label, style: Theme.of(context).textTheme.bodySmall),
              ],
              const SizedBox(height: 12),
              SetupRoomGrid(
                roomNumbers: territory.rooms,
                session: session,
                selectedAssignment: assignment,
                onRoomTap: onRoomTap,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _offTerritoryLabel(String activeTerritoryId) {
    final groups = <String, List<String>>{};
    for (final room in assignment.activeRooms) {
      for (final territory in MargaritavilleRoomCatalog.territories) {
        if (territory.id == activeTerritoryId ||
            !territory.rooms.contains(room.roomNumber)) {
          continue;
        }
        groups.putIfAbsent(territory.id, () => []).add(room.roomNumber);
        break;
      }
    }
    if (groups.isEmpty) return null;
    return groups.entries
        .map((entry) => '${entry.key}: ${entry.value.join(', ')}')
        .join('  •  ');
  }
}
