import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/app/margaritaville_theme.dart';
import 'package:margaritaville_flutter/features/room_details/presentation/room_details_screen.dart';
import 'package:margaritaville_flutter/shared/persistence/app_database_provider.dart';

void main() {
  testWidgets('voice media shell keeps Swift build 37 geometry', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(440, 956);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final database = AppDatabase.inMemory();
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          theme: MargaritavilleTheme.dark,
          home: const RoomDetailsScreen(
            sessionId: 'session-1',
            roomNumber: '101',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byKey(const Key('room-details-back'))),
      const Size(48, 48),
    );
    final roomNumber = tester.widget<Text>(
      find.byKey(const Key('room-details-room-number')),
    );
    final title = tester.widget<Text>(
      find.byKey(const Key('room-details-title')),
    );
    expect(roomNumber.style?.fontSize, 44);
    expect(roomNumber.style?.fontWeight, FontWeight.w900);
    expect(title.style?.fontSize, 34);
    expect(title.style?.fontWeight, FontWeight.w900);

    final cardLeft = tester
        .getTopLeft(find.byKey(const Key('room-details-card')))
        .dx;
    expect(cardLeft, 18);
    expect(
      tester.getSize(find.byKey(const Key('room-details-photo'))).height,
      86,
    );
    expect(
      tester.getSize(find.byKey(const Key('room-details-video'))).height,
      86,
    );
  });
}
