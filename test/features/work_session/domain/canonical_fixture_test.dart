import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/room_state.dart';
import 'package:margaritaville_flutter/features/work_session/domain/models/work_session.dart';

void main() {
  test('canonical v2 fixture decodes without Swift storage assumptions', () {
    final fixture =
        jsonDecode(
              File(
                'test/fixtures/canonical_work_session_v2.json',
              ).readAsStringSync(),
            )
            as Map<String, Object?>;

    final session = WorkSession.fromJson(fixture);

    expect(session.schemaVersion, 2);
    expect(session.hotel.id, 'margaritaville');
    expect(session.assignments, hasLength(2));
    expect(session.room('101')?.phase, RoomPhase.open);
    expect(session.room('101')?.isVip, isTrue);
    expect(session.room('143')?.displayStatus, RoomDisplayStatus.scheduled);
    expect(WorkSession.fromJson(session.toJson()), session);
  });
}
