import '../catalogs/margaritaville_room_catalog.dart';
import 'hotel_profile.dart';
import 'room_state.dart';
import 'work_assignment.dart';
import 'work_session_mutation.dart';

export 'work_session_mutation.dart';

part 'work_session_serialization.dart';
part 'work_session_room_actions.dart';

final class WorkSession {
  WorkSession._({
    required this.schemaVersion,
    required this.id,
    required this.hotel,
    required this.startedAt,
    required this.updatedAt,
    required this.workdayLocked,
    required this.lockUpdatedAt,
    required List<WorkAssignment> assignments,
  }) : assignments = List.unmodifiable(assignments) {
    _validate();
  }

  factory WorkSession.create({
    required String id,
    required HotelProfile hotel,
    required DateTime startedAt,
    required List<WorkAssignment> assignments,
  }) {
    return WorkSession._(
      schemaVersion: 2,
      id: id,
      hotel: hotel,
      startedAt: startedAt,
      updatedAt: startedAt,
      workdayLocked: false,
      lockUpdatedAt: null,
      assignments: assignments,
    );
  }

  final int schemaVersion;
  final String id;
  final HotelProfile hotel;
  final DateTime startedAt;
  final DateTime updatedAt;
  final bool workdayLocked;
  final DateTime? lockUpdatedAt;
  final List<WorkAssignment> assignments;

  Iterable<WorkAssignment> get activeAssignments {
    return assignments.where((assignment) => assignment.deletedAt == null);
  }

  Iterable<RoomState> get activeRooms {
    return activeAssignments.expand((assignment) => assignment.activeRooms);
  }

  RoomState? room(String roomNumber) {
    for (final assignment in activeAssignments) {
      final found = assignment.room(roomNumber);
      if (found != null) return found;
    }
    return null;
  }

  WorkAssignment? assignment(String assignmentId) {
    for (final candidate in activeAssignments) {
      if (candidate.id == assignmentId) return candidate;
    }
    return null;
  }

  WorkSessionMutation assignRoom({
    required String assignmentId,
    required String roomNumber,
    required DateTime changedAt,
  }) {
    if (workdayLocked ||
        !MargaritavilleRoomCatalog.contains(roomNumber.trim())) {
      return _ignored();
    }
    final target = assignment(assignmentId);
    if (target == null) return _ignored();
    for (final owner in activeAssignments) {
      final existing = owner.room(roomNumber);
      if (existing == null) continue;
      if (owner.id == assignmentId) return _ignored();
      return WorkSessionMutation(
        session: this,
        status: WorkSessionMutationStatus.blocked,
        conflict: RoomAssignmentConflict(
          roomNumber: roomNumber,
          ownerAssignmentId: owner.id,
          ownerHousekeeperId: owner.housekeeper.id,
        ),
      );
    }
    final room = RoomState.pending(
      roomNumber: roomNumber,
      selectedAt: changedAt,
    );
    final nextAssignments = assignments.map((assignment) {
      if (assignment.id == target.id) {
        return assignment.replacingRoom(room, changedAt: changedAt);
      }
      if (assignment.rooms.any(
        (candidate) =>
            candidate.roomNumber == roomNumber && candidate.isDeleted,
      )) {
        return assignment.removingRoomRecord(roomNumber, changedAt: changedAt);
      }
      return assignment;
    }).toList();
    return WorkSessionMutation(
      session: _copy(assignments: nextAssignments, updatedAt: changedAt),
      status: WorkSessionMutationStatus.changed,
    );
  }

  WorkSessionMutation unassignRoom({
    required String assignmentId,
    required String roomNumber,
    required DateTime changedAt,
  }) {
    if (workdayLocked) return _ignored();
    final owner = assignment(assignmentId);
    final current = owner?.room(roomNumber);
    if (owner == null || current == null) return _ignored();
    return _replaceAssignment(
      owner.replacingRoom(
        current.tombstone(changedAt: changedAt),
        changedAt: changedAt,
      ),
      changedAt: changedAt,
    );
  }

  WorkSessionMutation advanceRoom({
    required String roomNumber,
    required DateTime changedAt,
  }) {
    return _mutateRoom(
      roomNumber: roomNumber,
      changedAt: changedAt,
      transition: (room) => room.advanceSimpleCycle(changedAt: changedAt),
    );
  }

  WorkSessionMutation resetRoom({
    required String roomNumber,
    required DateTime changedAt,
  }) {
    return _mutateRoom(
      roomNumber: roomNumber,
      changedAt: changedAt,
      transition: (room) => room.resetSimpleCycle(changedAt: changedAt),
    );
  }

  WorkSession lockWorkday({required DateTime changedAt}) {
    if (workdayLocked || activeRooms.isEmpty) return this;
    return _copy(
      workdayLocked: true,
      lockUpdatedAt: changedAt,
      updatedAt: changedAt,
    );
  }

  WorkSession unlockWorkday({required DateTime changedAt}) {
    if (!workdayLocked) return this;
    return _copy(
      workdayLocked: false,
      lockUpdatedAt: changedAt,
      updatedAt: changedAt,
    );
  }

  WorkSessionMutation _mutateRoom({
    required String roomNumber,
    required DateTime changedAt,
    required RoomTransition Function(RoomState room) transition,
  }) {
    for (final owner in activeAssignments) {
      final current = owner.room(roomNumber);
      if (current == null) continue;
      final result = transition(current);
      if (result.outcome == RoomTransitionOutcome.ignored) return _ignored();
      return _replaceAssignment(
        owner.replacingRoom(result.room, changedAt: changedAt),
        changedAt: changedAt,
      );
    }
    return _ignored();
  }

  WorkSessionMutation _replaceAssignment(
    WorkAssignment replacement, {
    required DateTime changedAt,
  }) {
    final next = assignments
        .map((value) => value.id == replacement.id ? replacement : value)
        .toList();
    return WorkSessionMutation(
      session: _copy(assignments: next, updatedAt: changedAt),
      status: WorkSessionMutationStatus.changed,
    );
  }

  WorkSessionMutation _ignored() => WorkSessionMutation(
    session: this,
    status: WorkSessionMutationStatus.ignored,
  );

  WorkSession _copy({
    DateTime? updatedAt,
    bool? workdayLocked,
    Object? lockUpdatedAt = _unchanged,
    List<WorkAssignment>? assignments,
  }) {
    return WorkSession._(
      schemaVersion: schemaVersion,
      id: id,
      hotel: hotel,
      startedAt: startedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      workdayLocked: workdayLocked ?? this.workdayLocked,
      lockUpdatedAt: lockUpdatedAt == _unchanged
          ? this.lockUpdatedAt
          : lockUpdatedAt as DateTime?,
      assignments: assignments ?? this.assignments,
    );
  }

  factory WorkSession.fromJson(Map<String, Object?> json) {
    return _WorkSessionSerialization.decode(json);
  }

  Map<String, Object?> toJson() => _WorkSessionSerialization.encode(this);

  void _validate() {
    final activeRoomNumbers = <String>{};
    for (final assignment in activeAssignments) {
      for (final room in assignment.activeRooms) {
        if (!activeRoomNumbers.add(room.roomNumber)) {
          throw FormatException('Duplicate active room: ${room.roomNumber}');
        }
      }
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkSession &&
          schemaVersion == other.schemaVersion &&
          id == other.id &&
          hotel == other.hotel &&
          startedAt == other.startedAt &&
          updatedAt == other.updatedAt &&
          workdayLocked == other.workdayLocked &&
          lockUpdatedAt == other.lockUpdatedAt &&
          _listEquals(assignments, other.assignments);

  @override
  int get hashCode => Object.hash(
    schemaVersion,
    id,
    hotel,
    startedAt,
    updatedAt,
    workdayLocked,
    lockUpdatedAt,
    Object.hashAll(assignments),
  );
}

const _unchanged = Object();

bool _listEquals<T>(List<T> first, List<T> second) {
  if (first.length != second.length) return false;
  for (var index = 0; index < first.length; index++) {
    if (first[index] != second[index]) return false;
  }
  return true;
}
