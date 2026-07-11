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
  int get schemaVersion => 6;

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
        });
        return;
      }
      if (from == 4 && to >= 5) {
        await transaction(() async {
          await _upgradeMediaFoundationV5(migrator);
        });
        return;
      }
      if (from == 5 && to >= 6) {
        await transaction(() async {
          await _repairPreReleaseMediaJournalV6(migrator);
        });
        return;
      }
      throw UnsupportedError('Unsupported database upgrade $from -> $to');
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _upgradeMediaFoundationV5(Migrator migrator) async {
    await migrator.createTable(mediaPromotionRecords);
    await migrator.addColumn(
      mediaManifestRecords,
      mediaManifestRecords.byteLength,
    );
    await migrator.addColumn(
      mediaManifestRecords,
      mediaManifestRecords.widthPixels,
    );
    await migrator.addColumn(
      mediaManifestRecords,
      mediaManifestRecords.heightPixels,
    );
    await migrator.addColumn(
      mediaManifestRecords,
      mediaManifestRecords.originalExtension,
    );
    await migrator.addColumn(
      mediaManifestRecords,
      mediaManifestRecords.orientation,
    );
    await migrator.addColumn(
      mediaManifestRecords,
      mediaManifestRecords.colorSpace,
    );
    await migrator.addColumn(mediaManifestRecords, mediaManifestRecords.isHdr);
  }

  Future<void> _repairPreReleaseMediaJournalV6(Migrator migrator) async {
    final columns = await customSelect(
      "PRAGMA table_info('media_promotion_records')",
    ).map((row) => row.read<String>('name')).get();
    const requiredColumns = {
      'transient_file_path',
      'quarantined_at',
      'failure_reason',
    };
    if (columns.toSet().containsAll(requiredColumns)) return;

    // Some physical development installs saw an intermediate v5 table before
    // its recovery metadata was finalized. Rebuild it into the canonical shape
    // without deleting the journal. The sentinel is only consulted when neither
    // verified staged nor final bytes exist, in which case recovery quarantines
    // the row as a missing source instead of publishing unverified media.
    await migrator.alterTable(
      TableMigration(
        mediaPromotionRecords,
        columnTransformer: {
          if (!columns.contains('transient_file_path'))
            mediaPromotionRecords.transientFilePath: const Constant(
              '/tmp/margaritaville-recovery-missing-source',
            ),
          if (!columns.contains('quarantined_at'))
            mediaPromotionRecords.quarantinedAt: const Constant(null),
          if (!columns.contains('failure_reason'))
            mediaPromotionRecords.failureReason: const Constant(null),
        },
      ),
    );
  }
}
