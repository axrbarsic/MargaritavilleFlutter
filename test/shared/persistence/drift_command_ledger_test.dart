import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/shared/persistence/app_database.dart';
import 'package:margaritaville_flutter/shared/persistence/drift_command_ledger.dart';

void main() {
  late AppDatabase database;
  late DriftCommandLedger ledger;

  setUp(() async {
    database = AppDatabase.inMemory();
    ledger = DriftCommandLedger(database);
    await _insertSession(database);
  });

  tearDown(() => database.close());

  test(
    'changed mutation atomically writes receipt history and outbox',
    () async {
      var mutationCount = 0;
      final envelope = _envelope('command-1');

      expect(
        await ledger.commit(
          envelope: envelope,
          mutate: () async {
            mutationCount++;
            return true;
          },
        ),
        CommandLedgerStatus.applied,
      );
      expect(
        await ledger.commit(
          envelope: envelope,
          mutate: () async {
            mutationCount++;
            return true;
          },
        ),
        CommandLedgerStatus.duplicate,
      );

      expect(mutationCount, 1);
      expect(
        await database.select(database.commandReceiptRecords).get(),
        hasLength(1),
      );
      expect(
        await database.select(database.historyEventRecords).get(),
        hasLength(1),
      );
      expect(
        await database.select(database.syncOutboxRecords).get(),
        hasLength(1),
      );
    },
  );

  test('same ID with a different fingerprint is rejected', () async {
    final original = _envelope('command-conflict');
    await ledger.commit(envelope: original, mutate: () async => true);

    await expectLater(
      ledger.commit(
        envelope: _envelope('command-conflict', semanticValue: 'different'),
        mutate: () async => true,
      ),
      throwsStateError,
    );
  });

  test('ignored mutation has receipt but no event or outbox', () async {
    final status = await ledger.commit(
      envelope: _envelope('command-ignored'),
      mutate: () async => false,
    );

    expect(status, CommandLedgerStatus.ignored);
    expect(
      (await database.select(database.commandReceiptRecords).get())
          .single
          .outcome,
      'ignored',
    );
    expect(await database.select(database.historyEventRecords).get(), isEmpty);
    expect(await database.select(database.syncOutboxRecords).get(), isEmpty);
  });

  test('event collision rolls back projection and receipt', () async {
    final envelope = _envelope('collision');
    await database.customStatement('''
      INSERT INTO history_event_records (
        id, session_id, command_id, event_type, event_version,
        payload_json, happened_at
      ) VALUES (
        '${envelope.eventId}', 'session-1', 'existing', 'sentinel', 1,
        '{}', '2027-02-10T12:00:00Z'
      )
    ''');

    await expectLater(
      ledger.commit(
        envelope: envelope,
        mutate: () async {
          await database
              .into(database.assignmentNoteRecords)
              .insert(
                AssignmentNoteRecordsCompanion.insert(
                  sessionId: 'session-1',
                  assignmentId: 'assignment-1',
                  textValue: 'must roll back',
                  updatedAtMicros: envelope.issuedAt.microsecondsSinceEpoch,
                ),
              );
          return true;
        },
      ),
      throwsA(anything),
    );

    expect(
      await database.select(database.assignmentNoteRecords).get(),
      isEmpty,
    );
    expect(
      await database.select(database.commandReceiptRecords).get(),
      isEmpty,
    );
    expect(await database.select(database.syncOutboxRecords).get(), isEmpty);
  });

  test('event payload never contains private content fields', () async {
    await ledger.commit(
      envelope: _envelope('privacy'),
      mutate: () async => true,
    );
    final payload =
        jsonDecode(
              (await database.select(database.historyEventRecords).get())
                  .single
                  .payloadJson,
            )
            as Map<String, Object?>;
    expect(payload, {'assignmentId': 'assignment-1'});
    expect(payload.toString(), isNot(contains('secret note')));
    expect(payload.toString(), isNot(contains('/private/path')));
  });
}

CommandLedgerEnvelope _envelope(
  String commandId, {
  String semanticValue = 'secret note',
}) {
  final issuedAt = DateTime.utc(2027, 2, 10, 12, 30, 0, 123, 456);
  return CommandLedgerEnvelope(
    sessionId: 'session-1',
    commandId: commandId,
    commandVersion: 1,
    commandType: 'assignment.note.save',
    commandFingerprint: CommandLedgerEnvelope.fingerprint({
      'assignmentId': 'assignment-1',
      'text': semanticValue,
      'path': '/private/path',
    }),
    issuedAt: issuedAt,
    eventId: 'content:session-1:$commandId',
    eventType: 'assignment.note.updated',
    eventPayload: const {'assignmentId': 'assignment-1'},
  );
}

Future<void> _insertSession(AppDatabase database) {
  return database
      .into(database.workSessionRecords)
      .insert(
        WorkSessionRecordsCompanion.insert(
          id: 'session-1',
          canonicalSchemaVersion: 2,
          hotelId: 'hotel-1',
          hotelName: 'Margaritaville',
          workflow: 'simpleCycle',
          startedAt: DateTime.utc(2027, 2, 10, 12),
          updatedAt: DateTime.utc(2027, 2, 10, 12),
        ),
      );
}
