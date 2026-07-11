import 'package:drift/drift.dart';

// App-wide audit, receipt, sync, and media projections.

import 'work_session_tables.dart';

@DataClassName('HistoryEventRow')
class HistoryEventRecords extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId =>
      text().references(WorkSessionRecords, #id, onDelete: KeyAction.cascade)();
  TextColumn get commandId => text()();
  TextColumn get eventType => text()();
  IntColumn get eventVersion => integer().withDefault(const Constant(1))();
  TextColumn get payloadJson => text()();
  DateTimeColumn get happenedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('CommandReceiptRow')
class CommandReceiptRecords extends Table {
  TextColumn get sessionId =>
      text().references(WorkSessionRecords, #id, onDelete: KeyAction.cascade)();
  TextColumn get commandId => text()();
  IntColumn get commandVersion => integer().withDefault(const Constant(1))();
  TextColumn get outcome => text()();
  DateTimeColumn get processedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {sessionId, commandId};
}

@DataClassName('SyncOutboxRow')
class SyncOutboxRecords extends Table {
  TextColumn get eventId => text()();
  TextColumn get sessionId =>
      text().references(WorkSessionRecords, #id, onDelete: KeyAction.cascade)();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
  DateTimeColumn get acknowledgedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {eventId};
}

@DataClassName('SyncInboxRow')
class SyncInboxRecords extends Table {
  TextColumn get eventId => text()();
  TextColumn get checksum => text()();
  DateTimeColumn get receivedAt => dateTime()();
  DateTimeColumn get appliedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {eventId};
}

@DataClassName('MediaManifestRow')
class MediaManifestRecords extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId =>
      text().references(WorkSessionRecords, #id, onDelete: KeyAction.cascade)();
  TextColumn get assignmentId => text().nullable()();
  TextColumn get roomNumber => text().nullable()();
  TextColumn get kind => text()();
  TextColumn get relativePath => text()();
  TextColumn get checksumSha256 => text()();
  TextColumn get originDeviceId => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get mimeType => text().nullable()();
  IntColumn get durationMs => integer().nullable()();
  TextColumn get transcript => text().nullable()();
  IntColumn get byteLength => integer().nullable()();
  IntColumn get widthPixels => integer().nullable()();
  IntColumn get heightPixels => integer().nullable()();
  TextColumn get originalExtension => text().nullable()();
  IntColumn get orientation => integer().nullable()();
  TextColumn get colorSpace => text().nullable()();
  BoolColumn get isHdr => boolean().nullable()();
  TextColumn get lastCommandId => text().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('MediaPromotionRow')
class MediaPromotionRecords extends Table {
  TextColumn get operationId => text()();
  TextColumn get commandId => text()();
  TextColumn get mediaId => text().unique()();
  TextColumn get sessionId =>
      text().references(WorkSessionRecords, #id, onDelete: KeyAction.cascade)();
  TextColumn get roomNumber => text()();
  TextColumn get assignmentId => text().nullable()();
  TextColumn get kind => text()();
  TextColumn get stagedRelativePath => text()();
  TextColumn get transientFilePath => text()();
  TextColumn get finalRelativePath => text()();
  TextColumn get checksumSha256 => text()();
  IntColumn get byteLength => integer()();
  TextColumn get originDeviceId => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get issuedAt => dateTime()();
  TextColumn get mimeType => text().nullable()();
  IntColumn get durationMs => integer().nullable()();
  TextColumn get transcript => text().nullable()();
  IntColumn get widthPixels => integer().nullable()();
  IntColumn get heightPixels => integer().nullable()();
  TextColumn get originalExtension => text().nullable()();
  IntColumn get orientation => integer().nullable()();
  TextColumn get colorSpace => text().nullable()();
  BoolColumn get isHdr => boolean().nullable()();
  DateTimeColumn get quarantinedAt => dateTime().nullable()();
  TextColumn get failureReason => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {operationId};
}
