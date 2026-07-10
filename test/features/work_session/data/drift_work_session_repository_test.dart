import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/work_session/data/local/app_database.dart';
import 'package:margaritaville_flutter/features/work_session/data/repositories/drift_work_session_repository.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_session.dart';

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
}
