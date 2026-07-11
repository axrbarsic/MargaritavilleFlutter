import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/app/margaritaville_theme.dart';
import 'package:margaritaville_flutter/features/summary/presentation/summary_visual_policy.dart';
import 'package:margaritaville_flutter/features/summary/presentation/widgets/summary_assignment_section.dart';
import 'package:margaritaville_flutter/features/summary/presentation/widgets/summary_minimum_scale_text.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/housekeeper.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/room_state.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_assignment.dart';

void main() {
  testWidgets('Android three columns widen only the tile width', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: MargaritavilleTheme.dark.copyWith(
          platform: TargetPlatform.android,
        ),
        home: Scaffold(
          body: SizedBox(
            width: 329.6,
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
    expect(tester.getSize(firstTile).width, closeTo(99.2, 0.001));
    expect(tester.getSize(firstTile).height, closeTo(72.4, 0.001));
    expect(tester.getSize(firstSurface), tester.getSize(firstTile));
    expect(
      tester.getTopLeft(fourthTile).dy - tester.getBottomLeft(firstTile).dy,
      closeTo(8, 0.01),
    );
  });

  testWidgets('iOS three columns are wide and exactly 25 percent shorter', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: MargaritavilleTheme.dark.copyWith(platform: TargetPlatform.iOS),
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
    final number = tester.widget<SummaryMinimumScaleText>(
      find.byKey(const Key('summary-room-number-text-101')),
    );
    final time = tester.widget<SummaryMinimumScaleText>(
      find.byKey(const Key('summary-room-time-text-101')),
    );
    expect(tester.getSize(firstTile).width, closeTo(130.6666667, 0.001));
    expect(tester.getSize(firstTile).height, 73.5);
    expect(tester.getSize(firstSurface), tester.getSize(firstTile));
    expect(number.style.fontSize, 44);
    expect(time.style.fontSize, 16);
    expect(number.compressHeightOnly, isTrue);
    final numberTransform = tester.widget<Transform>(
      find.descendant(
        of: find.byKey(const Key('summary-room-number-text-101')),
        matching: find.byType(Transform),
      ),
    );
    expect(numberTransform.transform.storage[0], closeTo(1, 0.001));
    expect(numberTransform.transform.storage[5], lessThan(1));
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
