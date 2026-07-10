import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/sync_contract_tables.dart';
import 'tables/work_session_tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    WorkSessionRecords,
    HousekeeperRecords,
    WorkAssignmentRecords,
    RoomStateRecords,
    HistoryEventRecords,
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

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      throw UnsupportedError(
        'Canonical schema v2 is the first supported beta schema; '
        'cannot upgrade $from -> $to',
      );
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
