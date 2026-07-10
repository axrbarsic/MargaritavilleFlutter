import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/time/clock.dart';
import '../../application/commands/work_session_command.dart';
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

final workSessionControllerProvider =
    AsyncNotifierProvider<WorkSessionController, WorkSession>(
      WorkSessionController.new,
    );

final class WorkSessionController extends AsyncNotifier<WorkSession> {
  var _commandSequence = 0;

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

  Future<WorkSessionMutationStatus> advanceRoom(String roomNumber) {
    return _execute(
      AdvanceRoomCommand(
        commandId: _commandId(),
        issuedAt: _nextTimestamp(),
        roomNumber: roomNumber,
      ),
    );
  }

  Future<WorkSessionMutationStatus> resetRoom(String roomNumber) {
    return _execute(
      ResetRoomCommand(
        commandId: _commandId(),
        issuedAt: _nextTimestamp(),
        roomNumber: roomNumber,
      ),
    );
  }

  Future<WorkSessionMutationStatus> _execute(WorkSessionCommand command) async {
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
