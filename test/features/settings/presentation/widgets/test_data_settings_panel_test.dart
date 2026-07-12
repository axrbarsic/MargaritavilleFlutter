import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/app/margaritaville_theme.dart';
import 'package:margaritaville_flutter/features/settings/presentation/widgets/test_data_settings_panel.dart';
import '../../../../support/test_feedback_scope.dart';

void main() {
  testWidgets('cancel keeps current assignments untouched', (tester) async {
    var activationCount = 0;
    await tester.pumpWidget(
      _app(
        onActivateAllRooms: () async {
          activationCount++;
        },
      ),
    );

    await tester.tap(find.byKey(const Key('settings-use-all-hotel-rooms')));
    await tester.pumpAndSettle();

    expect(find.text('Заменить текущие назначения?'), findsOneWidget);
    expect(
      find.textContaining('Уже существующие статусы, VIP и расписание'),
      findsOneWidget,
    );
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();

    expect(activationCount, 0);
  });

  testWidgets('confirmation invokes the application callback once', (
    tester,
  ) async {
    var activationCount = 0;
    await tester.pumpWidget(
      _app(
        onActivateAllRooms: () async {
          activationCount++;
        },
      ),
    );

    await tester.tap(find.byKey(const Key('settings-use-all-hotel-rooms')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Заменить и перемешать'));
    await tester.pumpAndSettle();

    expect(activationCount, 1);
  });
}

Widget _app({required Future<void> Function() onActivateAllRooms}) {
  return ProviderScope(
    child: TestFeedbackScope(
      child: MaterialApp(
        theme: MargaritavilleTheme.dark,
        home: Scaffold(
          body: TestDataSettingsPanel(onActivateAllRooms: onActivateAllRooms),
        ),
      ),
    ),
  );
}
