import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value, Variable;
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/work_session/data/repositories/drift_housekeeper_catalog_repository.dart';
import 'package:margaritaville_flutter/features/work_session/data/repositories/drift_work_session_repository.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/housekeeper.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_session.dart';
import 'package:margaritaville_flutter/shared/persistence/app_database.dart';

void main() {
  late AppDatabase database;
  late DriftWorkSessionRepository repository;

  setUp(() {
    database = AppDatabase.inMemory();
    repository = DriftWorkSessionRepository(database);
  });

  tearDown(() => database.close());

  test(
    'replaces and reloads the normalized work-session graph atomically',
    () async {
      final fixture =
          jsonDecode(
                File(
                  'test/fixtures/canonical_work_session_v2.json',
                ).readAsStringSync(),
              )
              as Map<String, Object?>;
      final session = WorkSession.fromJson(fixture);

      await repository.replaceSession(session);
      final loaded = await repository.loadSession(session.id);

      expect(loaded?.toJson(), session.toJson());

      final reset = session.resetRoom(
        roomNumber: '101',
        changedAt: DateTime.utc(2027, 2, 10, 13),
      );
      expect(reset.status.name, 'changed');
      await repository.replaceSession(reset.session);

      final reloaded = await repository.loadSession(session.id);
      expect(reloaded?.room('101')?.phase.name, 'pending');
      expect(reloaded?.room('101')?.timestamps.openedAt, isNotNull);
    },
  );

  test('session graph replacement preserves all durable projections', () async {
    final session = _canonicalSession();
    await repository.replaceSession(session);
    await _insertSessionProjections(database, session.id);

    final next = session
        .resetRoom(roomNumber: '101', changedAt: DateTime.utc(2027, 2, 10, 13))
        .session;
    await repository.replaceSession(next);

    final history = await database.select(database.historyEventRecords).get();
    final outbox = await database.select(database.syncOutboxRecords).get();
    final media = await database.select(database.mediaManifestRecords).get();
    final notes = await database.select(database.roomNoteRecords).get();
    final receipts = await database
        .select(database.commandReceiptRecords)
        .get();
    expect(
      [
        history.length,
        outbox.length,
        media.length,
        notes.length,
        receipts.length,
      ],
      [1, 1, 1, 1, 1],
      reason:
          'Replacing the mutable session graph must not cascade-delete '
          'durable audit, sync, or media projections.',
    );
    expect(history.single.commandId, 'note-command-1');
    expect(outbox.single.eventId, history.single.id);
    expect(media.single.roomNumber, '101');
    expect(notes.single.textValue, 'Inspection note');
    expect(receipts.single.outcome, 'applied');
  });

  test(
    'session graph replacement keeps parent row identity and round-trip',
    () async {
      final session = _canonicalSession();
      await repository.replaceSession(session);
      await _insertSentinelSession(database);
      final identityBefore = await _sessionRowIdentity(database, session.id);

      final next = session
          .resetRoom(
            roomNumber: '101',
            changedAt: DateTime.utc(2027, 2, 10, 13),
          )
          .session;
      await repository.replaceSession(next);

      final identityAfter = await _sessionRowIdentity(database, session.id);
      final reloaded = await repository.loadSession(session.id);
      expect(
        identityAfter,
        identityBefore,
        reason:
            'The parent session row must be updated in place instead of '
            'deleted and reinserted.',
      );
      expect(reloaded?.toJson(), next.toJson());
    },
  );

  test(
    'session graph replacement leaves unrelated sessions untouched',
    () async {
      final session = _canonicalSession();
      await repository.replaceSession(session);
      await _insertSentinelSession(database);

      final next = session
          .resetRoom(
            roomNumber: '101',
            changedAt: DateTime.utc(2027, 2, 10, 13),
          )
          .session;
      await repository.replaceSession(next);

      final sentinel = await repository.loadSession('sentinel-session');
      final foreignKeyFailures = await database
          .customSelect('PRAGMA foreign_key_check')
          .get();
      expect(sentinel?.id, 'sentinel-session');
      expect(sentinel?.assignments, isEmpty);
      expect(foreignKeyFailures, isEmpty);
    },
  );

  test(
    'active assignment resolves the current persistent catalog name',
    () async {
      final now = DateTime.utc(2027, 2, 10, 12);
      final catalog = DriftHousekeeperCatalogRepository(database);
      await catalog.ensureDefaults(now);
      final session = _canonicalSession();
      await repository.replaceSession(session);
      final assignment = session.activeAssignments.first;
      await catalog.save(
        Housekeeper(
          id: assignment.housekeeper.id,
          displayName: 'Renamed in catalog',
          paletteKey: assignment.housekeeper.paletteKey,
          updatedAt: now.add(const Duration(minutes: 1)),
        ),
        sortOrder: 7,
      );

      final reloaded = await repository.loadSession(session.id);

      expect(
        reloaded?.activeAssignments.first.housekeeper.displayName,
        'Renamed in catalog',
      );
    },
  );
}

WorkSession _canonicalSession() {
  final fixture =
      jsonDecode(
            File(
              'test/fixtures/canonical_work_session_v2.json',
            ).readAsStringSync(),
          )
          as Map<String, Object?>;
  return WorkSession.fromJson(fixture);
}

Future<void> _insertSessionProjections(
  AppDatabase database,
  String sessionId,
) async {
  final happenedAt = DateTime.utc(2027, 2, 10, 12, 45);
  await database
      .into(database.roomNoteRecords)
      .insert(
        RoomNoteRecordsCompanion.insert(
          sessionId: sessionId,
          roomNumber: '101',
          textValue: 'Inspection note',
          updatedAt: happenedAt,
          lastCommandId: const Value('note-command-1'),
        ),
      );
  await database
      .into(database.commandReceiptRecords)
      .insert(
        CommandReceiptRecordsCompanion.insert(
          sessionId: sessionId,
          commandId: 'note-command-1',
          outcome: 'applied',
          processedAt: happenedAt,
        ),
      );
  await database
      .into(database.historyEventRecords)
      .insert(
        HistoryEventRecordsCompanion.insert(
          id: 'note-event-1',
          sessionId: sessionId,
          commandId: 'note-command-1',
          eventType: 'room.note.updated',
          payloadJson: '{"roomNumber":"101"}',
          happenedAt: happenedAt,
        ),
      );
  await database
      .into(database.syncOutboxRecords)
      .insert(
        SyncOutboxRecordsCompanion.insert(
          eventId: 'note-event-1',
          sessionId: sessionId,
        ),
      );
  await database
      .into(database.mediaManifestRecords)
      .insert(
        MediaManifestRecordsCompanion.insert(
          id: 'media-1',
          sessionId: sessionId,
          roomNumber: const Value('101'),
          kind: 'photo',
          relativePath: 'rooms/101/photo.jpg',
          checksumSha256: 'sha256-placeholder',
          originDeviceId: 'device-1',
          createdAt: happenedAt,
          updatedAt: happenedAt,
        ),
      );
}

Future<void> _insertSentinelSession(AppDatabase database) {
  final startedAt = DateTime.utc(2027, 2, 10, 11);
  return database
      .into(database.workSessionRecords)
      .insert(
        WorkSessionRecordsCompanion.insert(
          id: 'sentinel-session',
          canonicalSchemaVersion: 2,
          hotelId: 'margaritaville',
          hotelName: 'Margaritaville',
          workflow: 'simpleCycle',
          startedAt: startedAt,
          updatedAt: startedAt,
        ),
      );
}

Future<int> _sessionRowIdentity(AppDatabase database, String sessionId) async {
  final row = await database
      .customSelect(
        'SELECT rowid AS row_identity FROM work_session_records WHERE id = ?',
        variables: [Variable<String>(sessionId)],
        readsFrom: {database.workSessionRecords},
      )
      .getSingle();
  return row.read<int>('row_identity');
}
