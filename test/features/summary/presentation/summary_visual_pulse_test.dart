import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/summary/presentation/summary_visual_pulse.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/room_state.dart';

void main() {
  test('status pulse follows donor rise, peak and two-second cooling tail', () {
    expect(SummaryStatusPulseTiming.heat(Duration.zero), 0);
    expect(SummaryStatusPulseTiming.heat(const Duration(milliseconds: 420)), 1);
    expect(SummaryStatusPulseTiming.heat(const Duration(milliseconds: 580)), 1);
    expect(
      SummaryStatusPulseTiming.heat(const Duration(milliseconds: 1580)),
      inInclusiveRange(0.5, 0.8),
    );
    expect(
      SummaryStatusPulseTiming.heat(const Duration(milliseconds: 2580)),
      0,
    );
  });

  testWidgets('pulse coordinator removes only the completed generation', (
    tester,
  ) async {
    final coordinator = SummaryVisualPulseCoordinator(
      cleanupDuration: const Duration(milliseconds: 100),
    );
    addTearDown(coordinator.dispose);
    final startedAt = DateTime.utc(2027, 2, 10, 12);

    coordinator.record(
      roomNumber: '101',
      status: RoomDisplayStatus.open,
      startedAt: startedAt,
    );
    await tester.pump(const Duration(milliseconds: 60));
    coordinator.record(
      roomNumber: '101',
      status: RoomDisplayStatus.ready,
      startedAt: startedAt.add(const Duration(milliseconds: 60)),
    );
    await tester.pump(const Duration(milliseconds: 60));

    expect(coordinator.eventFor('101')?.status, RoomDisplayStatus.ready);

    await tester.pump(const Duration(milliseconds: 50));
    expect(coordinator.eventFor('101'), isNull);
  });
}
