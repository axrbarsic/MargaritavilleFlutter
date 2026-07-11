import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/shared/persistence/app_database.dart';

import '../../../generated_migrations/schema.dart';

void main() {
  test(
    'v9 to v10 backfills aggregate scope without losing ledger rows',
    () async {
      final verifier = SchemaVerifier(GeneratedHelper());
      final schema = await verifier.schemaAt(9);
      addTearDown(schema.close);
      final raw = schema.rawDatabase;
      raw.execute('''
      INSERT INTO work_session_records (
        id, canonical_schema_version, hotel_id, hotel_name, workflow,
        started_at, updated_at, workday_locked
      ) VALUES (
        'session-v9', 2, 'margaritaville', 'Margaritaville', 'simpleCycle',
        '2027-02-10T12:00:00.000Z', '2027-02-10T12:30:00.000Z', 0
      )
    ''');
      raw.execute('''
      INSERT INTO history_event_records (
        id, session_id, command_id, event_type, event_version,
        payload_json, happened_at
      ) VALUES (
        'event-v9', 'session-v9', 'command-v9', 'sentinel', 1,
        '{}', '2027-02-10T12:30:00.000Z'
      )
    ''');
      raw.execute('''
      INSERT INTO command_receipt_records (
        session_id, command_id, command_version, command_type,
        command_fingerprint, issued_at_micros, outcome, processed_at
      ) VALUES (
        'session-v9', 'command-v9', 1, 'sentinel', 'fingerprint',
        1802262600000000, 'applied', '2027-02-10T12:30:00.000Z'
      )
    ''');
      raw.execute('''
      INSERT INTO sync_outbox_records (
        event_id, session_id, attempt_count, next_attempt_at, acknowledged_at
      ) VALUES (
        'event-v9', 'session-v9', 2, '2027-02-10T13:00:00.000Z',
        '2027-02-10T13:05:00.000Z'
      )
    ''');

      final database = AppDatabase.forTesting(schema.newConnection());
      await verifier.migrateAndValidate(database, 10);

      final receipt = await database
          .select(database.commandReceiptRecords)
          .getSingle();
      final history = await database
          .select(database.historyEventRecords)
          .getSingle();
      final outbox = await database
          .select(database.syncOutboxRecords)
          .getSingle();
      expect(receipt.aggregateType, 'work-session');
      expect(receipt.aggregateId, 'session-v9');
      expect(receipt.sessionId, 'session-v9');
      expect(history.aggregateType, 'work-session');
      expect(history.aggregateId, 'session-v9');
      expect(history.sessionId, 'session-v9');
      expect(outbox.aggregateType, 'work-session');
      expect(outbox.aggregateId, 'session-v9');
      expect(outbox.sessionId, 'session-v9');
      expect(receipt.commandFingerprint, 'fingerprint');
      expect(outbox.attemptCount, 2);
      expect(outbox.nextAttemptAt, DateTime.utc(2027, 2, 10, 13));
      expect(outbox.acknowledgedAt, DateTime.utc(2027, 2, 10, 13, 5));
      expect(
        await database.customSelect('PRAGMA foreign_key_check').get(),
        isEmpty,
      );
      await database.close();
    },
  );
}
