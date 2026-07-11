import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/work_session/application/all_rooms_test_data_generator.dart';
import 'package:margaritaville_flutter/features/work_session/application/commands/work_session_command.dart';
import 'package:margaritaville_flutter/features/work_session/application/work_session_command_handler.dart';
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

      final result = await handler.execute(
        session,
        ReplaceAllRoomAssignmentsCommand(
          commandId: 'all-rooms-1',
          issuedAt: now.add(const Duration(minutes: 1)),
          roomNumbers: roomNumbers,
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
        persisted.activeAssignments.map((assignment) => assignment.id),
        session.activeAssignments.map((assignment) => assignment.id),
      );
      expect(
        persisted.activeAssignments.map(
          (assignment) => assignment.housekeeper.id,
        ),
        session.activeAssignments.map(
          (assignment) => assignment.housekeeper.id,
        ),
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
    },
  );
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
