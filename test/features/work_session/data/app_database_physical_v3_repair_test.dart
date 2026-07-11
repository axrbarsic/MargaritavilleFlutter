import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/shared/persistence/app_database.dart';

import '../../../generated_migrations/schema.dart';

void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test(
    'intermediate physical v3 without receipts repairs and backfills history',
    () async {
      final schema = await verifier.schemaAt(3);
      addTearDown(schema.close);
      final raw = schema.rawDatabase;
      raw.execute('DROP TABLE command_receipt_records');
      raw.execute('''
        INSERT INTO work_session_records (
          id, canonical_schema_version, hotel_id, hotel_name, workflow,
          started_at, updated_at, workday_locked
        ) VALUES (
          'pixel-session', 2, 'margaritaville', 'Margaritaville',
          'simpleCycle', '2027-02-10T12:00:00.000Z',
          '2027-02-10T12:30:00.000Z', 0
        )
      ''');
      raw.execute('''
        INSERT INTO history_event_records (
          id, session_id, command_id, event_type, event_version,
          payload_json, happened_at
        ) VALUES (
          'pixel-event', 'pixel-session', 'pixel-command',
          'room.note.updated', 1, '{"roomNumber":"101"}',
          '2027-02-10T12:31:00.000Z'
        )
      ''');

      final database = AppDatabase.forTesting(schema.newConnection());
      await verifier.migrateAndValidate(database, 9);
      final receipts = await database
          .select(database.commandReceiptRecords)
          .get();

      expect(receipts, hasLength(1));
      expect(receipts.single.sessionId, 'pixel-session');
      expect(receipts.single.commandId, 'pixel-command');
      expect(receipts.single.outcome, 'applied');
      expect(
        await database.select(database.workSessionRecords).get(),
        hasLength(1),
      );
      await database.close();
    },
  );
}
