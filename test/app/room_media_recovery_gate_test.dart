import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/app/room_media_recovery_gate.dart';
import 'package:margaritaville_flutter/features/room_details/application/media/room_media_promotion_recovery.dart';
import 'package:margaritaville_flutter/features/room_details/presentation/controllers/room_photo_capture_controller.dart';

void main() {
  testWidgets('room content stays hidden until startup recovery completes', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(recovery: const AsyncLoading<void>(), onRetry: () {}),
    );

    expect(find.byKey(RoomMediaRecoveryGate.loadingKey), findsOneWidget);
    expect(find.text('Содержимое комнат'), findsNothing);

    await tester.pumpWidget(
      _app(recovery: const AsyncData<void>(null), onRetry: () {}),
    );

    expect(find.text('Содержимое комнат'), findsOneWidget);
  });

  testWidgets('failed recovery exposes an explicit retry', (tester) async {
    var retries = 0;
    await tester.pumpWidget(
      _app(
        recovery: AsyncError<void>(
          StateError('broken journal'),
          StackTrace.empty,
        ),
        onRetry: () => retries += 1,
      ),
    );

    expect(find.byKey(RoomMediaRecoveryGate.errorKey), findsOneWidget);
    expect(find.text('Содержимое комнат'), findsNothing);
    await tester.tap(find.byKey(RoomMediaRecoveryGate.retryKey));
    expect(retries, 1);
  });

  testWidgets('retry invalidates the real provider from error to data', (
    tester,
  ) async {
    var attempts = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          roomMediaRecoveryProvider.overrideWith((ref) async {
            attempts += 1;
            if (attempts == 1) throw StateError('transient database error');
            return const RoomMediaPromotionRecoveryReport(
              recovered: 1,
              quarantined: 0,
            );
          }),
        ],
        child: Consumer(
          builder: (context, ref, _) => MaterialApp(
            home: RoomMediaRecoveryGate(
              recovery: ref.watch(roomMediaRecoveryProvider),
              onRetry: () => ref.invalidate(roomMediaRecoveryProvider),
              child: const Text('Содержимое комнат'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(RoomMediaRecoveryGate.errorKey), findsOneWidget);

    await tester.tap(find.byKey(RoomMediaRecoveryGate.retryKey));
    await tester.pumpAndSettle();

    expect(attempts, 2);
    expect(find.text('Содержимое комнат'), findsOneWidget);
  });
}

Widget _app({
  required AsyncValue<void> recovery,
  required VoidCallback onRetry,
}) => MaterialApp(
  home: RoomMediaRecoveryGate(
    recovery: recovery,
    onRetry: onRetry,
    child: const Text('Содержимое комнат'),
  ),
);
