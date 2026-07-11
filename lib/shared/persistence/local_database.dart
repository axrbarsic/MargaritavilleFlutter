import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/room_content_tables.dart';
import 'tables/sync_contract_tables.dart';
import 'tables/work_session_tables.dart';

part 'local_database.g.dart';

@DriftDatabase(
  tables: [
    WorkSessionRecords,
    HousekeeperRecords,
    WorkAssignmentRecords,
    RoomStateRecords,
    RoomNoteRecords,
    HistoryEventRecords,
    CommandReceiptRecords,
    SyncOutboxRecords,
    SyncInboxRecords,
    MediaManifestRecords,
  ],
)
final class AppDatabase extends _$AppDatabase {
  AppDatabase()
    : super(
        driftDatabase(
          name: 'margaritaville-canonical-v2',
          native: const DriftNativeOptions(shareAcrossIsolates: true),
        ),
      );

  AppDatabase.inMemory() : super(NativeDatabase.memory());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      if (from == 2 && to >= 3) {
        await transaction(() async {
          await migrator.createTable(roomNoteRecords);
          await migrator.createTable(commandReceiptRecords);
          await customStatement('''
            INSERT OR IGNORE INTO command_receipt_records (
              session_id, command_id, command_version, outcome, processed_at
            )
            SELECT
              session_id,
              command_id,
              1,
              'applied',
              MAX(happened_at)
            FROM history_event_records
            GROUP BY session_id, command_id
          ''');
          await migrator.alterTable(
            TableMigration(
              mediaManifestRecords,
              newColumns: [
                mediaManifestRecords.createdAt,
                mediaManifestRecords.mimeType,
                mediaManifestRecords.durationMs,
                mediaManifestRecords.transcript,
                mediaManifestRecords.lastCommandId,
              ],
              columnTransformer: {
                mediaManifestRecords.createdAt: mediaManifestRecords.updatedAt,
              },
            ),
          );
        });
        return;
      }
      if (from == 3 && to >= 4) {
        await transaction(() async {
          await migrator.addColumn(
            roomNoteRecords,
            roomNoteRecords.lastCommandId,
          );
          await migrator.addColumn(
            mediaManifestRecords,
            mediaManifestRecords.lastCommandId,
          );
        });
        return;
      }
      throw UnsupportedError('Unsupported database upgrade $from -> $to');
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
