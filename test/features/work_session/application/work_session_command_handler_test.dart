import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/work_session/application/commands/work_session_command.dart';
import 'package:margaritaville_flutter/features/work_session/application/work_session_command_handler.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/hotel_profile.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/housekeeper.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_assignment.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_session.dart';
import 'package:margaritaville_flutter/features/work_session/domain/repositories/work_session_repository.dart';

void main() {
  final now = DateTime.utc(2027, 2, 10, 12);

  test(
    'persists a changed command and keeps ignored commands write-free',
    () async {
      final repository = _RecordingRepository();
      final session = WorkSession.create(
        id: 'session-1',
        hotel: HotelProfile.margaritaville,
        startedAt: now,
        assignments: [
          WorkAssignment.create(
            id: 'cart-1',
            cartNumber: 1,
            housekeeper: Housekeeper(
              id: 'ketty',
              displayName: 'Ketty',
              paletteKey: 'ruby',
              updatedAt: now,
            ),
            assignedAt: now,
          ),
        ],
      );
      final handler = WorkSessionCommandHandler(repository);

      final changed = await handler.execute(
        session,
        AssignRoomCommand(
          commandId: 'command-1',
          issuedAt: now.add(const Duration(minutes: 1)),
          assignmentId: 'cart-1',
          roomNumber: '101',
        ),
      );
      final ignored = await handler.execute(
        changed.session,
        AssignRoomCommand(
          commandId: 'command-2',
          issuedAt: now.add(const Duration(minutes: 2)),
          assignmentId: 'cart-1',
          roomNumber: '101',
        ),
      );

      expect(changed.status.name, 'changed');
      expect(ignored.status.name, 'ignored');
      expect(repository.writeCount, 1);
      expect(repository.session, changed.session);
    },
  );

  test(
    'persists VIP and schedule commands through the same command path',
    () async {
      final repository = _RecordingRepository();
      final assigned =
          WorkSession.create(
                id: 'session-1',
                hotel: HotelProfile.margaritaville,
                startedAt: now,
                assignments: [
                  WorkAssignment.create(
                    id: 'cart-1',
                    cartNumber: 1,
                    housekeeper: Housekeeper(
                      id: 'ketty',
                      displayName: 'Ketty',
                      paletteKey: 'ruby',
                      updatedAt: now,
                    ),
                    assignedAt: now,
                  ),
                ],
              )
              .assignRoom(
                assignmentId: 'cart-1',
                roomNumber: '101',
                changedAt: now.add(const Duration(minutes: 1)),
              )
              .session;
      final handler = WorkSessionCommandHandler(repository);
      final dueAt = now.add(const Duration(hours: 1));

      final vip = await handler.execute(
        assigned,
        SetRoomVipCommand(
          commandId: 'vip-1',
          issuedAt: now.add(const Duration(minutes: 2)),
          roomNumber: '101',
          isVip: true,
        ),
      );
      final scheduled = await handler.execute(
        vip.session,
        SetRoomScheduleCommand(
          commandId: 'schedule-1',
          issuedAt: now.add(const Duration(minutes: 3)),
          roomNumber: '101',
          scheduledFor: dueAt,
        ),
      );
      final duplicateVip = await handler.execute(
        scheduled.session,
        SetRoomVipCommand(
          commandId: 'vip-2',
          issuedAt: now.add(const Duration(minutes: 4)),
          roomNumber: '101',
          isVip: true,
        ),
      );

      expect(scheduled.session.room('101')?.isVip, isTrue);
      expect(scheduled.session.room('101')?.scheduledFor, dueAt);
      expect(duplicateVip.status, WorkSessionMutationStatus.ignored);
      expect(repository.writeCount, 2);
    },
  );
}

final class _RecordingRepository implements WorkSessionRepository {
  WorkSession? session;
  int writeCount = 0;

  @override
  Future<WorkSession?> loadLatestSession() async => session;

  @override
  Future<WorkSession?> loadSession(String sessionId) async => session;

  @override
  Future<void> replaceSession(WorkSession session) async {
    this.session = session;
    writeCount++;
  }

  @override
  Stream<WorkSession?> watchLatestSession() => Stream.value(session);
}
