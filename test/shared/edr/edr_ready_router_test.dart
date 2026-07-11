import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/shared/edr/edr_ready_router.dart';

void main() {
  test('readiness router unregisters only its own surface session', () {
    const firstSession = 90_001;
    const secondSession = 90_002;
    final firstRevisions = <(int, int)>[];
    final secondRevisions = <(int, int)>[];
    addTearDown(() {
      EdrReadyRouter.instance
        ..unregister(firstSession)
        ..unregister(secondSession);
    });

    EdrReadyRouter.instance
      ..register(
        firstSession,
        (_, revision, presentation) =>
            firstRevisions.add((revision, presentation)),
      )
      ..register(
        secondSession,
        (_, revision, presentation) =>
            secondRevisions.add((revision, presentation)),
      )
      ..windowReady(firstSession, 101, 11, 31)
      ..windowReady(secondSession, 201, 21, 41)
      ..unregister(firstSession)
      ..windowReady(firstSession, 102, 12, 32)
      ..windowReady(secondSession, 202, 22, 42);

    expect(firstRevisions, [(11, 31)]);
    expect(secondRevisions, [(21, 41), (22, 42)]);
  });
}
