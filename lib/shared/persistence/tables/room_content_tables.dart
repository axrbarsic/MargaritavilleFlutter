import 'package:drift/drift.dart';

// App-wide room content projection.

import 'work_session_tables.dart';

@DataClassName('RoomNoteRow')
class RoomNoteRecords extends Table {
  TextColumn get sessionId =>
      text().references(WorkSessionRecords, #id, onDelete: KeyAction.cascade)();
  TextColumn get roomNumber => text()();
  TextColumn get textValue => text()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get lastCommandId => text().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {sessionId, roomNumber};
}

@DataClassName('AssignmentNoteRow')
class AssignmentNoteRecords extends Table {
  TextColumn get sessionId =>
      text().references(WorkSessionRecords, #id, onDelete: KeyAction.cascade)();
  TextColumn get assignmentId => text()();
  TextColumn get textValue => text()();
  IntColumn get updatedAtMicros => integer()();
  TextColumn get lastCommandId => text().nullable()();
  IntColumn get deletedAtMicros => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {sessionId, assignmentId};
}

@DataClassName('CartConsumableRow')
class CartConsumableRecords extends Table {
  TextColumn get sessionId =>
      text().references(WorkSessionRecords, #id, onDelete: KeyAction.cascade)();
  TextColumn get assignmentId => text()();
  TextColumn get itemId => text()();
  TextColumn get title => text()();
  IntColumn get quantity => integer()();
  IntColumn get updatedAtMicros => integer()();
  TextColumn get lastCommandId => text()();
  IntColumn get completedAtMicros => integer().nullable()();
  IntColumn get deletedAtMicros => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {sessionId, assignmentId, itemId};

  @override
  List<String> get customConstraints => const [
    'CHECK (quantity >= 0 AND quantity <= 10)',
  ];
}
