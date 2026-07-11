import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/work_session/application/all_rooms_test_data_generator.dart';
import 'package:margaritaville_flutter/features/work_session/application/commands/work_session_command.dart';
import 'package:margaritaville_flutter/features/work_session/application/work_session_command_handler.dart';
import 'package:margaritaville_flutter/features/work_session/domain/catalogs/margaritaville_housekeeper_catalog.dart';
import 'package:margaritaville_flutter/features/work_session/domain/catalogs/margaritaville_room_catalog.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/hotel_profile.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/housekeeper.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_assignment.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_session.dart';
import 'package:margaritaville_flutter/features/work_session/domain/repositories/work_session_repository.dart';

void main() {
  final now = DateTime.utc(2027, 2, 10, 12);

  test('controlled seed returns every catalog room once in shuffled order', () {
    final catalogOrder = MargaritavilleRoomCatalog.territories
        .expand((territory) => territory.rooms)
        .toList(growable: false);

    final generated = const AllRoomsTestDataGenerator().shuffledRoomNumbers(
      Random(42),
    );

    expect(generated, hasLength(catalogOrder.length));
    expect(generated.toSet(), catalogOrder.toSet());
    expect(generated, isNot(equals(catalogOrder)));
    expect(generated.where((roomNumber) => roomNumber == '101'), hasLength(1));
  });

  test(
    'replacement command persists every room through application path',
    () async {
      final repository = _RecordingRepository();
      final session = _session(now).lockWorkday(changedAt: now);
      final roomNumbers = const AllRoomsTestDataGenerator().shuffledRoomNumbers(
        Random(42),
      );
      final handler = WorkSessionCommandHandler(repository);
      final housekeepers = MargaritavilleHousekeeperCatalog.housekeepers(now);

      final result = await handler.execute(
        session,
        ReplaceAllRoomAssignmentsCommand(
          commandId: 'all-rooms-1',
          issuedAt: now.add(const Duration(minutes: 1)),
          roomNumbers: roomNumbers,
          housekeepers: housekeepers,
        ),
      );

      final persisted = repository.session!;
      final persistedRooms = persisted.activeAssignments
          .expand((assignment) => assignment.activeRooms)
          .map((room) => room.roomNumber)
          .toList(growable: false);
      expect(result.status, WorkSessionMutationStatus.changed);
      expect(repository.writeCount, 1);
      expect(persisted.id, session.id);
      expect(persisted.workdayLocked, isTrue);
      expect(persisted.activeAssignments, hasLength(housekeepers.length));
      expect(
        persisted.activeAssignments
            .map((assignment) => assignment.housekeeper.id)
            .toSet(),
        housekeepers.map((value) => value.id).toSet(),
      );
      expect(
        persistedRooms,
        hasLength(MargaritavilleRoomCatalog.roomNumbers.length),
      );
      expect(persistedRooms.toSet(), MargaritavilleRoomCatalog.roomNumbers);
      expect(persistedRooms.toSet(), hasLength(persistedRooms.length));
      expect(
        persisted.activeAssignments.every(
          (assignment) => assignment.activeRooms.isNotEmpty,
        ),
        isTrue,
      );
      for (final assignment in persisted.activeAssignments) {
        final firstRoom =
            assignment.activeRooms.map((room) => room.roomNumber).toList()
              ..sort();
        expect(
          assignment.territoryId,
          MargaritavilleRoomCatalog.territoryForRoom(firstRoom.first)?.id,
        );
      }
    },
  );

  test('replacement preserves existing room status, VIP and schedule', () {
    final dueAt = now.add(const Duration(hours: 2));
    var session = _session(now);
    session = session
        .advanceRoom(
          roomNumber: '101',
          changedAt: now.add(const Duration(microseconds: 1)),
        )
        .session;
    session = session
        .setRoomVip(
          roomNumber: '101',
          isVip: true,
          changedAt: now.add(const Duration(microseconds: 2)),
        )
        .session;
    session = session
        .setRoomSchedule(
          roomNumber: '101',
          scheduledFor: dueAt,
          changedAt: now.add(const Duration(microseconds: 3)),
        )
        .session;

    final result = session.replaceAllRoomAssignments(
      roomNumbers: const AllRoomsTestDataGenerator().shuffledRoomNumbers(
        Random(7),
      ),
      housekeepers: MargaritavilleHousekeeperCatalog.housekeepers(now),
      changedAt: now.add(const Duration(minutes: 1)),
    );

    final preserved = result.session.room('101')!;
    expect(preserved.phase.name, 'open');
    expect(preserved.isVip, isTrue);
    expect(preserved.scheduledFor, dueAt);
    expect(preserved.timestamps.selectedAt, now);
  });

  test('replacement never creates carts outside the donor 1 to 100 range', () {
    final housekeepers = [
      for (var index = 1; index <= 101; index++)
        Housekeeper(
          id: 'housekeeper-$index',
          displayName: 'Housekeeper $index',
          paletteKey: 'ruby',
          updatedAt: now,
        ),
    ];

    final result = _session(now).replaceAllRoomAssignments(
      roomNumbers: const AllRoomsTestDataGenerator().shuffledRoomNumbers(
        Random(11),
      ),
      housekeepers: housekeepers,
      changedAt: now.add(const Duration(minutes: 1)),
    );

    expect(result.session.activeAssignments, hasLength(100));
    expect(
      result.session.activeAssignments
          .map((assignment) => assignment.cartNumber)
          .reduce((left, right) => left > right ? left : right),
      100,
    );
  });
}

WorkSession _session(DateTime now) {
  WorkAssignment assignment(String id, int cart, String name) {
    return WorkAssignment.create(
      id: id,
      cartNumber: cart,
      housekeeper: Housekeeper(
        id: name.toLowerCase(),
        displayName: name,
        paletteKey: 'ruby',
        updatedAt: now,
      ),
      assignedAt: now,
    );
  }

  return WorkSession.create(
        id: 'session-1',
        hotel: HotelProfile.margaritaville,
        startedAt: now,
        assignments: [
          assignment('cart-1', 1, 'Ketty'),
          assignment('cart-2', 2, 'Omelene'),
        ],
      )
      .assignRoom(assignmentId: 'cart-1', roomNumber: '101', changedAt: now)
      .session;
}

final class _RecordingRepository implements WorkSessionRepository {
  WorkSession? session;
  int writeCount = 0;

  @override
  Future<WorkSession?> loadLatestSession() async => session;

  @override
  Future<WorkSession?> loadSession(String sessionId) async => session;

  @override
  Future<void> replaceSession(WorkSession session) async {
    this.session = session;
    writeCount++;
  }

  @override
  Stream<WorkSession?> watchLatestSession() => Stream.value(session);
}
