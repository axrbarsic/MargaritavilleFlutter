import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/work_session/application/work_session_seed.dart';
import 'package:margaritaville_flutter/features/work_session/domain/catalogs/margaritaville_housekeeper_catalog.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_session.dart';

void main() {
  final now = DateTime.utc(2027, 2, 10, 12);

  test('housekeeper catalog exactly matches Swift build 37 order', () {
    expect(
      MargaritavilleHousekeeperCatalog.entries
          .map((value) => value.displayName)
          .toList(),
      [
        'Kerlange',
        'Ana',
        'Bebita',
        'Denise',
        'Fabiola',
        'Francia',
        'Gurlene',
        'Ketty',
        'Luisa',
        'Marie',
        'Marie Pierre',
        'Nadia',
        'Nadia M (DC)',
        'Nidia',
        'Omelene PM',
        'Ritza',
        'Rosaire',
        'Simone',
        'Vida',
        'Wonderline',
      ],
    );
  });

  test('fresh selection is empty and materializes first free carts lazily', () {
    var session = makeInitialWorkSession(now);
    expect(session.activeAssignments, isEmpty);

    final ketty = MargaritavilleHousekeeperCatalog.entries[7];
    session = session
        .toggleHousekeeperWorkItem(
          housekeeperId: ketty.id,
          displayName: ketty.displayName,
          paletteKey: ketty.paletteKey,
          changedAt: now,
        )
        .session;
    final nadia = MargaritavilleHousekeeperCatalog.entries[11];
    session = session
        .toggleHousekeeperWorkItem(
          housekeeperId: nadia.id,
          displayName: nadia.displayName,
          paletteKey: nadia.paletteKey,
          changedAt: now.add(const Duration(microseconds: 1)),
        )
        .session;

    expect(session.assignmentForHousekeeper('ketty')?.cartNumber, 1);
    expect(session.assignmentForHousekeeper('ketty')?.territoryId, 'A1');
    expect(session.assignmentForHousekeeper('nadia')?.cartNumber, 2);
    expect(session.assignmentForHousekeeper('nadia')?.territoryId, 'B1');
  });

  test('reselecting a housekeeper removes their work item and rooms', () {
    final ketty = MargaritavilleHousekeeperCatalog.entries[7];
    var session = makeInitialWorkSession(now)
        .toggleHousekeeperWorkItem(
          housekeeperId: ketty.id,
          displayName: ketty.displayName,
          paletteKey: ketty.paletteKey,
          changedAt: now,
        )
        .session;
    final assignment = session.assignmentForHousekeeper('ketty')!;
    session = session
        .assignRoom(
          assignmentId: assignment.id,
          roomNumber: '101',
          changedAt: now.add(const Duration(microseconds: 1)),
        )
        .session;
    session = session
        .toggleHousekeeperWorkItem(
          housekeeperId: ketty.id,
          displayName: ketty.displayName,
          paletteKey: ketty.paletteKey,
          changedAt: now.add(const Duration(microseconds: 2)),
        )
        .session;

    expect(session.activeAssignments, isEmpty);
    expect(session.room('101'), isNull);
  });

  test('removed cart number is reused by the next work item', () {
    final ketty = MargaritavilleHousekeeperCatalog.entries[7];
    final nadia = MargaritavilleHousekeeperCatalog.entries[11];
    var session = makeInitialWorkSession(now)
        .toggleHousekeeperWorkItem(
          housekeeperId: ketty.id,
          displayName: ketty.displayName,
          paletteKey: ketty.paletteKey,
          changedAt: now,
        )
        .session;
    session = session
        .toggleHousekeeperWorkItem(
          housekeeperId: ketty.id,
          displayName: ketty.displayName,
          paletteKey: ketty.paletteKey,
          changedAt: now.add(const Duration(microseconds: 1)),
        )
        .session;
    session = session
        .toggleHousekeeperWorkItem(
          housekeeperId: nadia.id,
          displayName: nadia.displayName,
          paletteKey: nadia.paletteKey,
          changedAt: now.add(const Duration(microseconds: 2)),
        )
        .session;

    expect(session.assignmentForHousekeeper('nadia')?.cartNumber, 1);
    expect(session.assignmentForHousekeeper('nadia')?.territoryId, 'A1');
  });

  test('room IDs are canonicalized before storage', () {
    final ketty = MargaritavilleHousekeeperCatalog.entries[7];
    var session = makeInitialWorkSession(now)
        .toggleHousekeeperWorkItem(
          housekeeperId: ketty.id,
          displayName: ketty.displayName,
          paletteKey: ketty.paletteKey,
          changedAt: now,
        )
        .session;
    final assignment = session.assignmentForHousekeeper('ketty')!;
    session = session
        .assignRoom(
          assignmentId: assignment.id,
          roomNumber: ' 101 ',
          changedAt: now.add(const Duration(microseconds: 1)),
        )
        .session;

    expect(session.activeRooms.single.roomNumber, '101');
  });

  test('territory switches keep previously selected rooms', () {
    final ketty = MargaritavilleHousekeeperCatalog.entries[7];
    var session = makeInitialWorkSession(now)
        .toggleHousekeeperWorkItem(
          housekeeperId: ketty.id,
          displayName: ketty.displayName,
          paletteKey: ketty.paletteKey,
          changedAt: now,
        )
        .session;
    final assignment = session.assignmentForHousekeeper('ketty')!;
    session = session
        .assignRoom(
          assignmentId: assignment.id,
          roomNumber: '101',
          changedAt: now.add(const Duration(microseconds: 1)),
        )
        .session;
    session = session
        .setAssignmentTerritory(
          assignmentId: assignment.id,
          territoryId: 'B1',
          changedAt: now.add(const Duration(microseconds: 2)),
        )
        .session;
    session = session
        .assignRoom(
          assignmentId: assignment.id,
          roomNumber: '143',
          changedAt: now.add(const Duration(microseconds: 3)),
        )
        .session;

    final updated = session.assignment(assignment.id)!;
    expect(updated.territoryId, 'B1');
    expect(updated.activeRooms.map((value) => value.roomNumber).toSet(), {
      '101',
      '143',
    });
  });

  test('locked workday rejects setup edits and unlock preserves selection', () {
    final ketty = MargaritavilleHousekeeperCatalog.entries[7];
    final nadia = MargaritavilleHousekeeperCatalog.entries[11];
    var session = makeInitialWorkSession(now)
        .toggleHousekeeperWorkItem(
          housekeeperId: ketty.id,
          displayName: ketty.displayName,
          paletteKey: ketty.paletteKey,
          changedAt: now,
        )
        .session;
    final assignment = session.assignmentForHousekeeper('ketty')!;
    session = session
        .assignRoom(
          assignmentId: assignment.id,
          roomNumber: '101',
          changedAt: now.add(const Duration(microseconds: 1)),
        )
        .session
        .lockWorkday(changedAt: now.add(const Duration(microseconds: 2)));

    final housekeeperMutation = session.toggleHousekeeperWorkItem(
      housekeeperId: nadia.id,
      displayName: nadia.displayName,
      paletteKey: nadia.paletteKey,
      changedAt: now.add(const Duration(microseconds: 3)),
    );
    final territoryMutation = session.setAssignmentTerritory(
      assignmentId: assignment.id,
      territoryId: 'B1',
      changedAt: now.add(const Duration(microseconds: 4)),
    );
    final roomMutation = session.toggleRoomSelection(
      assignmentId: assignment.id,
      roomNumber: '102',
      changedAt: now.add(const Duration(microseconds: 5)),
    );

    expect(housekeeperMutation.status, WorkSessionMutationStatus.ignored);
    expect(territoryMutation.status, WorkSessionMutationStatus.ignored);
    expect(roomMutation.status, WorkSessionMutationStatus.ignored);

    final unlocked = session.unlockWorkday(
      changedAt: now.add(const Duration(microseconds: 6)),
    );
    expect(unlocked.workdayLocked, isFalse);
    expect(unlocked.assignment(assignment.id)?.territoryId, 'A1');
    expect(unlocked.room('101'), isNotNull);
    expect(unlocked.assignmentForHousekeeper('nadia'), isNull);
  });
}
