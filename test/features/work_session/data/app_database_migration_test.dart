import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/shared/persistence/app_database.dart';

import '../../../generated_migrations/schema.dart';

void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('v2 to v6 preserves data and adds durable media promotion', () async {
    final schema = await verifier.schemaAt(2);
    addTearDown(schema.close);
    _seedV2(schema);

    final database = AppDatabase.forTesting(schema.newConnection());
    await verifier.migrateAndValidate(database, 6);

    final sessions = await database.select(database.workSessionRecords).get();
    final history = await database.select(database.historyEventRecords).get();
    final outbox = await database.select(database.syncOutboxRecords).get();
    final media = await database.select(database.mediaManifestRecords).get();
    final notes = await database.select(database.roomNoteRecords).get();
    final receipts = await database
        .select(database.commandReceiptRecords)
        .get();
    final foreignKeyFailures = await database
        .customSelect('PRAGMA foreign_key_check')
        .get();

    expect(sessions.single.id, 'session-1');
    expect(history.single.commandId, 'command-1');
    expect(outbox.single.eventId, 'event-1');
    expect(media.single.id, 'media-1');
    expect(media.single.createdAt, media.single.updatedAt);
    expect(media.single.mimeType, isNull);
    expect(media.single.durationMs, isNull);
    expect(media.single.transcript, isNull);
    expect(media.single.lastCommandId, isNull);
    expect(media.single.byteLength, isNull);
    expect(media.single.widthPixels, isNull);
    expect(media.single.heightPixels, isNull);
    expect(media.single.originalExtension, isNull);
    expect(media.single.orientation, isNull);
    expect(media.single.colorSpace, isNull);
    expect(media.single.isHdr, isNull);
    expect(
      await database.select(database.mediaPromotionRecords).get(),
      isEmpty,
    );
    expect(notes, isEmpty);
    expect(receipts, hasLength(1));
    expect(receipts.single.commandId, 'command-1');
    expect(receipts.single.commandVersion, 1);
    expect(receipts.single.outcome, 'applied');
    expect(foreignKeyFailures, isEmpty);
    await database.customStatement('''
        INSERT INTO history_event_records (
          id, session_id, command_id, event_type, event_version,
          payload_json, happened_at
        ) VALUES (
          'event-duplicate', 'session-1', 'command-1', 'duplicate', 1,
          '{}', '2027-02-10T12:31:00.000Z'
        )
      ''');
    final migratedHistory = await database
        .select(database.historyEventRecords)
        .get();
    expect(migratedHistory, hasLength(2));

    await expectLater(
      database.customStatement('''
        INSERT INTO command_receipt_records (
          session_id, command_id, command_version, outcome, processed_at
        ) VALUES (
          'session-1', 'command-1', 1, 'duplicate',
          '2027-02-10T12:32:00.000Z'
        )
      '''),
      throwsA(anything),
    );

    await database.close();
  });

  test(
    'v3 to v6 preserves notes and media while adding media journal',
    () async {
      final schema = await verifier.schemaAt(3);
      addTearDown(schema.close);
      final raw = schema.rawDatabase;
      raw.execute('''
      INSERT INTO work_session_records (
        id, canonical_schema_version, hotel_id, hotel_name, workflow,
        started_at, updated_at, workday_locked
      ) VALUES (
        'session-v3', 2, 'hotel-1', 'Margaritaville', 'simpleCycle',
        '2027-02-10T12:00:00.000Z', '2027-02-10T12:30:00.000Z', 0
      )
    ''');
      raw.execute('''
      INSERT INTO room_note_records (
        session_id, room_number, text_value, updated_at
      ) VALUES (
        'session-v3', '101', 'legacy local note',
        '2027-02-10T12:30:00.000Z'
      )
    ''');
      raw.execute('''
      INSERT INTO media_manifest_records (
        id, session_id, room_number, kind, relative_path, checksum_sha256,
        origin_device_id, created_at, updated_at
      ) VALUES (
        'media-v3', 'session-v3', '101', 'photo', 'rooms/101/photo.jpg',
        'sha256-v3', 'device-1', '2027-02-10T12:30:00.000Z',
        '2027-02-10T12:30:00.000Z'
      )
    ''');

      final database = AppDatabase.forTesting(schema.newConnection());
      await verifier.migrateAndValidate(database, 6);

      final notes = await database.select(database.roomNoteRecords).get();
      final media = await database.select(database.mediaManifestRecords).get();
      expect(notes.single.textValue, 'legacy local note');
      expect(notes.single.lastCommandId, isNull);
      expect(media.single.id, 'media-v3');
      expect(media.single.lastCommandId, isNull);
      expect(media.single.byteLength, isNull);
      expect(
        await database.select(database.mediaPromotionRecords).get(),
        isEmpty,
      );
      await database.close();
    },
  );

  test('v4 to v6 preserves manifest and creates an empty journal', () async {
    final schema = await verifier.schemaAt(4);
    addTearDown(schema.close);
    final raw = schema.rawDatabase;
    raw.execute('''
      INSERT INTO work_session_records (
        id, canonical_schema_version, hotel_id, hotel_name, workflow,
        started_at, updated_at, workday_locked
      ) VALUES (
        'session-v4', 2, 'hotel-1', 'Margaritaville', 'simpleCycle',
        '2027-02-10T12:00:00.000Z', '2027-02-10T12:30:00.000Z', 0
      )
    ''');
    raw.execute('''
      INSERT INTO media_manifest_records (
        id, session_id, room_number, kind, relative_path, checksum_sha256,
        origin_device_id, created_at, updated_at, last_command_id
      ) VALUES (
        'media-v4', 'session-v4', '101', 'photo', 'Media/photo.jpg',
        'sha256-v4', 'device-1', '2027-02-10T12:30:00.000Z',
        '2027-02-10T12:30:00.000Z', 'command-v4'
      )
    ''');

    final database = AppDatabase.forTesting(schema.newConnection());
    await verifier.migrateAndValidate(database, 6);

    final media = await database.select(database.mediaManifestRecords).get();
    expect(media.single.id, 'media-v4');
    expect(media.single.byteLength, isNull);
    expect(media.single.widthPixels, isNull);
    expect(
      await database.select(database.mediaPromotionRecords).get(),
      isEmpty,
    );
    await database.close();
  });
}

void _seedV2(InitializedSchema schema) {
  final raw = schema.rawDatabase;
  raw.execute('''
    INSERT INTO work_session_records (
      id, canonical_schema_version, hotel_id, hotel_name, workflow,
      started_at, updated_at, workday_locked
    ) VALUES (
      'session-1', 2, 'hotel-1', 'Margaritaville', 'simpleCycle',
      '2027-02-10T12:00:00.000Z', '2027-02-10T12:30:00.000Z', 0
    )
  ''');
  raw.execute('''
    INSERT INTO history_event_records (
      id, session_id, command_id, event_type, event_version,
      payload_json, happened_at
    ) VALUES (
      'event-1', 'session-1', 'command-1', 'room.media.added', 9,
      '{"roomNumber":"101"}', '2027-02-10T12:30:00.000Z'
    )
  ''');
  raw.execute('''
    INSERT INTO sync_outbox_records (event_id, session_id, attempt_count)
    VALUES ('event-1', 'session-1', 0)
  ''');
  raw.execute('''
    INSERT INTO media_manifest_records (
      id, session_id, assignment_id, room_number, kind, relative_path,
      checksum_sha256, origin_device_id, updated_at
    ) VALUES (
      'media-1', 'session-1', NULL, '101', 'photo', 'rooms/101/photo.jpg',
      'sha256-placeholder', 'device-1', '2027-02-10T12:30:00.000Z'
    )
  ''');
}
