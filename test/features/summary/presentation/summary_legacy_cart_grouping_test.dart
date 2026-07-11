import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/app/margaritaville_theme.dart';
import 'package:margaritaville_flutter/features/summary/presentation/summary_screen.dart';
import 'package:margaritaville_flutter/features/summary/presentation/summary_visual_policy.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/hotel_profile.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/housekeeper.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/room_state.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_assignment.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_session.dart';

void main() {
  testWidgets('legacy carts of one housekeeper render as one summary section', (
    tester,
  ) async {
    final now = DateTime.utc(2027, 2, 10, 12);
    final housekeeper = Housekeeper(
      id: 'ketty',
      displayName: 'Ketty',
      paletteKey: 'ruby',
      updatedAt: now,
    );
    final session = WorkSession.create(
      id: 'session-1',
      hotel: HotelProfile.margaritaville,
      startedAt: now,
      assignments: [
        _assignment('legacy-cart-1', 1, housekeeper, '101', now),
        _assignment('legacy-cart-2', 2, housekeeper, '143', now),
      ],
    ).lockWorkday(changedAt: now);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: MargaritavilleTheme.dark,
          home: SummaryScreen(
            session: session,
            visualPolicy: const SummaryVisualPolicy(
              vipJellyEnabled: false,
              vipHdrLightEnabled: false,
              statusPulseEnabled: false,
              sdrGlowEnabled: false,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('summary-housekeeper-name-ketty')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('summary-room-101')), findsOneWidget);
    expect(find.byKey(const Key('summary-room-143')), findsOneWidget);
    expect(find.text('A1 B1'), findsOneWidget);
  });

  testWidgets('summary sections follow cart number rather than storage order', (
    tester,
  ) async {
    final now = DateTime.utc(2027, 2, 10, 12);
    final session = WorkSession.create(
      id: 'session-2',
      hotel: HotelProfile.margaritaville,
      startedAt: now,
      assignments: [
        _assignment(
          'cart-2',
          2,
          Housekeeper(
            id: 'nadia',
            displayName: 'Nadia',
            paletteKey: 'aqua',
            updatedAt: now,
          ),
          '143',
          now,
        ),
        _assignment(
          'cart-1',
          1,
          Housekeeper(
            id: 'ketty',
            displayName: 'Ketty',
            paletteKey: 'ruby',
            updatedAt: now,
          ),
          '101',
          now,
        ),
      ],
    ).lockWorkday(changedAt: now);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: MargaritavilleTheme.dark,
          home: SummaryScreen(
            session: session,
            visualPolicy: const SummaryVisualPolicy(
              vipJellyEnabled: false,
              vipHdrLightEnabled: false,
              statusPulseEnabled: false,
              sdrGlowEnabled: false,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      tester
          .getTopLeft(find.byKey(const Key('summary-housekeeper-name-ketty')))
          .dy,
      lessThan(
        tester
            .getTopLeft(find.byKey(const Key('summary-housekeeper-name-nadia')))
            .dy,
      ),
    );
  });
}

WorkAssignment _assignment(
  String id,
  int cartNumber,
  Housekeeper housekeeper,
  String roomNumber,
  DateTime now,
) {
  return WorkAssignment(
    id: id,
    cartNumber: cartNumber,
    housekeeper: housekeeper,
    assignedAt: now,
    updatedAt: now,
    rooms: [RoomState.pending(roomNumber: roomNumber, selectedAt: now)],
  );
}
