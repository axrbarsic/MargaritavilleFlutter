import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/hotel_profile.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/housekeeper.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/room_state.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_assignment.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_session.dart';

void main() {
  final startedAt = DateTime.utc(2027, 2, 10, 12);
  final changedAt = DateTime.utc(2027, 2, 10, 12, 1);
  final ketty = Housekeeper(
    id: 'ketty',
    displayName: 'Ketty',
    paletteKey: 'lagoon',
    updatedAt: startedAt,
  );
  final omelene = Housekeeper(
    id: 'omelene-pm',
    displayName: 'Omelene PM',
    paletteKey: 'sunset',
    updatedAt: startedAt,
  );

  WorkSession makeSession() => WorkSession.create(
    id: 'session-2027-02-10',
    hotel: HotelProfile.margaritaville,
    startedAt: startedAt,
    assignments: [
      WorkAssignment.create(
        id: 'cart-1',
        cartNumber: 1,
        housekeeper: ketty,
        assignedAt: startedAt,
      ),
      WorkAssignment.create(
        id: 'cart-2',
        cartNumber: 2,
        housekeeper: omelene,
        assignedAt: startedAt,
      ),
    ],
  );

  test('blocks a room already owned by another housekeeper assignment', () {
    final first = makeSession().assignRoom(
      assignmentId: 'cart-1',
      roomNumber: '101',
      changedAt: changedAt,
    );
    final duplicate = first.session.assignRoom(
      assignmentId: 'cart-2',
      roomNumber: '101',
      changedAt: changedAt.add(const Duration(seconds: 1)),
    );

    expect(first.status, WorkSessionMutationStatus.changed);
    expect(duplicate.status, WorkSessionMutationStatus.blocked);
    expect(duplicate.conflict?.roomNumber, '101');
    expect(duplicate.conflict?.ownerAssignmentId, 'cart-1');
    expect(duplicate.conflict?.ownerHousekeeperId, 'ketty');
    expect(duplicate.session, first.session);
  });

  test('ignores room numbers outside the Margaritaville catalog', () {
    final result = makeSession().assignRoom(
      assignmentId: 'cart-1',
      roomNumber: '999',
      changedAt: changedAt,
    );

    expect(result.status, WorkSessionMutationStatus.ignored);
    expect(result.session.activeRooms, isEmpty);
  });

  test('locked workday ignores setup mutations', () {
    final withRoom = makeSession()
        .assignRoom(
          assignmentId: 'cart-1',
          roomNumber: '101',
          changedAt: changedAt,
        )
        .session;
    final locked = withRoom.lockWorkday(
      changedAt: changedAt.add(const Duration(seconds: 1)),
    );

    final result = locked.assignRoom(
      assignmentId: 'cart-1',
      roomNumber: '102',
      changedAt: changedAt.add(const Duration(seconds: 2)),
    );

    expect(locked.workdayLocked, isTrue);
    expect(result.status, WorkSessionMutationStatus.ignored);
    expect(result.session, locked);
  });

  test('cannot lock an empty workday', () {
    final empty = makeSession();

    expect(empty.lockWorkday(changedAt: changedAt), empty);
  });

  test('advances an assigned room through the explicit simple-cycle phase', () {
    final assigned = makeSession()
        .assignRoom(
          assignmentId: 'cart-1',
          roomNumber: '101',
          changedAt: changedAt,
        )
        .session;
    final openedAt = changedAt.add(const Duration(minutes: 1));

    final opened = assigned.advanceRoom(roomNumber: '101', changedAt: openedAt);

    expect(opened.status, WorkSessionMutationStatus.changed);
    expect(opened.session.room('101')?.phase.name, 'open');
    expect(opened.session.updatedAt, openedAt);
  });

  test('mutates VIP and schedule as independent room fields', () {
    final assigned = makeSession()
        .assignRoom(
          assignmentId: 'cart-1',
          roomNumber: '101',
          changedAt: changedAt,
        )
        .session;
    final vipAt = changedAt.add(const Duration(minutes: 1));
    final dueAt = changedAt.add(const Duration(hours: 1));
    final scheduledAt = changedAt.add(const Duration(minutes: 2));

    final vip = assigned.setRoomVip(
      roomNumber: '101',
      isVip: true,
      changedAt: vipAt,
    );
    final scheduled = vip.session.setRoomSchedule(
      roomNumber: '101',
      scheduledFor: dueAt,
      changedAt: scheduledAt,
    );

    expect(vip.status, WorkSessionMutationStatus.changed);
    expect(scheduled.status, WorkSessionMutationStatus.changed);
    expect(scheduled.session.room('101')?.isVip, isTrue);
    expect(scheduled.session.room('101')?.scheduledFor, dueAt);
    expect(scheduled.session.room('101')?.timestamps.vipUpdatedAt, vipAt);
    expect(
      scheduled.session.room('101')?.timestamps.scheduledUpdatedAt,
      scheduledAt,
    );
  });

  test('advances every due scheduled room in one session mutation', () {
    var session = makeSession()
        .assignRoom(
          assignmentId: 'cart-1',
          roomNumber: '101',
          changedAt: changedAt,
        )
        .session;
    session = session
        .assignRoom(
          assignmentId: 'cart-1',
          roomNumber: '102',
          changedAt: changedAt.add(const Duration(seconds: 1)),
        )
        .session;
    final dueAt = changedAt.add(const Duration(minutes: 30));
    session = session
        .setRoomSchedule(
          roomNumber: '101',
          scheduledFor: dueAt,
          changedAt: changedAt.add(const Duration(minutes: 1)),
        )
        .session;
    session = session
        .setRoomSchedule(
          roomNumber: '102',
          scheduledFor: dueAt.add(const Duration(minutes: 1)),
          changedAt: changedAt.add(const Duration(minutes: 1)),
        )
        .session;

    final advanced = session.advanceScheduledRooms(now: dueAt);

    expect(advanced.status, WorkSessionMutationStatus.changed);
    expect(advanced.session.room('101')?.phase, RoomPhase.open);
    expect(advanced.session.room('101')?.scheduledFor, isNull);
    expect(
      advanced.session.room('102')?.displayStatus,
      RoomDisplayStatus.scheduled,
    );
  });

  test('unassigning a room leaves a selection tombstone', () {
    final assigned = makeSession()
        .assignRoom(
          assignmentId: 'cart-1',
          roomNumber: '101',
          changedAt: changedAt,
        )
        .session;
    final removedAt = changedAt.add(const Duration(minutes: 1));

    final removed = assigned.unassignRoom(
      assignmentId: 'cart-1',
      roomNumber: '101',
      changedAt: removedAt,
    );

    expect(removed.status, WorkSessionMutationStatus.changed);
    expect(removed.session.room('101'), isNull);
    final tombstone = removed.session.assignment('cart-1')!.rooms.single;
    expect(tombstone.deletedAt, removedAt);
  });

  test('a tombstoned room can be assigned to a different work block', () {
    final first = makeSession()
        .assignRoom(
          assignmentId: 'cart-1',
          roomNumber: '101',
          changedAt: changedAt,
        )
        .session;
    final removed = first
        .unassignRoom(
          assignmentId: 'cart-1',
          roomNumber: '101',
          changedAt: changedAt.add(const Duration(minutes: 1)),
        )
        .session;

    final reassigned = removed.assignRoom(
      assignmentId: 'cart-2',
      roomNumber: '101',
      changedAt: changedAt.add(const Duration(minutes: 2)),
    );

    expect(reassigned.status, WorkSessionMutationStatus.changed);
    expect(reassigned.session.assignment('cart-1')!.rooms, isEmpty);
    expect(reassigned.session.assignment('cart-2')!.room('101'), isNotNull);
  });
}
