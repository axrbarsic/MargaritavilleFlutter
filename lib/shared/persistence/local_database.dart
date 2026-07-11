import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/room_content_tables.dart';
import 'tables/sync_contract_tables.dart';
import 'tables/work_session_tables.dart';

part 'local_database.g.dart';
part 'local_database_migrations.dart';

@DriftDatabase(
  tables: [
    HousekeeperCatalogRecords,
    WorkSessionRecords,
    HousekeeperRecords,
    WorkAssignmentRecords,
    RoomStateRecords,
    RoomNoteRecords,
    AssignmentNoteRecords,
    CartConsumableRecords,
    HistoryEventRecords,
    CommandReceiptRecords,
    SyncOutboxRecords,
    SyncInboxRecords,
    MediaManifestRecords,
    MediaPromotionRecords,
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
  int get schemaVersion => 9;

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
                if (to >= 4) mediaManifestRecords.lastCommandId,
                if (to >= 5) ...[
                  mediaManifestRecords.byteLength,
                  mediaManifestRecords.widthPixels,
                  mediaManifestRecords.heightPixels,
                  mediaManifestRecords.originalExtension,
                  mediaManifestRecords.orientation,
                  mediaManifestRecords.colorSpace,
                  mediaManifestRecords.isHdr,
                ],
              ],
              columnTransformer: {
                mediaManifestRecords.createdAt: mediaManifestRecords.updatedAt,
              },
            ),
          );
          if (to >= 5) {
            await migrator.createTable(mediaPromotionRecords);
          }
          if (to >= 7) {
            await _upgradeAssignmentContentV7(migrator);
          }
          if (to >= 8) await _upgradeWorkSetupV8(migrator);
          if (to >= 9) await _upgradeHousekeeperCatalogV9(migrator);
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
          if (to >= 5) {
            await _upgradeMediaFoundationV5(migrator);
          }
          if (to >= 7) {
            await _upgradeAssignmentContentV7(migrator);
          }
          if (to >= 8) await _upgradeWorkSetupV8(migrator);
          if (to >= 9) await _upgradeHousekeeperCatalogV9(migrator);
        });
        return;
      }
      if (from == 4 && to >= 5) {
        await transaction(() async {
          await _upgradeMediaFoundationV5(migrator);
          if (to >= 7) {
            await _upgradeAssignmentContentV7(migrator);
          }
          if (to >= 8) await _upgradeWorkSetupV8(migrator);
          if (to >= 9) await _upgradeHousekeeperCatalogV9(migrator);
        });
        return;
      }
      if (from == 5 && to >= 6) {
        await transaction(() async {
          await _repairPreReleaseMediaJournalV6(migrator);
          if (to >= 7) {
            await _upgradeAssignmentContentV7(migrator);
          }
          if (to >= 8) await _upgradeWorkSetupV8(migrator);
          if (to >= 9) await _upgradeHousekeeperCatalogV9(migrator);
        });
        return;
      }
      if (from == 6 && to >= 7) {
        await transaction(() async {
          await _upgradeAssignmentContentV7(migrator);
          if (to >= 8) await _upgradeWorkSetupV8(migrator);
          if (to >= 9) await _upgradeHousekeeperCatalogV9(migrator);
        });
        return;
      }
      if (from == 7 && to >= 8) {
        await transaction(() async {
          await _upgradeWorkSetupV8(migrator);
          if (to >= 9) await _upgradeHousekeeperCatalogV9(migrator);
        });
        return;
      }
      if (from == 8 && to >= 9) {
        await transaction(() => _upgradeHousekeeperCatalogV9(migrator));
        return;
      }
      throw UnsupportedError('Unsupported database upgrade $from -> $to');
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
