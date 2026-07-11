import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/app/margaritaville_theme.dart';
import 'package:margaritaville_flutter/features/summary/presentation/summary_visual_policy.dart';
import 'package:margaritaville_flutter/features/summary/presentation/widgets/summary_assignment_section.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/housekeeper.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/room_state.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_assignment.dart';

void main() {
  testWidgets('three columns widen tiles without changing donor height', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: MargaritavilleTheme.dark,
        home: Scaffold(
          body: SizedBox(
            width: 424,
            child: SummaryAssignmentSection(
              assignment: _assignment(),
              visualPolicy: const SummaryVisualPolicy(
                gridColumns: SummaryGridColumns.three,
              ),
              onAdvance: (_) {},
              onReset: (_) {},
              onToggleVip: (_) {},
              onSchedule: (_) {},
              onOpenMedia: (_) {},
            ),
          ),
        ),
      ),
    );

    final firstTile = find.byKey(const Key('summary-room-101'));
    final firstSurface = find.byKey(const Key('summary-room-surface-101'));
    final fourthTile = find.byKey(const Key('summary-room-104'));
    expect(tester.getSize(firstTile), const Size(130.66666666666666, 98));
    expect(tester.getSize(firstSurface), tester.getSize(firstTile));
    expect(
      tester.getTopLeft(fourthTile).dy - tester.getBottomLeft(firstTile).dy,
      closeTo(8, 0.01),
    );
  });
}

WorkAssignment _assignment() {
  final selectedAt = DateTime(2027, 2, 10, 20, 47);
  return WorkAssignment(
    id: 'assignment-1',
    cartNumber: 1,
    housekeeper: Housekeeper(
      id: 'ketty',
      displayName: 'Ketty',
      paletteKey: 'ruby',
      updatedAt: selectedAt,
    ),
    assignedAt: selectedAt,
    updatedAt: selectedAt,
    rooms: [
      for (final roomNumber in ['101', '102', '103', '104'])
        RoomState.pending(roomNumber: roomNumber, selectedAt: selectedAt),
    ],
  );
}
