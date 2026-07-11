import 'package:drift/drift.dart';

// App-wide canonical work-session projection.

@DataClassName('WorkSessionRow')
class WorkSessionRecords extends Table {
  TextColumn get id => text()();
  IntColumn get canonicalSchemaVersion => integer()();
  TextColumn get hotelId => text()();
  TextColumn get hotelName => text()();
  TextColumn get workflow => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get workdayLocked =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get lockUpdatedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('HousekeeperRow')
class HousekeeperRecords extends Table {
  TextColumn get sessionId =>
      text().references(WorkSessionRecords, #id, onDelete: KeyAction.cascade)();
  TextColumn get id => text()();
  TextColumn get displayName => text()();
  TextColumn get paletteKey => text()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {sessionId, id};
}

@DataClassName('WorkAssignmentRow')
class WorkAssignmentRecords extends Table {
  TextColumn get sessionId =>
      text().references(WorkSessionRecords, #id, onDelete: KeyAction.cascade)();
  TextColumn get id => text()();
  IntColumn get cartNumber => integer()();
  TextColumn get housekeeperId => text()();
  DateTimeColumn get assignedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {sessionId, id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {sessionId, cartNumber},
  ];
}

@DataClassName('RoomStateRow')
class RoomStateRecords extends Table {
  TextColumn get sessionId =>
      text().references(WorkSessionRecords, #id, onDelete: KeyAction.cascade)();
  TextColumn get roomNumber => text()();
  TextColumn get assignmentId => text()();
  TextColumn get phase => text()();
  BoolColumn get isVip => boolean().withDefault(const Constant(false))();
  DateTimeColumn get scheduledFor => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  DateTimeColumn get selectedAt => dateTime()();
  DateTimeColumn get phaseUpdatedAt => dateTime()();
  DateTimeColumn get openedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get vipUpdatedAt => dateTime().nullable()();
  DateTimeColumn get scheduledUpdatedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {sessionId, roomNumber};
}
