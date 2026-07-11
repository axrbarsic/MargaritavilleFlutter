import 'package:drift/drift.dart' show Variable;
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/cart_details/application/commands/cart_details_command.dart';
import 'package:margaritaville_flutter/features/cart_details/data/repositories/drift_cart_details_repository.dart';
import 'package:margaritaville_flutter/features/work_session/application/commands/work_session_command.dart';
import 'package:margaritaville_flutter/features/work_session/application/work_session_command_handler.dart';
import 'package:margaritaville_flutter/features/work_session/data/repositories/drift_work_session_repository.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/hotel_profile.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/housekeeper.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_assignment.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_session.dart';
import 'package:margaritaville_flutter/shared/persistence/app_database.dart';

void main() {
  late AppDatabase database;
  late DriftWorkSessionRepository sessions;
  late DriftCartDetailsRepository carts;
  late WorkSessionCommandHandler handler;

  setUp(() {
    database = AppDatabase.inMemory();
    sessions = DriftWorkSessionRepository(database);
    carts = DriftCartDetailsRepository(database);
    handler = WorkSessionCommandHandler(sessions);
  });

  tearDown(() => database.close());

  test(
    'remove and re-add keeps stable cart identity and durable content',
    () async {
      final original = _session('primary');
      final assignment = original.activeAssignments.single;
      await sessions.replaceSession(original);
      await carts.commit(
        SaveCartNoteCommand(
          commandId: 'cart-note',
          sessionId: original.id,
          assignmentId: assignment.id,
          issuedAt: DateTime.utc(2027, 2, 10, 12, 30),
          text: 'Сохранить вместе с тележкой',
        ),
      );
      final rowId = await _assignmentRowId(
        database,
        original.id,
        assignment.id,
      );
      final housekeeper = assignment.housekeeper;

      final removed = await handler.execute(
        original,
        ToggleHousekeeperWorkItemCommand(
          commandId: 'remove-cart',
          issuedAt: DateTime.utc(2027, 2, 10, 13),
          housekeeperId: housekeeper.id,
          displayName: housekeeper.displayName,
          paletteKey: housekeeper.paletteKey,
        ),
      );
      expect(removed.session.activeAssignments, isEmpty);
      expect(removed.session.assignments.single.deletedAt, isNotNull);
      expect(removed.session.room('101'), isNull);

      final restored = await handler.execute(
        removed.session,
        ToggleHousekeeperWorkItemCommand(
          commandId: 'restore-cart',
          issuedAt: DateTime.utc(2027, 2, 10, 13, 1),
          housekeeperId: housekeeper.id,
          displayName: housekeeper.displayName,
          paletteKey: housekeeper.paletteKey,
        ),
      );
      final restoredAssignment = restored.session.activeAssignments.single;
      expect(restoredAssignment.id, assignment.id);
      expect(restoredAssignment.cartNumber, assignment.cartNumber);
      expect(restored.session.room('101'), isNull);
      expect(
        await _assignmentRowId(database, original.id, assignment.id),
        rowId,
      );
      expect(
        (await carts.load(
          sessionId: original.id,
          assignmentId: assignment.id,
        )).note,
        'Сохранить вместе с тележкой',
      );
    },
  );

  test(
    'command mutation leaves another session and its content untouched',
    () async {
      final primary = _session('primary');
      final sentinel = _session('sentinel');
      await sessions.replaceSession(primary);
      await sessions.replaceSession(sentinel);
      final sentinelAssignment = sentinel.activeAssignments.single;
      await carts.commit(
        SaveCartNoteCommand(
          commandId: 'sentinel-note',
          sessionId: sentinel.id,
          assignmentId: sentinelAssignment.id,
          issuedAt: DateTime.utc(2027, 2, 10, 12, 30),
          text: 'Чужую смену не менять',
        ),
      );
      final sentinelBefore = (await sessions.loadSession(
        sentinel.id,
      ))!.toJson();
      final sentinelRowId = await _assignmentRowId(
        database,
        sentinel.id,
        sentinelAssignment.id,
      );

      await handler.execute(
        primary,
        SetRoomVipCommand(
          commandId: 'primary-vip',
          issuedAt: DateTime.utc(2027, 2, 10, 13),
          roomNumber: '101',
          isVip: true,
        ),
      );

      expect(
        (await sessions.loadSession(sentinel.id))!.toJson(),
        sentinelBefore,
      );
      expect(
        await _assignmentRowId(database, sentinel.id, sentinelAssignment.id),
        sentinelRowId,
      );
      expect(
        (await carts.load(
          sessionId: sentinel.id,
          assignmentId: sentinelAssignment.id,
        )).note,
        'Чужую смену не менять',
      );
    },
  );
}

WorkSession _session(String id) {
  final now = DateTime.utc(2027, 2, 10, 12);
  final assignment = WorkAssignment.create(
    id: '$id-cart-1',
    cartNumber: 1,
    housekeeper: Housekeeper(
      id: '$id-ketty',
      displayName: 'Ketty',
      paletteKey: 'ruby',
      updatedAt: now,
    ),
    assignedAt: now,
  );
  return WorkSession.create(
        id: id,
        hotel: HotelProfile.margaritaville,
        startedAt: now,
        assignments: [assignment],
      )
      .assignRoom(
        assignmentId: assignment.id,
        roomNumber: '101',
        changedAt: now.add(const Duration(microseconds: 1)),
      )
      .session;
}

Future<int> _assignmentRowId(
  AppDatabase database,
  String sessionId,
  String assignmentId,
) async {
  final row = await database
      .customSelect(
        'SELECT rowid FROM work_assignment_records '
        'WHERE session_id = ? AND id = ?',
        variables: [
          Variable<String>(sessionId),
          Variable<String>(assignmentId),
        ],
      )
      .getSingle();
  return row.read<int>('rowid');
}
