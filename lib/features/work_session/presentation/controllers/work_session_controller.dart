import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/time/clock.dart';
import '../../application/all_rooms_test_data_generator.dart';
import '../../application/commands/work_session_command.dart';
import '../../application/ports/room_schedule_notification_client.dart';
import '../../application/work_session_command_handler.dart';
import '../../application/work_session_seed.dart';
import '../../data/local/app_database.dart';
import '../../data/repositories/drift_work_session_repository.dart';
import '../../domain/models/work_session.dart';
import '../../domain/repositories/work_session_repository.dart';

final clockProvider = Provider<Clock>((ref) => const SystemClock());

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(() {
    database.close();
  });
  return database;
});

final workSessionRepositoryProvider = Provider<WorkSessionRepository>((ref) {
  return DriftWorkSessionRepository(ref.watch(appDatabaseProvider));
});

final roomScheduleNotificationClientProvider =
    Provider<RoomScheduleNotificationClient>((ref) {
      return const NoopRoomScheduleNotificationClient();
    });

final workSessionControllerProvider =
    AsyncNotifierProvider<WorkSessionController, WorkSession>(
      WorkSessionController.new,
    );

final class WorkSessionController extends AsyncNotifier<WorkSession> {
  var _commandSequence = 0;
  Future<void> _commandTail = Future<void>.value();

  @override
  Future<WorkSession> build() async {
    final repository = ref.watch(workSessionRepositoryProvider);
    final existing = await repository.loadLatestSession();
    if (existing != null) return existing;

    final initial = makeInitialWorkSession(ref.watch(clockProvider).now());
    await repository.replaceSession(initial);
    return initial;
  }

  Future<WorkSessionMutationStatus> toggleRoomSelection({
    required String assignmentId,
    required String roomNumber,
  }) async {
    final current = state.requireValue;
    final assignment = current.assignment(assignmentId);
    final isSelected = assignment?.room(roomNumber) != null;
    final issuedAt = _nextTimestamp();
    final command = isSelected
        ? UnassignRoomCommand(
            commandId: _commandId(),
            issuedAt: issuedAt,
            assignmentId: assignmentId,
            roomNumber: roomNumber,
          )
        : AssignRoomCommand(
            commandId: _commandId(),
            issuedAt: issuedAt,
            assignmentId: assignmentId,
            roomNumber: roomNumber,
          );
    return _execute(command);
  }

  Future<WorkSessionMutationStatus> lockWorkday() {
    return _execute(
      LockWorkdayCommand(commandId: _commandId(), issuedAt: _nextTimestamp()),
    );
  }

  Future<WorkSessionMutationStatus> unlockWorkday() {
    return _execute(
      UnlockWorkdayCommand(commandId: _commandId(), issuedAt: _nextTimestamp()),
    );
  }

  Future<WorkSessionMutationStatus> activateAllRoomsForTesting({
    Random? random,
  }) {
    final roomNumbers = const AllRoomsTestDataGenerator().shuffledRoomNumbers(
      random ?? Random(),
    );
    return _execute(
      ReplaceAllRoomAssignmentsCommand(
        commandId: _commandId(),
        issuedAt: _nextTimestamp(),
        roomNumbers: roomNumbers,
      ),
    );
  }

  Future<WorkSessionMutationStatus> advanceRoom(String roomNumber) {
    return _execute(
      AdvanceRoomCommand(
        commandId: _commandId(),
        issuedAt: _nextTimestamp(),
        roomNumber: roomNumber,
      ),
    );
  }

  Future<WorkSessionMutationStatus> resetRoom(String roomNumber) async {
    final hadSchedule =
        state.requireValue.room(roomNumber)?.scheduledFor != null;
    final result = await _execute(
      ResetRoomCommand(
        commandId: _commandId(),
        issuedAt: _nextTimestamp(),
        roomNumber: roomNumber,
      ),
    );
    if (hadSchedule && result == WorkSessionMutationStatus.changed) {
      await ref
          .read(roomScheduleNotificationClientProvider)
          .cancelRoom(roomNumber);
    }
    return result;
  }

  Future<WorkSessionMutationStatus> setRoomVip(
    String roomNumber, {
    required bool isVip,
  }) {
    return _execute(
      SetRoomVipCommand(
        commandId: _commandId(),
        issuedAt: _nextTimestamp(),
        roomNumber: roomNumber,
        isVip: isVip,
      ),
    );
  }

  Future<WorkSessionMutationStatus> setRoomSchedule(
    String roomNumber, {
    required DateTime? scheduledFor,
  }) async {
    final issuedAt = _nextTimestamp();
    final result = await _execute(
      SetRoomScheduleCommand(
        commandId: _commandId(),
        issuedAt: issuedAt,
        roomNumber: roomNumber,
        scheduledFor: scheduledFor,
      ),
    );
    if (result != WorkSessionMutationStatus.changed) return result;

    final notifications = ref.read(roomScheduleNotificationClientProvider);
    if (scheduledFor == null) {
      await notifications.cancelRoom(roomNumber);
    } else if (!scheduledFor.isAfter(issuedAt)) {
      await advanceScheduledRooms();
    } else {
      await notifications.scheduleRoom(
        roomNumber: roomNumber,
        dueAt: scheduledFor,
      );
    }
    return result;
  }

  Future<WorkSessionMutationStatus> advanceScheduledRooms() async {
    final issuedAt = _nextTimestamp();
    final dueRoomNumbers = state.requireValue.activeRooms
        .where((room) {
          final dueAt = room.scheduledFor;
          return dueAt != null && !dueAt.isAfter(issuedAt);
        })
        .map((room) => room.roomNumber)
        .toList(growable: false);
    final result = await _execute(
      AdvanceScheduledRoomsCommand(commandId: _commandId(), issuedAt: issuedAt),
    );
    if (result == WorkSessionMutationStatus.changed) {
      final notifications = ref.read(roomScheduleNotificationClientProvider);
      await Future.wait(dueRoomNumbers.map(notifications.cancelRoom));
    }
    return result;
  }

  Future<WorkSessionMutationStatus> _execute(WorkSessionCommand command) {
    final completer = Completer<WorkSessionMutationStatus>();
    _commandTail = _commandTail.then((_) async {
      try {
        completer.complete(await _executeNow(command));
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }

  Future<WorkSessionMutationStatus> _executeNow(
    WorkSessionCommand command,
  ) async {
    final current = state.requireValue;
    final handler = WorkSessionCommandHandler(
      ref.read(workSessionRepositoryProvider),
    );
    try {
      final result = await handler.execute(current, command);
      if (result.status == WorkSessionMutationStatus.changed) {
        state = AsyncData(result.session);
      }
      return result.status;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  DateTime _nextTimestamp() {
    _commandSequence++;
    return ref
        .read(clockProvider)
        .now()
        .add(Duration(microseconds: _commandSequence));
  }

  String _commandId() {
    return 'local-${ref.read(clockProvider).now().microsecondsSinceEpoch}-'
        '$_commandSequence';
  }
}
