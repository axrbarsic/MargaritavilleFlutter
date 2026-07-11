import '../domain/models/work_session.dart';
import '../domain/repositories/work_session_repository.dart';
import 'commands/work_session_command.dart';
import 'commands/work_session_command_descriptor.dart';

final class WorkSessionCommandHandler {
  const WorkSessionCommandHandler(this._repository);

  final WorkSessionRepository _repository;

  Future<WorkSessionMutation> execute(
    WorkSession session,
    WorkSessionCommand command,
  ) {
    return _repository.commitCommand(
      fallbackSession: session,
      descriptor: command.toDescriptor(),
      mutate: (authoritative) => _apply(authoritative, command),
    );
  }

  WorkSessionMutation _apply(WorkSession session, WorkSessionCommand command) {
    return switch (command) {
      final ToggleHousekeeperWorkItemCommand command =>
        session.toggleHousekeeperWorkItem(
          housekeeperId: command.housekeeperId,
          displayName: command.displayName,
          paletteKey: command.paletteKey,
          changedAt: command.issuedAt,
        ),
      final SetAssignmentTerritoryCommand command =>
        session.setAssignmentTerritory(
          assignmentId: command.assignmentId,
          territoryId: command.territoryId,
          changedAt: command.issuedAt,
        ),
      final ToggleRoomSelectionCommand command => session.toggleRoomSelection(
        assignmentId: command.assignmentId,
        roomNumber: command.roomNumber,
        changedAt: command.issuedAt,
      ),
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
      final ReplaceAllRoomAssignmentsCommand command =>
        session.replaceAllRoomAssignments(
          roomNumbers: command.roomNumbers,
          housekeepers: command.housekeepers,
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
      final SetRoomVipCommand command => session.setRoomVip(
        roomNumber: command.roomNumber,
        isVip: command.isVip,
        changedAt: command.issuedAt,
      ),
      final SetRoomScheduleCommand command => session.setRoomSchedule(
        roomNumber: command.roomNumber,
        scheduledFor: command.scheduledFor,
        changedAt: command.issuedAt,
      ),
      final AdvanceScheduledRoomsCommand command =>
        session.advanceScheduledRooms(now: command.issuedAt),
    };
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
