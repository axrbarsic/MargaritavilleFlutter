import 'package:flutter/material.dart';

import '../../../work_session/domain/models/work_assignment.dart';

final class HousekeeperSelector extends StatelessWidget {
  const HousekeeperSelector({
    required this.assignments,
    required this.selectedAssignmentId,
    required this.onSelected,
    super.key,
  });

  final List<WorkAssignment> assignments;
  final String selectedAssignmentId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: assignments.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final assignment = assignments[index];
          return ChoiceChip(
            selected: assignment.id == selectedAssignmentId,
            label: Text(assignment.housekeeper.displayName),
            onSelected: (_) => onSelected(assignment.id),
          );
        },
      ),
    );
  }
}
