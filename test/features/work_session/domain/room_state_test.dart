import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/room_state.dart';

void main() {
  final selectedAt = DateTime.utc(2027, 2, 10, 12);
  final openedAt = DateTime.utc(2027, 2, 10, 12, 5);
  final completedAt = DateTime.utc(2027, 2, 10, 12, 30);

  group('Margaritaville simple-cycle', () {
    test('advances pending -> open -> ready and keeps ready terminal', () {
      final pending = RoomState.pending(
        roomNumber: '101',
        selectedAt: selectedAt,
      );

      final opened = pending.advanceSimpleCycle(changedAt: openedAt);
      expect(opened.outcome, RoomTransitionOutcome.changed);
      expect(opened.room.phase, RoomPhase.open);
      expect(opened.room.displayStatus, RoomDisplayStatus.open);
      expect(opened.room.timestamps.openedAt, openedAt);
      expect(opened.room.timestamps.phaseUpdatedAt, openedAt);

      final ready = opened.room.advanceSimpleCycle(changedAt: completedAt);
      expect(ready.outcome, RoomTransitionOutcome.changed);
      expect(ready.room.phase, RoomPhase.ready);
      expect(ready.room.timestamps.completedAt, completedAt);
      expect(ready.room.timestamps.phaseUpdatedAt, completedAt);

      final terminal = ready.room.advanceSimpleCycle(
        changedAt: completedAt.add(const Duration(minutes: 1)),
      );
      expect(terminal.outcome, RoomTransitionOutcome.ignored);
      expect(terminal.room, ready.room);
    });

    test('explicit reset preserves first-happened milestones', () {
      final ready = RoomState.pending(roomNumber: '101', selectedAt: selectedAt)
          .advanceSimpleCycle(changedAt: openedAt)
          .room
          .advanceSimpleCycle(changedAt: completedAt)
          .room;
      final resetAt = completedAt.add(const Duration(minutes: 2));

      final reset = ready.resetSimpleCycle(changedAt: resetAt);

      expect(reset.outcome, RoomTransitionOutcome.changed);
      expect(reset.room.phase, RoomPhase.pending);
      expect(reset.room.timestamps.phaseUpdatedAt, resetAt);
      expect(reset.room.timestamps.openedAt, openedAt);
      expect(reset.room.timestamps.completedAt, completedAt);
    });

    test('scheduled is an overlay and a due pending room becomes open', () {
      final pending = RoomState.pending(
        roomNumber: '101',
        selectedAt: selectedAt,
      );
      final scheduledFor = openedAt.add(const Duration(minutes: 15));
      final scheduled = pending.schedule(
        scheduledFor: scheduledFor,
        changedAt: openedAt,
      );

      expect(scheduled.phase, RoomPhase.pending);
      expect(scheduled.displayStatus, RoomDisplayStatus.scheduled);
      expect(
        scheduled
            .advanceScheduledIfDue(
              now: scheduledFor.subtract(const Duration(seconds: 1)),
            )
            .outcome,
        RoomTransitionOutcome.ignored,
      );

      final due = scheduled.advanceScheduledIfDue(now: scheduledFor);
      expect(due.outcome, RoomTransitionOutcome.changed);
      expect(due.room.phase, RoomPhase.open);
      expect(due.room.scheduledFor, isNull);
      expect(due.room.timestamps.openedAt, scheduledFor);
      expect(due.room.timestamps.scheduledUpdatedAt, scheduledFor);
    });

    test('due schedule over ready only clears the overlay', () {
      final ready = RoomState.pending(roomNumber: '101', selectedAt: selectedAt)
          .advanceSimpleCycle(changedAt: openedAt)
          .room
          .advanceSimpleCycle(changedAt: completedAt)
          .room;
      final dueAt = completedAt.add(const Duration(minutes: 10));
      final scheduled = ready.schedule(
        scheduledFor: dueAt,
        changedAt: completedAt.add(const Duration(minutes: 1)),
      );

      final due = scheduled.advanceScheduledIfDue(now: dueAt);

      expect(due.outcome, RoomTransitionOutcome.changed);
      expect(due.room.phase, RoomPhase.ready);
      expect(due.room.timestamps.phaseUpdatedAt, completedAt);
      expect(due.room.timestamps.scheduledUpdatedAt, dueAt);
    });

    test('VIP is independent from phase and has its own field timestamp', () {
      final pending = RoomState.pending(
        roomNumber: '101',
        selectedAt: selectedAt,
      );

      final vip = pending.setVip(isVip: true, changedAt: openedAt);

      expect(vip.phase, RoomPhase.pending);
      expect(vip.isVip, isTrue);
      expect(vip.timestamps.vipUpdatedAt, openedAt);
    });
  });
}
