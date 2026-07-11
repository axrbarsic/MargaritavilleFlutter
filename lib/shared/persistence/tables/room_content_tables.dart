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
