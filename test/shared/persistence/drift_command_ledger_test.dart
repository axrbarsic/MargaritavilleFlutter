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
        id, aggregate_type, aggregate_id, session_id,
        command_id, event_type, event_version,
        payload_json, happened_at
      ) VALUES (
        '${envelope.eventId}', 'work-session', 'session-1', 'session-1',
        'existing', 'sentinel', 1,
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

  test('app aggregate commits without a synthetic work session', () async {
    final issuedAt = DateTime.utc(2027, 2, 10, 13);
    final envelope = CommandLedgerEnvelope.forAggregate(
      aggregateType: 'housekeeper-catalog',
      aggregateId: 'margaritaville',
      commandId: 'catalog-add-1',
      commandVersion: 1,
      commandType: 'housekeeper_catalog.add',
      commandFingerprint: CommandLedgerEnvelope.fingerprint(const {
        'displayName': 'Zoë',
      }),
      issuedAt: issuedAt,
      eventId: 'housekeeper-catalog:margaritaville:catalog-add-1',
      eventType: 'housekeeper_catalog.added',
      eventPayload: const {'housekeeperId': 'zoe'},
    );

    expect(
      await ledger.commit(envelope: envelope, mutate: () async => true),
      CommandLedgerStatus.applied,
    );

    final receipt = await database
        .select(database.commandReceiptRecords)
        .getSingle();
    final history = await database
        .select(database.historyEventRecords)
        .getSingle();
    final outbox = await database
        .select(database.syncOutboxRecords)
        .getSingle();
    expect(receipt.aggregateType, 'housekeeper-catalog');
    expect(receipt.aggregateId, 'margaritaville');
    expect(receipt.sessionId, isNull);
    expect(history.aggregateId, 'margaritaville');
    expect(history.sessionId, isNull);
    expect(outbox.aggregateId, 'margaritaville');
    expect(outbox.sessionId, isNull);
  });

  test('generic aggregate cannot counterfeit reserved work-session scope', () {
    expect(
      () => _aggregateEnvelope('work-session', 'fake-session', 'reserved'),
      throwsArgumentError,
    );
  });

  test('the same command ID is independent across aggregate scopes', () async {
    await ledger.commit(
      envelope: _aggregateEnvelope('housekeeper-catalog', 'hotel-a', 'same'),
      mutate: () async => true,
    );
    await ledger.commit(
      envelope: _aggregateEnvelope('housekeeper-catalog', 'hotel-b', 'same'),
      mutate: () async => true,
    );

    expect(
      await database.select(database.commandReceiptRecords).get(),
      hasLength(2),
    );
    expect(
      await database.select(database.historyEventRecords).get(),
      hasLength(2),
    );
    expect(
      await database.select(database.syncOutboxRecords).get(),
      hasLength(2),
    );
  });
}

CommandLedgerEnvelope _aggregateEnvelope(
  String aggregateType,
  String aggregateId,
  String commandId,
) {
  return CommandLedgerEnvelope.forAggregate(
    aggregateType: aggregateType,
    aggregateId: aggregateId,
    commandId: commandId,
    commandVersion: 1,
    commandType: 'test.aggregate',
    commandFingerprint: CommandLedgerEnvelope.fingerprint(const {'value': 1}),
    issuedAt: DateTime.utc(2027, 2, 10, 13),
    eventId: '$aggregateType:$aggregateId:$commandId',
    eventType: 'test.aggregate.changed',
    eventPayload: const {},
  );
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
