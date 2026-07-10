import '../domain/models/work_session.dart';
import '../domain/repositories/work_session_repository.dart';
import 'commands/work_session_command.dart';

final class WorkSessionCommandHandler {
  const WorkSessionCommandHandler(this._repository);

  final WorkSessionRepository _repository;

  Future<WorkSessionMutation> execute(
    WorkSession session,
    WorkSessionCommand command,
  ) async {
    final result = switch (command) {
      final AssignRoomCommand command => session.assignRoom(
        assignmentId: command.assignmentId,
        roomNumber: command.roomNumber,
        changedAt: command.issuedAt,
      ),
      final UnassignRoomCommand command => session.unassignRoom(
        assignmentId: command.assignmentId,
        roomNumber: command.roomNumber,
        changedAt: command.issuedAt,
      ),
      final LockWorkdayCommand command => _asMutation(
        session,
        session.lockWorkday(changedAt: command.issuedAt),
      ),
      final UnlockWorkdayCommand command => _asMutation(
        session,
        session.unlockWorkday(changedAt: command.issuedAt),
      ),
      final AdvanceRoomCommand command => session.advanceRoom(
        roomNumber: command.roomNumber,
        changedAt: command.issuedAt,
      ),
      final ResetRoomCommand command => session.resetRoom(
        roomNumber: command.roomNumber,
        changedAt: command.issuedAt,
      ),
    };
    if (result.status == WorkSessionMutationStatus.changed) {
      await _repository.replaceSession(result.session);
    }
    return result;
  }

  WorkSessionMutation _asMutation(WorkSession previous, WorkSession next) {
    return WorkSessionMutation(
      session: next,
      status: next == previous
          ? WorkSessionMutationStatus.ignored
          : WorkSessionMutationStatus.changed,
    );
  }
}
