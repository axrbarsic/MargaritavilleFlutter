import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/app/margaritaville_theme.dart';
import 'package:margaritaville_flutter/features/summary/presentation/summary_screen.dart';
import 'package:margaritaville_flutter/features/summary/presentation/widgets/room_status_tile.dart';
import 'package:margaritaville_flutter/features/summary/presentation/widgets/summary_assignment_section.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/hotel_profile.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/housekeeper.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/room_state.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/room_timestamps.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_assignment.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_session.dart';

void main() {
  testWidgets('room tile uses donor color, type and timestamp contract', (
    tester,
  ) async {
    final selectedAt = DateTime(2027, 2, 10, 20, 47);
    final room = _room('101', selectedAt: selectedAt);

    await tester.pumpWidget(
      MaterialApp(
        theme: MargaritavilleTheme.dark,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 96,
              height: 98,
              child: RoomStatusTile(
                room: room,
                onAdvance: () {},
                onReset: () {},
              ),
            ),
          ),
        ),
      ),
    );

    final tile = find.byKey(const Key('summary-room-101'));
    final decorated = tester.widget<DecoratedBox>(
      find.descendant(of: tile, matching: find.byType(DecoratedBox)).first,
    );
    final decoration = decorated.decoration as BoxDecoration;
    expect(decoration.color, const Color(0xFFFFD83D));
    expect(decoration.borderRadius, BorderRadius.circular(16));

    final number = tester.widget<Text>(find.text('101'));
    expect(number.style?.fontSize, 44);
    expect(number.style?.fontWeight, FontWeight.w900);

    final timestamp = tester.widget<Text>(find.text('8:47 PM'));
    expect(timestamp.style?.fontSize, 16);
    expect(timestamp.style?.fontWeight, FontWeight.w900);
  });

  testWidgets('assignment section keeps donor four-column geometry', (
    tester,
  ) async {
    final assignment = _assignment();

    await tester.pumpWidget(
      MaterialApp(
        theme: MargaritavilleTheme.dark,
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 424,
              child: SummaryAssignmentSection(
                assignment: assignment,
                onAdvance: (_) {},
                onReset: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    final firstTile = find.byKey(const Key('summary-room-101'));
    expect(tester.getSize(firstTile).width, closeTo(96, 0.01));
    expect(tester.getSize(firstTile).height, 98);
    expect(find.text('A1 B1'), findsOneWidget);

    final name = tester.widget<Text>(find.text('Ketty'));
    expect(name.style?.fontSize, 25);
    expect(name.style?.fontWeight, FontWeight.w900);
    expect(name.style?.color, const Color(0xFFF02E5C));
  });

  testWidgets('summary replaces Material app bar with donor header', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(440, 956);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: MargaritavilleTheme.dark,
          home: SummaryScreen(session: _session()),
        ),
      ),
    );

    final header = find.byKey(const Key('summary-header'));
    expect(header, findsOneWidget);
    expect(tester.getSize(header).height, 48);
    expect(find.text('Текущая смена'), findsNothing);
    expect(find.byKey(const Key('summary-filter-open')), findsOneWidget);
    expect(find.byKey(const Key('summary-filter-ready')), findsOneWidget);
    expect(find.byKey(const Key('summary-filter-scheduled')), findsOneWidget);
    expect(find.byKey(const Key('summary-filter-pending')), findsOneWidget);
  });

  testWidgets('summary stays intact at physical Pixel width and font scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(346, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: MargaritavilleTheme.dark,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.15)),
            child: child!,
          ),
          home: SummaryScreen(session: _session()),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byKey(const Key('summary-header'))).height, 48);
    expect(find.byKey(const Key('summary-filter-pending')), findsOneWidget);
    expect(find.byKey(const Key('summary-room-101')), findsOneWidget);
  });
}

WorkSession _session() {
  final startedAt = DateTime(2027, 2, 10, 20, 47);
  return WorkSession.create(
    id: 'donor-summary-fixture',
    hotel: HotelProfile.margaritaville,
    startedAt: startedAt,
    assignments: [_assignment()],
  ).lockWorkday(changedAt: startedAt.add(const Duration(minutes: 1)));
}

WorkAssignment _assignment() {
  final selectedAt = DateTime(2027, 2, 10, 20, 47);
  return WorkAssignment(
    id: 'work-block-1',
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
      for (final number in ['101', '102', '103', '104', '105', '106', '107'])
        _room(number, selectedAt: selectedAt),
      _room('143', selectedAt: selectedAt),
    ],
  );
}

RoomState _room(String roomNumber, {required DateTime selectedAt}) {
  return RoomState(
    roomNumber: roomNumber,
    phase: RoomPhase.pending,
    isVip: false,
    timestamps: RoomTimestamps(
      selectedAt: selectedAt,
      phaseUpdatedAt: selectedAt,
    ),
  );
}
