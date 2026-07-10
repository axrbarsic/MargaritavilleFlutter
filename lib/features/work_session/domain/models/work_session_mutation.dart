import 'work_session.dart';

enum WorkSessionMutationStatus { changed, blocked, ignored }

final class RoomAssignmentConflict {
  const RoomAssignmentConflict({
    required this.roomNumber,
    required this.ownerAssignmentId,
    required this.ownerHousekeeperId,
  });

  final String roomNumber;
  final String ownerAssignmentId;
  final String ownerHousekeeperId;
}

final class WorkSessionMutation {
  const WorkSessionMutation({
    required this.session,
    required this.status,
    this.conflict,
  });

  final WorkSession session;
  final WorkSessionMutationStatus status;
  final RoomAssignmentConflict? conflict;
}
