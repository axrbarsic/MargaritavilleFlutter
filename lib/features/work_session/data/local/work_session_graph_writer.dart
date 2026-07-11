import 'package:drift/drift.dart';

import '../../../../shared/persistence/app_database.dart';
import '../../../housekeeper_catalog/domain/models/housekeeper.dart';
import '../../domain/models/room_state.dart';
import '../../domain/models/work_session.dart';

final class WorkSessionGraphWriter {
  const WorkSessionGraphWriter(this._database);

  final AppDatabase _database;

  Future<void> replace(WorkSession session) {
    return _database.transaction(() => reconcileInCurrentTransaction(session));
  }

  Future<void> reconcileInCurrentTransaction(WorkSession session) async {
    await _upsertParent(session);
    await _reconcileHousekeepers(session);
    await _reconcileAssignments(session);
    await _reconcileRooms(session);
  }

  Future<void> _upsertParent(WorkSession session) {
    return _database
        .into(_database.workSessionRecords)
        .insertOnConflictUpdate(
          WorkSessionRecordsCompanion.insert(
            id: session.id,
            canonicalSchemaVersion: session.schemaVersion,
            hotelId: session.hotel.id,
            hotelName: session.hotel.name,
            workflow: session.hotel.workflow.name,
            startedAt: session.startedAt,
            updatedAt: session.updatedAt,
            workdayLocked: Value(session.workdayLocked),
            lockUpdatedAt: Value(session.lockUpdatedAt),
          ),
        );
  }

  Future<void> _reconcileHousekeepers(WorkSession session) async {
    final desired = <String, Housekeeper>{
      for (final assignment in session.assignments)
        assignment.housekeeper.id: assignment.housekeeper,
    };
    final existing = await (_database.select(
      _database.housekeeperRecords,
    )..where((row) => row.sessionId.equals(session.id))).get();
    for (final row in existing) {
      if (desired.containsKey(row.id)) continue;
      await (_database.update(_database.housekeeperRecords)..where(
            (candidate) =>
                candidate.sessionId.equals(session.id) &
                candidate.id.equals(row.id),
          ))
          .write(
            HousekeeperRecordsCompanion(
              updatedAt: Value(session.updatedAt),
              deletedAt: Value(row.deletedAt ?? session.updatedAt),
            ),
          );
    }
    for (final housekeeper in desired.values) {
      await _upsertHousekeeper(session.id, housekeeper);
    }
  }

  Future<void> _upsertHousekeeper(String sessionId, Housekeeper housekeeper) {
    return _database
        .into(_database.housekeeperRecords)
        .insertOnConflictUpdate(
          HousekeeperRecordsCompanion.insert(
            sessionId: sessionId,
            id: housekeeper.id,
            displayName: housekeeper.displayName,
            paletteKey: housekeeper.paletteKey,
            updatedAt: housekeeper.updatedAt,
            deletedAt: Value(housekeeper.deletedAt),
          ),
        );
  }

  Future<void> _reconcileAssignments(WorkSession session) async {
    final desired = {for (final value in session.assignments) value.id: value};
    final existing = await (_database.select(
      _database.workAssignmentRecords,
    )..where((row) => row.sessionId.equals(session.id))).get();
    for (final row in existing) {
      if (desired.containsKey(row.id)) continue;
      await (_database.update(_database.workAssignmentRecords)..where(
            (candidate) =>
                candidate.sessionId.equals(session.id) &
                candidate.id.equals(row.id),
          ))
          .write(
            WorkAssignmentRecordsCompanion(
              updatedAt: Value(session.updatedAt),
              deletedAt: Value(row.deletedAt ?? session.updatedAt),
            ),
          );
    }
    for (final assignment in desired.values) {
      await _database
          .into(_database.workAssignmentRecords)
          .insertOnConflictUpdate(
            WorkAssignmentRecordsCompanion.insert(
              sessionId: session.id,
              id: assignment.id,
              cartNumber: assignment.cartNumber,
              housekeeperId: assignment.housekeeper.id,
              territoryId: Value(assignment.territoryId),
              assignedAt: assignment.assignedAt,
              updatedAt: assignment.updatedAt,
              deletedAt: Value(assignment.deletedAt),
            ),
          );
    }
  }

  Future<void> _reconcileRooms(WorkSession session) async {
    final desired = <String, ({String assignmentId, RoomState room})>{};
    for (final assignment in session.assignments) {
      for (final room in assignment.rooms) {
        final current = desired[room.roomNumber];
        if (current != null && !current.room.isDeleted && room.isDeleted) {
          continue;
        }
        desired[room.roomNumber] = (assignmentId: assignment.id, room: room);
      }
    }
    final existing = await (_database.select(
      _database.roomStateRecords,
    )..where((row) => row.sessionId.equals(session.id))).get();
    for (final row in existing) {
      if (desired.containsKey(row.roomNumber)) continue;
      await (_database.update(_database.roomStateRecords)..where(
            (candidate) =>
                candidate.sessionId.equals(session.id) &
                candidate.roomNumber.equals(row.roomNumber),
          ))
          .write(
            RoomStateRecordsCompanion(
              deletedAt: Value(row.deletedAt ?? session.updatedAt),
              phaseUpdatedAt: Value(session.updatedAt),
            ),
          );
    }
    for (final value in desired.values) {
      await _upsertRoom(session.id, value.assignmentId, value.room);
    }
  }

  Future<void> _upsertRoom(
    String sessionId,
    String assignmentId,
    RoomState room,
  ) {
    return _database
        .into(_database.roomStateRecords)
        .insertOnConflictUpdate(
          RoomStateRecordsCompanion.insert(
            sessionId: sessionId,
            roomNumber: room.roomNumber,
            assignmentId: assignmentId,
            phase: room.phase.name,
            isVip: Value(room.isVip),
            scheduledFor: Value(room.scheduledFor),
            deletedAt: Value(room.deletedAt),
            selectedAt: room.timestamps.selectedAt,
            phaseUpdatedAt: room.timestamps.phaseUpdatedAt,
            openedAt: Value(room.timestamps.openedAt),
            completedAt: Value(room.timestamps.completedAt),
            vipUpdatedAt: Value(room.timestamps.vipUpdatedAt),
            scheduledUpdatedAt: Value(room.timestamps.scheduledUpdatedAt),
          ),
        );
  }
}
