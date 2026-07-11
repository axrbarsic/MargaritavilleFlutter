import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/app/margaritaville_theme.dart';
import 'package:margaritaville_flutter/features/summary/presentation/summary_visual_policy.dart';
import 'package:margaritaville_flutter/features/summary/presentation/widgets/room_status_tile.dart';
import 'package:margaritaville_flutter/features/summary/presentation/widgets/summary_assignment_section.dart';
import 'package:margaritaville_flutter/features/summary/presentation/widgets/summary_minimum_scale_text.dart';

import 'support/summary_test_fixture.dart';

void main() {
  test('iOS uses the same hidden rounded system family as SwiftUI', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    expect(
      MargaritavilleTheme.dark.textTheme.bodyMedium?.fontFamily,
      '.AppleSystemUIFontRounded',
    );
  });

  testWidgets('room tile uses donor color, type and timestamp contract', (
    tester,
  ) async {
    final selectedAt = DateTime(2027, 2, 10, 20, 47);
    final room = donorRoom('101', selectedAt: selectedAt);

    await tester.pumpWidget(
      MaterialApp(
        theme: MargaritavilleTheme.dark.copyWith(platform: TargetPlatform.iOS),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 96,
              height: 98,
              child: RoomStatusTile(
                room: room,
                onAdvance: () {},
                onReset: () {},
                onToggleVip: () {},
                onSchedule: () {},
                onOpenMedia: () {},
              ),
            ),
          ),
        ),
      ),
    );

    final decorated = tester.widget<DecoratedBox>(
      find.byKey(const Key('summary-room-surface-101')),
    );
    final decoration = decorated.decoration as BoxDecoration;
    expect(decoration.color, const Color(0xFFFFC400));
    expect(decoration.borderRadius, BorderRadius.circular(16));

    final number = tester.widget<SummaryMinimumScaleText>(
      find.byKey(const Key('summary-room-number-text-101')),
    );
    expect(number.style.fontSize, 44);
    expect(number.style.fontWeight, FontWeight.w900);
    expect(number.minimumScaleFactor, 0.5);

    final timestamp = tester.widget<SummaryMinimumScaleText>(
      find.byKey(const Key('summary-room-time-text-101')),
    );
    expect(timestamp.style.fontSize, 16);
    expect(timestamp.style.fontWeight, FontWeight.w900);
    expect(timestamp.minimumScaleFactor, 0.62);
  });

  testWidgets('ordinary palette remains an explicit donor setting', (
    tester,
  ) async {
    final selectedAt = DateTime(2027, 2, 10, 20, 47);

    await tester.pumpWidget(
      MaterialApp(
        theme: MargaritavilleTheme.dark,
        home: Center(
          child: SizedBox(
            width: 96,
            height: 98,
            child: RoomStatusTile(
              room: donorRoom('101', selectedAt: selectedAt),
              visualPolicy: const SummaryVisualPolicy(
                vividStatusPaletteEnabled: false,
              ),
              onAdvance: () {},
              onReset: () {},
              onToggleVip: () {},
              onSchedule: () {},
              onOpenMedia: () {},
            ),
          ),
        ),
      ),
    );

    final surface = tester.widget<DecoratedBox>(
      find.byKey(const Key('summary-room-surface-101')),
    );
    expect(
      (surface.decoration as BoxDecoration).color,
      const Color(0xFFFFD83D),
    );
  });

  testWidgets('iOS four-column section restores the donor cell geometry', (
    tester,
  ) async {
    final assignment = donorAssignment();

    await tester.pumpWidget(
      MaterialApp(
        theme: MargaritavilleTheme.dark.copyWith(platform: TargetPlatform.iOS),
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 424,
              child: SummaryAssignmentSection(
                assignment: assignment,
                onAdvance: (_) {},
                onReset: (_) {},
                onToggleVip: (_) {},
                onSchedule: (_) {},
                onOpenMedia: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    final firstTile = find.byKey(const Key('summary-room-101'));
    final firstSurface = find.byKey(const Key('summary-room-surface-101'));
    final secondTile = find.byKey(const Key('summary-room-102'));
    final fifthTile = find.byKey(const Key('summary-room-105'));
    expect(tester.getSize(firstTile).width, closeTo(96, 0.01));
    expect(tester.getSize(firstTile).height, 98);
    expect(tester.getSize(firstSurface), const Size(96, 98));
    final number = tester.widget<SummaryMinimumScaleText>(
      find.byKey(const Key('summary-room-number-text-101')),
    );
    final time = tester.widget<SummaryMinimumScaleText>(
      find.byKey(const Key('summary-room-time-text-101')),
    );
    expect(number.style.fontSize, 44);
    expect(time.style.fontSize, 16);
    expect(number.compressHeightOnly, isFalse);
    expect(time.compressHeightOnly, isFalse);
    expect(
      tester.getTopLeft(secondTile).dx - tester.getTopRight(firstTile).dx,
      closeTo(8, 0.01),
    );
    expect(
      tester.getTopLeft(fifthTile).dy - tester.getBottomLeft(firstTile).dy,
      closeTo(8, 0.01),
    );
    expect(find.text('A1 B1'), findsOneWidget);

    final name = tester.widget<Text>(find.text('Ketty'));
    expect(name.style?.fontSize, 25);
    expect(name.style?.fontWeight, FontWeight.w900);
    expect(name.style?.color, const Color(0xFFF02E5C));

    final nameBadge = tester.widget<DecoratedBox>(
      find.byKey(const Key('summary-housekeeper-name-ketty')),
    );
    final badgeDecoration = nameBadge.decoration as BoxDecoration;
    final nameScaler = tester.widget<SummaryMinimumScaleText>(
      find.descendant(
        of: find.byKey(const Key('summary-housekeeper-name-ketty')),
        matching: find.byType(SummaryMinimumScaleText),
      ),
    );
    final badgePadding = tester.widget<Padding>(
      find.descendant(
        of: find.byKey(const Key('summary-housekeeper-name-ketty')),
        matching: find.byType(Padding),
      ),
    );
    expect(
      badgePadding.padding,
      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
    expect(badgeDecoration.border?.top.width, 1.5);
    expect(
      badgeDecoration.border?.top.strokeAlign,
      BorderSide.strokeAlignCenter,
    );
    expect(badgeDecoration.borderRadius, BorderRadius.circular(999));
    expect(nameScaler.minimumScaleFactor, 0.62);
    expect(nameScaler.shrinkWrap, isTrue);
    expect(name.style?.shadows?.single.blurRadius, 1.6);
    expect(name.style?.shadows?.single.offset, const Offset(0, 1));
  });

  testWidgets('housekeeper badge preserves the full donor name and end inset', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: MargaritavilleTheme.dark,
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 424,
              child: SummaryAssignmentSection(
                assignment: donorAssignment(housekeeperName: 'Omelene PM'),
                onAdvance: (_) {},
                onReset: (_) {},
                onToggleVip: (_) {},
                onSchedule: (_) {},
                onOpenMedia: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    final badge = find.byKey(const Key('summary-housekeeper-name-ketty'));
    final label = find.text('Omelene PM');
    final badgeRect = tester.getRect(badge);
    final labelRect = tester.getRect(label);
    final labelWidget = tester.widget<Text>(label);
    expect(tester.takeException(), isNull);
    expect(labelWidget.overflow, TextOverflow.clip);
    expect(badgeRect.width, closeTo(labelRect.width + 24, 0.01));
    expect(labelRect.left - badgeRect.left, closeTo(12, 0.75));
    expect(badgeRect.right - labelRect.right, closeTo(12, 0.75));
  });

  testWidgets(
    'Pixel width preserves donor tile, spacing, badge and type proportions',
    (tester) async {
      const sectionWidth = 329.6;
      await tester.pumpWidget(
        MaterialApp(
          theme: MargaritavilleTheme.dark.copyWith(
            platform: TargetPlatform.android,
          ),
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(1.15)),
              child: SingleChildScrollView(
                child: SizedBox(
                  width: sectionWidth,
                  child: SummaryAssignmentSection(
                    assignment: donorAssignment(),
                    onAdvance: (_) {},
                    onReset: (_) {},
                    onToggleVip: (_) {},
                    onSchedule: (_) {},
                    onOpenMedia: (_) {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      final firstTile = find.byKey(const Key('summary-room-101'));
      final firstSurface = find.byKey(const Key('summary-room-surface-101'));
      final secondTile = find.byKey(const Key('summary-room-102'));
      final fifthTile = find.byKey(const Key('summary-room-105'));
      expect(tester.getSize(firstTile).width, closeTo(72.4, 0.01));
      expect(tester.getSize(firstTile).height, closeTo(72.4, 0.01));
      expect(tester.getSize(firstSurface).width, closeTo(72.4, 0.01));
      expect(tester.getSize(firstSurface).height, closeTo(72.4, 0.01));
      expect(
        tester.getTopLeft(secondTile).dx - tester.getTopRight(firstTile).dx,
        closeTo(8, 0.01),
      );
      expect(
        tester.getTopLeft(fifthTile).dy - tester.getBottomLeft(firstTile).dy,
        closeTo(8, 0.01),
      );
      final name = tester.widget<Text>(find.text('Ketty'));
      expect(name.style?.fontSize, 25);
      final nameBadge = tester.widget<DecoratedBox>(
        find.byKey(const Key('summary-housekeeper-name-ketty')),
      );
      final badgeDecoration = nameBadge.decoration as BoxDecoration;
      final badgePadding = tester.widget<Padding>(
        find.descendant(
          of: find.byKey(const Key('summary-housekeeper-name-ketty')),
          matching: find.byType(Padding),
        ),
      );
      expect(
        badgePadding.padding,
        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      );
      expect(badgeDecoration.border?.top.width, 1.5);
    },
  );
}
