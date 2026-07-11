import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/shared/persistence/app_database.dart';

import '../../../generated_migrations/schema.dart';

void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('canonical v5 to v9 preserves journal and adds content owner', () async {
    final schema = await verifier.schemaAt(5);
    addTearDown(schema.close);
    _seedSession(schema);
    schema.rawDatabase.execute('''
      INSERT INTO media_promotion_records (
        operation_id, command_id, media_id, session_id, room_number, kind,
        staged_relative_path, transient_file_path, final_relative_path,
        checksum_sha256, byte_length, origin_device_id, created_at, issued_at,
        mime_type, original_extension
      ) VALUES (
        'operation-v5', 'command-v5', 'media-v5', 'session-v5', '147', 'photo',
        'Media/.staging/media-v5.jpg.partial', '/camera/photo-v5.jpg',
        'Media/media-v5.jpg',
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
        42, 'device-v5', '2027-02-10T12:30:00.000Z',
        '2027-02-10T12:30:00.000Z', 'image/jpeg', 'jpg'
      )
    ''');

    final database = AppDatabase.forTesting(schema.newConnection());
    await verifier.migrateAndValidate(database, 9);

    final journal = await database.select(database.mediaPromotionRecords).get();
    expect(journal.single.operationId, 'operation-v5');
    expect(journal.single.transientFilePath, '/camera/photo-v5.jpg');
    await database.close();
  });

  test('intermediate physical v5 journal repairs safely into v9', () async {
    final schema = await verifier.schemaAt(5);
    addTearDown(schema.close);
    _seedSession(schema);
    final raw = schema.rawDatabase;
    raw.execute('ALTER TABLE media_promotion_records RENAME TO canonical_v5');
    raw.execute(_intermediateJournalSql);
    raw.execute('''
      INSERT INTO media_promotion_records (
        operation_id, command_id, media_id, session_id, room_number, kind,
        staged_relative_path, final_relative_path, checksum_sha256, byte_length,
        origin_device_id, created_at, issued_at, mime_type, original_extension
      ) VALUES (
        'operation-v5', 'command-v5', 'media-v5', 'session-v5', '147', 'photo',
        'Media/.staging/media-v5.jpg.partial', 'Media/media-v5.jpg',
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
        42, 'device-v5', '2027-02-10T12:30:00.000Z',
        '2027-02-10T12:30:00.000Z', 'image/jpeg', 'jpg'
      )
    ''');
    raw.execute('DROP TABLE canonical_v5');

    final database = AppDatabase.forTesting(schema.newConnection());
    await verifier.migrateAndValidate(database, 9);

    final journal = await database.select(database.mediaPromotionRecords).get();
    expect(journal, hasLength(1));
    expect(journal.single.operationId, 'operation-v5');
    expect(
      journal.single.transientFilePath,
      '/tmp/margaritaville-recovery-missing-source',
    );
    expect(journal.single.quarantinedAt, isNull);
    expect(journal.single.failureReason, isNull);
    await database.close();
  });
}

void _seedSession(InitializedSchema schema) {
  schema.rawDatabase.execute('''
    INSERT INTO work_session_records (
      id, canonical_schema_version, hotel_id, hotel_name, workflow,
      started_at, updated_at, workday_locked
    ) VALUES (
      'session-v5', 2, 'hotel-1', 'Margaritaville', 'simpleCycle',
      '2027-02-10T12:00:00.000Z', '2027-02-10T12:30:00.000Z', 0
    )
  ''');
}

const _intermediateJournalSql = '''
  CREATE TABLE media_promotion_records (
    operation_id TEXT NOT NULL PRIMARY KEY,
    command_id TEXT NOT NULL,
    media_id TEXT NOT NULL UNIQUE,
    session_id TEXT NOT NULL REFERENCES work_session_records(id)
      ON DELETE CASCADE,
    room_number TEXT NOT NULL,
    assignment_id TEXT,
    kind TEXT NOT NULL,
    staged_relative_path TEXT NOT NULL,
    final_relative_path TEXT NOT NULL,
    checksum_sha256 TEXT NOT NULL,
    byte_length INTEGER NOT NULL,
    origin_device_id TEXT NOT NULL,
    created_at TEXT NOT NULL,
    issued_at TEXT NOT NULL,
    mime_type TEXT,
    duration_ms INTEGER,
    transcript TEXT,
    width_pixels INTEGER,
    height_pixels INTEGER,
    original_extension TEXT,
    orientation INTEGER,
    color_space TEXT,
    is_hdr INTEGER CHECK (is_hdr IN (0, 1))
  )
''';
