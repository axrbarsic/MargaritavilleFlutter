import 'package:drift/drift.dart';

import '../../../../shared/persistence/app_database.dart';
import '../../../../shared/persistence/drift_command_ledger.dart';
import '../../../housekeeper_catalog/domain/models/housekeeper.dart';
import '../../domain/models/room_state.dart';
import '../../domain/models/room_timestamps.dart';
import '../../domain/models/work_assignment.dart';
import '../../domain/models/work_session.dart';
import '../../domain/models/work_session_command_descriptor.dart';
import '../../domain/repositories/work_session_repository.dart';
import '../local/work_session_graph_writer.dart';

final class DriftWorkSessionRepository implements WorkSessionRepository {
  const DriftWorkSessionRepository(this._database);

  final AppDatabase _database;

  @override
  Future<WorkSession?> loadSession(String sessionId) async {
    final query = _database.select(_database.workSessionRecords)
      ..where((row) => row.id.equals(sessionId));
    final row = await query.getSingleOrNull();
    return row == null ? null : _hydrate(row);
  }

  @override
  Future<WorkSession?> loadLatestSession() async {
    final query = _database.select(_database.workSessionRecords)
      ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)])
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _hydrate(row);
  }

  @override
  Stream<WorkSession?> watchLatestSession() {
    final query = _database.select(_database.workSessionRecords)
      ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)])
      ..limit(1);
    return query.watchSingleOrNull().asyncMap((row) async {
      return row == null ? null : _hydrate(row);
    });
  }

  @override
  Future<void> replaceSession(WorkSession session) {
    return WorkSessionGraphWriter(_database).replace(session);
  }

  @override
  Future<WorkSessionMutation> commitCommand({
    required WorkSession fallbackSession,
    required WorkSessionCommandDescriptor descriptor,
    required WorkSessionMutation Function(WorkSession session) mutate,
  }) async {
    WorkSessionMutation? evaluated;
    final status = await DriftCommandLedger(_database).commit(
      envelope: CommandLedgerEnvelope(
        sessionId: fallbackSession.id,
        commandId: descriptor.commandId,
        commandVersion: descriptor.version,
        commandType: descriptor.commandType,
        commandFingerprint: CommandLedgerEnvelope.fingerprint(
          descriptor.canonicalPayload,
        ),
        issuedAt: descriptor.issuedAt,
        eventId: 'work-session:${fallbackSession.id}:${descriptor.commandId}',
        eventType: descriptor.eventType,
        eventPayload: descriptor.eventPayload,
      ),
      mutate: () async {
        final authoritative = await loadSession(fallbackSession.id);
        if (authoritative == null) {
          throw StateError('Missing work session ${fallbackSession.id}.');
        }
        final result = mutate(authoritative);
        evaluated = result;
        if (result.status != WorkSessionMutationStatus.changed) return false;
        await WorkSessionGraphWriter(
          _database,
        ).reconcileInCurrentTransaction(result.session);
        return true;
      },
    );
    final authoritative = await loadSession(fallbackSession.id);
    if (authoritative == null) {
      throw StateError('Missing work session ${fallbackSession.id}.');
    }
    if (status == CommandLedgerStatus.duplicate) {
      return WorkSessionMutation(
        session: authoritative,
        status: WorkSessionMutationStatus.ignored,
      );
    }
    final result = evaluated;
    if (result == null) {
      throw StateError('Command ${descriptor.commandId} was not evaluated.');
    }
    return WorkSessionMutation(
      session: authoritative,
      status: result.status,
      conflict: result.conflict,
    );
  }

  Future<WorkSession> _hydrate(WorkSessionRow session) async {
    final catalogRows = await (_database.select(
      _database.housekeeperCatalogRecords,
    )..where((row) => row.deletedAt.isNull())).get();
    final catalogById = {
      for (final row in catalogRows) row.id: _mapCatalogHousekeeper(row),
    };
    final assignmentQuery = _database.select(_database.workAssignmentRecords)
      ..where((row) => row.sessionId.equals(session.id))
      ..orderBy([(row) => OrderingTerm.asc(row.cartNumber)]);
    final assignmentRows = await assignmentQuery.get();
    final assignments = <WorkAssignment>[];

    for (final assignment in assignmentRows) {
      final housekeeperQuery = _database.select(_database.housekeeperRecords)
        ..where(
          (row) =>
              row.sessionId.equals(session.id) &
              row.id.equals(assignment.housekeeperId),
        );
      final housekeeper = await housekeeperQuery.getSingle();
      final roomQuery = _database.select(_database.roomStateRecords)
        ..where(
          (row) =>
              row.sessionId.equals(session.id) &
              row.assignmentId.equals(assignment.id),
        )
        ..orderBy([(row) => OrderingTerm.asc(row.roomNumber)]);
      final rooms = await roomQuery.get();
      assignments.add(
        WorkAssignment(
          id: assignment.id,
          cartNumber: assignment.cartNumber,
          territoryId: assignment.territoryId,
          housekeeper:
              catalogById[assignment.housekeeperId] ??
              _mapHousekeeper(housekeeper),
          assignedAt: assignment.assignedAt,
          updatedAt: assignment.updatedAt,
          deletedAt: assignment.deletedAt,
          rooms: rooms.map(_mapRoom).toList(),
        ),
      );
    }

    return WorkSession.fromJson({
      'schemaVersion': session.canonicalSchemaVersion,
      'id': session.id,
      'hotel': {
        'id': session.hotelId,
        'name': session.hotelName,
        'workflow': session.workflow,
      },
      'startedAt': session.startedAt.toUtc().toIso8601String(),
      'updatedAt': session.updatedAt.toUtc().toIso8601String(),
      'workdayLocked': session.workdayLocked,
      'lockUpdatedAt': session.lockUpdatedAt?.toUtc().toIso8601String(),
      'assignments': assignments.map((value) => value.toJson()).toList(),
    });
  }

  Housekeeper _mapHousekeeper(HousekeeperRow row) => Housekeeper(
    id: row.id,
    displayName: row.displayName,
    paletteKey: row.paletteKey,
    updatedAt: row.updatedAt,
    deletedAt: row.deletedAt,
  );

  Housekeeper _mapCatalogHousekeeper(HousekeeperCatalogRow row) => Housekeeper(
    id: row.id,
    displayName: row.displayName,
    paletteKey: row.paletteKey,
    updatedAt: row.updatedAt,
    deletedAt: row.deletedAt,
  );

  RoomState _mapRoom(RoomStateRow row) => RoomState(
    roomNumber: row.roomNumber,
    phase: RoomPhase.values.byName(row.phase),
    isVip: row.isVip,
    scheduledFor: row.scheduledFor,
    deletedAt: row.deletedAt,
    timestamps: RoomTimestamps(
      selectedAt: row.selectedAt,
      phaseUpdatedAt: row.phaseUpdatedAt,
      openedAt: row.openedAt,
      completedAt: row.completedAt,
      vipUpdatedAt: row.vipUpdatedAt,
      scheduledUpdatedAt: row.scheduledUpdatedAt,
    ),
  );
}
