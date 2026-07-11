import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/shared/persistence/app_database.dart';
import 'package:margaritaville_flutter/shared/persistence/drift_command_ledger.dart';

void main() {
  test(
    'event payload can be derived from authoritative mutation result',
    () async {
      final database = AppDatabase.inMemory();
      addTearDown(database.close);
      Map<String, Object?>? authoritativePayload;
      final envelope = CommandLedgerEnvelope.forAggregate(
        aggregateType: 'housekeeper-catalog',
        aggregateId: 'margaritaville',
        commandId: 'authoritative-event',
        commandVersion: 1,
        commandType: 'test.aggregate',
        commandFingerprint: CommandLedgerEnvelope.fingerprint(const {
          'value': 1,
        }),
        issuedAt: DateTime.utc(2027, 2, 10, 13),
        eventId: 'housekeeper-catalog:margaritaville:authoritative-event',
        eventType: 'test.aggregate.changed',
        eventPayload: const {},
      );

      final status = await DriftCommandLedger(database).commit(
        envelope: envelope,
        mutate: () async {
          authoritativePayload = const {
            'housekeeperId': 'zoe-2',
            'changedFields': ['displayName', 'paletteKey'],
          };
          return true;
        },
        eventPayloadAfterMutation: () => authoritativePayload!,
      );

      expect(status, CommandLedgerStatus.applied);
      final event = await database
          .select(database.historyEventRecords)
          .getSingle();
      expect(jsonDecode(event.payloadJson), authoritativePayload);
    },
  );
}
