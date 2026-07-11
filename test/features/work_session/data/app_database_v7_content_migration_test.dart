import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/shared/persistence/app_database.dart';

import '../../../generated_migrations/schema.dart';

void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('v6 to v9 preserves room media and adds assignment content', () async {
    final schema = await verifier.schemaAt(6);
    addTearDown(schema.close);
    final raw = schema.rawDatabase;
    _seedSession(schema);
    raw.execute('''
      INSERT INTO media_manifest_records (
        id, session_id, room_number, kind, relative_path, checksum_sha256,
        origin_device_id, created_at, updated_at
      ) VALUES (
        'room-photo', 'session-v7', '101', 'photo', 'Media/room-photo.jpg',
        'sha256-room-photo', 'device-1', '2027-02-10T12:30:00.000Z',
        '2027-02-10T12:30:00.000Z'
      )
    ''');

    final database = AppDatabase.forTesting(schema.newConnection());
    await verifier.migrateAndValidate(database, 9);

    expect(
      (await database.select(database.mediaManifestRecords).get()).single.id,
      'room-photo',
    );
    expect(
      await database.select(database.assignmentNoteRecords).get(),
      isEmpty,
    );
    expect(
      await database.select(database.cartConsumableRecords).get(),
      isEmpty,
    );

    await database
        .into(database.assignmentNoteRecords)
        .insert(
          AssignmentNoteRecordsCompanion.insert(
            sessionId: 'session-v7',
            assignmentId: 'assignment-1',
            textValue: 'Тележка готова',
            updatedAtMicros: DateTime.utc(
              2027,
              2,
              10,
              13,
            ).microsecondsSinceEpoch,
          ),
        );
    await database
        .into(database.cartConsumableRecords)
        .insert(
          CartConsumableRecordsCompanion.insert(
            sessionId: 'session-v7',
            assignmentId: 'assignment-1',
            itemId: 'bath_towel',
            title: 'Полотенца банные',
            quantity: 4,
            updatedAtMicros: DateTime.utc(
              2027,
              2,
              10,
              13,
            ).microsecondsSinceEpoch,
            lastCommandId: 'command-consumable',
          ),
        );
    expect(
      (await database.select(database.cartConsumableRecords).get())
          .single
          .quantity,
      4,
    );
    await database.close();
  });

  test('v7 database rejects missing and dual media owners', () async {
    final database = AppDatabase.inMemory();
    addTearDown(database.close);
    await _insertSession(database);

    Future<void> insertOwner({String? room, String? assignment}) {
      return database
          .into(database.mediaManifestRecords)
          .insert(
            MediaManifestRecordsCompanion.insert(
              id: 'media-${room ?? assignment ?? 'none'}-$room-$assignment',
              sessionId: 'session-v7',
              assignmentId: Value(assignment),
              roomNumber: Value(room),
              kind: 'photo',
              relativePath: 'Media/owner.jpg',
              checksumSha256: 'sha256-owner',
              originDeviceId: 'device-1',
              createdAt: DateTime.utc(2027, 2, 10, 13),
              updatedAt: DateTime.utc(2027, 2, 10, 13),
            ),
          );
    }

    await insertOwner(room: '101');
    await insertOwner(assignment: 'assignment-1');
    await expectLater(insertOwner(), throwsA(anything));
    await expectLater(insertOwner(room: '  '), throwsA(anything));
    await expectLater(insertOwner(assignment: ''), throwsA(anything));
    await expectLater(
      insertOwner(room: '102', assignment: 'assignment-1'),
      throwsA(anything),
    );
  });

  test('v7 database constrains consumable quantity to donor range', () async {
    final database = AppDatabase.inMemory();
    addTearDown(database.close);
    await _insertSession(database);

    await expectLater(
      database
          .into(database.cartConsumableRecords)
          .insert(
            CartConsumableRecordsCompanion.insert(
              sessionId: 'session-v7',
              assignmentId: 'assignment-1',
              itemId: 'bath_towel',
              title: 'Полотенца банные',
              quantity: 11,
              updatedAtMicros: DateTime.utc(
                2027,
                2,
                10,
                13,
              ).microsecondsSinceEpoch,
              lastCommandId: 'command-invalid',
            ),
          ),
      throwsA(anything),
    );
  });
}

void _seedSession(InitializedSchema schema) {
  schema.rawDatabase.execute('''
    INSERT INTO work_session_records (
      id, canonical_schema_version, hotel_id, hotel_name, workflow,
      started_at, updated_at, workday_locked
    ) VALUES (
      'session-v7', 2, 'hotel-1', 'Margaritaville', 'simpleCycle',
      '2027-02-10T12:00:00.000Z', '2027-02-10T12:30:00.000Z', 0
    )
  ''');
}

Future<void> _insertSession(AppDatabase database) {
  return database
      .into(database.workSessionRecords)
      .insert(
        WorkSessionRecordsCompanion.insert(
          id: 'session-v7',
          canonicalSchemaVersion: 2,
          hotelId: 'hotel-1',
          hotelName: 'Margaritaville',
          workflow: 'simpleCycle',
          startedAt: DateTime.utc(2027, 2, 10, 12),
          updatedAt: DateTime.utc(2027, 2, 10, 12, 30),
        ),
      );
}
