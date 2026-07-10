import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/core/time/clock.dart';
import 'package:margaritaville_flutter/features/work_session/application/ports/room_schedule_notification_client.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/hotel_profile.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/housekeeper.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_assignment.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_session.dart';
import 'package:margaritaville_flutter/features/work_session/domain/repositories/work_session_repository.dart';
import 'package:margaritaville_flutter/features/work_session/presentation/controllers/work_session_controller.dart';

void main() {
  test(
    'schedule, due transition and reset coordinate notification cleanup',
    () async {
      final now = DateTime.utc(2027, 2, 10, 12);
      final repository = _MemoryRepository(_session(now));
      final notifications = _RecordingNotificationClient();
      final container = ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(FixedClock(now)),
          workSessionRepositoryProvider.overrideWithValue(repository),
          roomScheduleNotificationClientProvider.overrideWithValue(
            notifications,
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(workSessionControllerProvider.future);
      final controller = container.read(workSessionControllerProvider.notifier);
      final futureDueAt = now.add(const Duration(hours: 1));

      await controller.setRoomSchedule('101', scheduledFor: futureDueAt);

      expect(notifications.scheduled, [('101', futureDueAt)]);
      expect(repository.session.room('101')?.scheduledFor, futureDueAt);

      await controller.resetRoom('101');

      expect(notifications.cancelled, ['101']);
      expect(repository.session.room('101')?.scheduledFor, isNull);

      final dueAt = now.subtract(const Duration(minutes: 1));
      await controller.setRoomSchedule('101', scheduledFor: dueAt);

      expect(repository.session.room('101')?.phase.name, 'open');
      expect(repository.session.room('101')?.scheduledFor, isNull);
      expect(notifications.scheduled, [('101', futureDueAt)]);
      expect(notifications.cancelled, ['101', '101']);
    },
  );

  test(
    'concurrent room commands are serialized without lost updates',
    () async {
      final now = DateTime.utc(2027, 2, 10, 12);
      final repository = _MemoryRepository(
        _session(now),
        writeDelay: const Duration(milliseconds: 20),
      );
      final container = ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(FixedClock(now)),
          workSessionRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      await container.read(workSessionControllerProvider.future);
      final controller = container.read(workSessionControllerProvider.notifier);

      await Future.wait([
        controller.advanceRoom('101'),
        controller.advanceRoom('101'),
      ]);

      expect(repository.session.room('101')?.phase.name, 'ready');
      expect(
        container.read(workSessionControllerProvider).requireValue,
        repository.session,
      );
    },
  );
}

WorkSession _session(DateTime now) {
  final assignment = WorkAssignment.create(
    id: 'cart-1',
    cartNumber: 1,
    housekeeper: Housekeeper(
      id: 'ketty',
      displayName: 'Ketty',
      paletteKey: 'ruby',
      updatedAt: now,
    ),
    assignedAt: now,
  );
  return WorkSession.create(
        id: 'session-1',
        hotel: HotelProfile.margaritaville,
        startedAt: now,
        assignments: [assignment],
      )
      .assignRoom(assignmentId: 'cart-1', roomNumber: '101', changedAt: now)
      .session
      .lockWorkday(changedAt: now);
}

final class _MemoryRepository implements WorkSessionRepository {
  _MemoryRepository(this.session, {this.writeDelay = Duration.zero});

  WorkSession session;
  final Duration writeDelay;

  @override
  Future<WorkSession?> loadLatestSession() async => session;

  @override
  Future<WorkSession?> loadSession(String sessionId) async => session;

  @override
  Future<void> replaceSession(WorkSession session) async {
    if (writeDelay > Duration.zero) await Future<void>.delayed(writeDelay);
    this.session = session;
  }

  @override
  Stream<WorkSession?> watchLatestSession() => Stream.value(session);
}

final class _RecordingNotificationClient
    implements RoomScheduleNotificationClient {
  final scheduled = <(String, DateTime)>[];
  final cancelled = <String>[];

  @override
  Future<void> cancelRoom(String roomNumber) async {
    cancelled.add(roomNumber);
  }

  @override
  Future<void> scheduleRoom({
    required String roomNumber,
    required DateTime dueAt,
  }) async {
    scheduled.add((roomNumber, dueAt));
  }
}
