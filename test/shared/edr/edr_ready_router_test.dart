import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/shared/edr/edr_ready_router.dart';

void main() {
  test('readiness router unregisters only its own surface session', () {
    const firstSession = 90_001;
    const secondSession = 90_002;
    final firstRevisions = <int>[];
    final secondRevisions = <int>[];
    addTearDown(() {
      EdrReadyRouter.instance
        ..unregister(firstSession)
        ..unregister(secondSession);
    });

    EdrReadyRouter.instance
      ..register(firstSession, (_, revision) => firstRevisions.add(revision))
      ..register(secondSession, (_, revision) => secondRevisions.add(revision))
      ..windowReady(firstSession, 101, 11)
      ..windowReady(secondSession, 201, 21)
      ..unregister(firstSession)
      ..windowReady(firstSession, 102, 12)
      ..windowReady(secondSession, 202, 22);

    expect(firstRevisions, [11]);
    expect(secondRevisions, [21, 22]);
  });
}
