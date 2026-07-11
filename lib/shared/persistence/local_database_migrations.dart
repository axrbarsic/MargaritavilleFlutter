part of 'local_database.dart';

extension AppDatabaseMigrations on AppDatabase {
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

    await _assertNoOwnerlessMediaRows('media_promotion_records');

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
          mediaPromotionRecords.assignmentId: const CustomExpression<String>(
            'CASE WHEN room_number IS NOT NULL '
            'AND length(trim(room_number)) > 0 THEN NULL '
            'ELSE assignment_id END',
          ),
          mediaPromotionRecords.roomNumber: const CustomExpression<String>(
            'CASE WHEN room_number IS NOT NULL '
            'AND length(trim(room_number)) > 0 THEN room_number '
            'ELSE NULL END',
          ),
        },
      ),
    );
  }

  Future<void> _upgradeAssignmentContentV7(Migrator migrator) async {
    await migrator.createTable(assignmentNoteRecords);
    await migrator.createTable(cartConsumableRecords);
    await _addReceiptV7ColumnsIfMissing(migrator);
    await _assertNoOwnerlessMediaRows('media_manifest_records');
    await _assertNoOwnerlessMediaRows('media_promotion_records');
    await migrator.alterTable(
      TableMigration(
        mediaManifestRecords,
        columnTransformer: {
          // v2-v6 used assignment_id as optional room metadata. In v7 owner
          // identity is exclusive, so an existing room deterministically wins.
          mediaManifestRecords.assignmentId: const CustomExpression<String>(
            'CASE WHEN room_number IS NOT NULL AND length(trim(room_number)) > 0 '
            'THEN NULL ELSE assignment_id END',
          ),
          mediaManifestRecords.roomNumber: const CustomExpression<String>(
            'CASE WHEN room_number IS NOT NULL AND length(trim(room_number)) > 0 '
            'THEN room_number ELSE NULL END',
          ),
        },
      ),
    );
    await migrator.alterTable(
      TableMigration(
        mediaPromotionRecords,
        columnTransformer: {
          mediaPromotionRecords.assignmentId: const CustomExpression<String>(
            'CASE WHEN room_number IS NOT NULL '
            'AND length(trim(room_number)) > 0 THEN NULL '
            'ELSE assignment_id END',
          ),
          mediaPromotionRecords.roomNumber: const CustomExpression<String>(
            'CASE WHEN room_number IS NOT NULL '
            'AND length(trim(room_number)) > 0 THEN room_number '
            'ELSE NULL END',
          ),
        },
      ),
    );
  }

  Future<void> _addReceiptV7ColumnsIfMissing(Migrator migrator) async {
    final columns = await customSelect(
      "PRAGMA table_info('command_receipt_records')",
    ).map((row) => row.read<String>('name')).get();
    if (columns.isEmpty) {
      // Some physical pre-release installs recorded user_version=3 without
      // creating the receipt projection. Recreate the current table and
      // recover applied command identities from the append-only history.
      await _createLegacyCommandReceiptTableV9();
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
      return;
    }
    if (!columns.contains('command_type')) {
      await migrator.addColumn(
        commandReceiptRecords,
        commandReceiptRecords.commandType,
      );
    }
    if (!columns.contains('command_fingerprint')) {
      await migrator.addColumn(
        commandReceiptRecords,
        commandReceiptRecords.commandFingerprint,
      );
    }
    if (!columns.contains('issued_at_micros')) {
      await migrator.addColumn(
        commandReceiptRecords,
        commandReceiptRecords.issuedAtMicros,
      );
    }
  }

  Future<void> _createLegacyCommandReceiptTableV9() {
    return customStatement('''
      CREATE TABLE command_receipt_records (
        session_id TEXT NOT NULL REFERENCES work_session_records(id)
          ON DELETE CASCADE,
        command_id TEXT NOT NULL,
        command_version INTEGER NOT NULL DEFAULT 1,
        command_type TEXT,
        command_fingerprint TEXT,
        issued_at_micros INTEGER,
        outcome TEXT NOT NULL,
        processed_at INTEGER NOT NULL,
        PRIMARY KEY (session_id, command_id)
      )
    ''');
  }

  Future<void> _upgradeWorkSetupV8(Migrator migrator) async {
    final columns = await customSelect(
      "PRAGMA table_info('work_assignment_records')",
    ).map((row) => row.read<String>('name')).get();
    if (!columns.contains('territory_id')) {
      await migrator.addColumn(
        workAssignmentRecords,
        workAssignmentRecords.territoryId,
      );
    }
  }

  Future<void> _upgradeHousekeeperCatalogV9(Migrator migrator) {
    return migrator.createTable(housekeeperCatalogRecords);
  }

  Future<void> _upgradeAggregateLedgerV10(Migrator migrator) async {
    await customStatement(
      'ALTER TABLE history_event_records RENAME TO history_event_records_v9',
    );
    await migrator.createTable(historyEventRecords);
    await customStatement('''
      INSERT INTO history_event_records (
        id, aggregate_type, aggregate_id, session_id, command_id, event_type,
        event_version, payload_json, happened_at
      )
      SELECT
        id, 'work-session', session_id, session_id, command_id, event_type,
        event_version, payload_json, happened_at
      FROM history_event_records_v9
    ''');
    await customStatement('DROP TABLE history_event_records_v9');

    await customStatement(
      'ALTER TABLE command_receipt_records '
      'RENAME TO command_receipt_records_v9',
    );
    await migrator.createTable(commandReceiptRecords);
    await customStatement('''
      INSERT INTO command_receipt_records (
        aggregate_type, aggregate_id, session_id, command_id, command_version,
        command_type, command_fingerprint, issued_at_micros, outcome,
        processed_at
      )
      SELECT
        'work-session', session_id, session_id, command_id, command_version,
        command_type, command_fingerprint, issued_at_micros, outcome,
        processed_at
      FROM command_receipt_records_v9
    ''');
    await customStatement('DROP TABLE command_receipt_records_v9');

    await customStatement(
      'ALTER TABLE sync_outbox_records RENAME TO sync_outbox_records_v9',
    );
    await migrator.createTable(syncOutboxRecords);
    await customStatement('''
      INSERT INTO sync_outbox_records (
        event_id, aggregate_type, aggregate_id, session_id, attempt_count,
        next_attempt_at, acknowledged_at
      )
      SELECT
        event_id, 'work-session', session_id, session_id, attempt_count,
        next_attempt_at, acknowledged_at
      FROM sync_outbox_records_v9
    ''');
    await customStatement('DROP TABLE sync_outbox_records_v9');
  }

  Future<void> _assertNoOwnerlessMediaRows(String tableName) async {
    final result = await customSelect('''
      SELECT COUNT(*) AS invalid_count
      FROM $tableName
      WHERE (room_number IS NULL OR length(trim(room_number)) = 0)
        AND (assignment_id IS NULL OR length(trim(assignment_id)) = 0)
    ''').getSingle();
    final invalidCount = result.read<int>('invalid_count');
    if (invalidCount != 0) {
      throw StateError(
        'Cannot migrate $tableName: $invalidCount media rows have no owner.',
      );
    }
  }
}
