import 'package:flutter/material.dart';

import '../../../work_session/domain/models/work_assignment.dart';
import '../../../work_session/domain/models/work_session.dart';

final class SetupRoomGrid extends StatelessWidget {
  const SetupRoomGrid({
    required this.roomNumbers,
    required this.session,
    required this.selectedAssignment,
    required this.onRoomHeld,
    super.key,
  });

  final List<String> roomNumbers;
  final WorkSession session;
  final WorkAssignment selectedAssignment;
  final ValueChanged<String> onRoomHeld;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: roomNumbers.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (context, index) {
        final roomNumber = roomNumbers[index];
        final owner = _owner(roomNumber);
        final isSelected = owner?.id == selectedAssignment.id;
        final isBlocked = owner != null && !isSelected;
        return Semantics(
          button: true,
          label: 'Номер $roomNumber',
          value: isSelected
              ? 'выбран для ${selectedAssignment.housekeeper.displayName}'
              : isBlocked
              ? 'занят ${owner.housekeeper.displayName}'
              : 'не выбран',
          hint: 'Удерживайте, чтобы изменить выбор',
          child: GestureDetector(
            key: Key('setup-room-$roomNumber'),
            onLongPress: () => onRoomHeld(roomNumber),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF006C64)
                    : isBlocked
                    ? const Color(0xFF303B39)
                    : const Color(0xFF10251F),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF65F7DE)
                      : const Color(0xFF315A50),
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      child: Text(
                        roomNumber,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (isBlocked)
                      Text(
                        owner.housekeeper.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  WorkAssignment? _owner(String roomNumber) {
    for (final assignment in session.activeAssignments) {
      if (assignment.room(roomNumber) != null) return assignment;
    }
    return null;
  }
}
