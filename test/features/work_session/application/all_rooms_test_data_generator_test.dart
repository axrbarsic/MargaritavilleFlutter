import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/work_session/application/all_rooms_test_data_generator.dart';
import 'package:margaritaville_flutter/features/work_session/application/commands/work_session_command.dart';
import 'package:margaritaville_flutter/features/work_session/application/work_session_command_handler.dart';
import 'package:margaritaville_flutter/features/work_session/domain/catalogs/margaritaville_housekeeper_catalog.dart';
import 'package:margaritaville_flutter/features/work_session/domain/catalogs/margaritaville_room_catalog.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/hotel_profile.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/housekeeper.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/room_state.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_assignment.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_session.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_session_command_descriptor.dart';
import 'package:margaritaville_flutter/features/work_session/domain/repositories/work_session_repository.dart';

void main() {
  final now = DateTime.utc(2027, 2, 10, 12);

  test('fixture returns every room and housekeeper in deterministic order', () {
    final catalogOrder = MargaritavilleRoomCatalog.territories
        .expand((territory) => territory.rooms)
        .toList(growable: false);
    final housekeepers = MargaritavilleHousekeeperCatalog.housekeepers(now);

    final first = const AllRoomsTestDataGenerator().generate(
      housekeepers: housekeepers,
      changedAt: now,
      seed: 42,
    );
    final second = const AllRoomsTestDataGenerator().generate(
      housekeepers: housekeepers,
      changedAt: now,
      seed: 42,
    );

    expect(first.roomNumbers, hasLength(catalogOrder.length));
    expect(first.roomNumbers.toSet(), catalogOrder.toSet());
    expect(first.roomNumbers, isNot(equals(catalogOrder)));
    expect(first.housekeepers, isNot(equals(housekeepers)));
    expect(_fixtureSignature(first), _fixtureSignature(second));
  });

  test('fixture covers every live status and makes most rooms real VIP', () {
    final fixture = const AllRoomsTestDataGenerator().generate(
      housekeepers: MargaritavilleHousekeeperCatalog.housekeepers(now),
      changedAt: now,
      seed: 42,
    );

    expect(
      fixture.rooms.map((room) => room.displayStatus).toSet(),
      RoomDisplayStatus.values.toSet(),
    );
    expect(
      fixture.rooms.where((room) => room.isVip).length,
      greaterThanOrEqualTo((fixture.rooms.length * 0.6).ceil()),
    );
    expect(fixture.rooms.where((room) => !room.isVip), isNotEmpty);
  });

  test(
    'replacement command persists every room through application path',
    () async {
      final repository = _RecordingRepository();
      final session = _session(now).lockWorkday(changedAt: now);
      final fixture = const AllRoomsTestDataGenerator().generate(
        housekeepers: MargaritavilleHousekeeperCatalog.housekeepers(now),
        changedAt: now.add(const Duration(minutes: 1)),
        seed: 42,
      );
      final handler = WorkSessionCommandHandler(repository);

      final result = await handler.execute(
        session,
        ReplaceAllRoomAssignmentsCommand(
          commandId: 'all-rooms-1',
          issuedAt: now.add(const Duration(minutes: 1)),
          roomNumbers: fixture.roomNumbers,
          housekeepers: fixture.housekeepers,
          testRooms: fixture.rooms,
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
      expect(
        persisted.activeAssignments,
        hasLength(fixture.housekeepers.length),
      );
      expect(
        persisted.activeAssignments
            .map((assignment) => assignment.housekeeper.id)
            .toSet(),
        fixture.housekeepers.map((value) => value.id).toSet(),
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
      expect(
        persisted.activeRooms.map((room) => room.displayStatus).toSet(),
        RoomDisplayStatus.values.toSet(),
      );
      expect(
        persisted.activeRooms.where((room) => room.isVip).length,
        greaterThanOrEqualTo((persistedRooms.length * 0.6).ceil()),
      );
      for (final assignment in persisted.activeAssignments) {
        expect(
          assignment.activeRooms.map((room) => room.displayStatus).toSet(),
          RoomDisplayStatus.values.toSet(),
        );
      }
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
      roomNumbers: const AllRoomsTestDataGenerator()
          .generate(housekeepers: [], changedAt: now, seed: 7)
          .roomNumbers,
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
      roomNumbers: const AllRoomsTestDataGenerator()
          .generate(housekeepers: [], changedAt: now, seed: 11)
          .roomNumbers,
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

List<Object?> _fixtureSignature(AllRoomsTestData fixture) => [
  fixture.roomNumbers,
  fixture.housekeepers.map((value) => value.id).toList(growable: false),
  fixture.rooms.map((room) => room.toJson()).toList(growable: false),
];

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
  Future<WorkSessionMutation> commitCommand({
    required WorkSession fallbackSession,
    required WorkSessionCommandDescriptor descriptor,
    required WorkSessionMutation Function(WorkSession session) mutate,
  }) async {
    final result = mutate(session ?? fallbackSession);
    if (result.status == WorkSessionMutationStatus.changed) {
      session = result.session;
      writeCount++;
    }
    return result;
  }

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
