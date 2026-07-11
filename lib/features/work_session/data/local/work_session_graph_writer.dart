import 'package:drift/drift.dart';

import '../../../../shared/persistence/app_database.dart';
import '../../domain/models/housekeeper.dart';
import '../../domain/models/room_state.dart';
import '../../domain/models/work_session.dart';

final class WorkSessionGraphWriter {
  const WorkSessionGraphWriter(this._database);

  final AppDatabase _database;

  Future<void> replace(WorkSession session) {
    return _database.transaction(() async {
      await _upsertParent(session);
      await _deleteMutableChildren(session.id);

      final writtenHousekeepers = <String>{};
      for (final assignment in session.assignments) {
        if (writtenHousekeepers.add(assignment.housekeeper.id)) {
          await _insertHousekeeper(session.id, assignment.housekeeper);
        }
        await _database
            .into(_database.workAssignmentRecords)
            .insert(
              WorkAssignmentRecordsCompanion.insert(
                sessionId: session.id,
                id: assignment.id,
                cartNumber: assignment.cartNumber,
                housekeeperId: assignment.housekeeper.id,
                assignedAt: assignment.assignedAt,
                updatedAt: assignment.updatedAt,
                deletedAt: Value(assignment.deletedAt),
              ),
            );
        for (final room in assignment.rooms) {
          await _insertRoom(session.id, assignment.id, room);
        }
      }
    });
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

  Future<void> _deleteMutableChildren(String sessionId) async {
    await (_database.delete(
      _database.roomStateRecords,
    )..where((row) => row.sessionId.equals(sessionId))).go();
    await (_database.delete(
      _database.workAssignmentRecords,
    )..where((row) => row.sessionId.equals(sessionId))).go();
    await (_database.delete(
      _database.housekeeperRecords,
    )..where((row) => row.sessionId.equals(sessionId))).go();
  }

  Future<void> _insertHousekeeper(String sessionId, Housekeeper housekeeper) {
    return _database
        .into(_database.housekeeperRecords)
        .insert(
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

  Future<void> _insertRoom(
    String sessionId,
    String assignmentId,
    RoomState room,
  ) {
    return _database
        .into(_database.roomStateRecords)
        .insert(
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
