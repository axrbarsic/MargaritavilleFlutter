import 'package:flutter/material.dart';

import '../../../../design/margaritaville_colors.dart';
import '../../../work_session/domain/models/housekeeper.dart';

final class HousekeeperSelector extends StatelessWidget {
  const HousekeeperSelector({
    required this.housekeepers,
    required this.selectedHousekeeperIds,
    required this.focusedHousekeeperId,
    required this.onSelected,
    super.key,
  });

  final List<Housekeeper> housekeepers;
  final Set<String> selectedHousekeeperIds;
  final String? focusedHousekeeperId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 68,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: housekeepers.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final housekeeper = housekeepers[index];
          final selected = selectedHousekeeperIds.contains(housekeeper.id);
          final focused = focusedHousekeeperId == housekeeper.id;
          final color = MargaritavilleColors.housekeeper(
            housekeeper.paletteKey,
          );
          return ChoiceChip(
            key: Key('setup-housekeeper-${housekeeper.id}'),
            selected: selected,
            showCheckmark: selected,
            avatar: CircleAvatar(radius: 7, backgroundColor: color),
            label: Text(
              housekeeper.displayName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            side: BorderSide(
              color: focused ? Colors.white70 : color.withValues(alpha: 0.5),
              width: 1.5,
            ),
            onSelected: (_) => onSelected(housekeeper.id),
          );
        },
      ),
    );
  }
}
