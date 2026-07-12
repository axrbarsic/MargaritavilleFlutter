import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/shared/edr/edr_ready_router.dart';
import 'package:margaritaville_flutter/shared/edr/generated/edr_overlay_api.g.dart';

void main() {
  test('readiness router unregisters only its own surface session', () async {
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
      ..register(firstSession, (activation, revision, presentation) async {
        firstRevisions.add((revision, presentation));
        return _ack(firstSession, activation, revision, presentation);
      })
      ..register(secondSession, (activation, revision, presentation) async {
        secondRevisions.add((revision, presentation));
        return _ack(secondSession, activation, revision, presentation);
      });

    await EdrReadyRouter.instance.windowReady(firstSession, 101, 11, 31);
    await EdrReadyRouter.instance.windowReady(secondSession, 201, 21, 41);
    EdrReadyRouter.instance.unregister(firstSession);
    final rejected = await EdrReadyRouter.instance.windowReady(
      firstSession,
      102,
      12,
      32,
    );
    await EdrReadyRouter.instance.windowReady(secondSession, 202, 22, 42);

    expect(firstRevisions, [(11, 31)]);
    expect(secondRevisions, [(21, 41), (22, 42)]);
    expect(rejected.accepted, isFalse);
  });
}

EdrReadyAck _ack(int session, int activation, int content, int presentation) =>
    EdrReadyAck(
      surfaceSessionId: session,
      activationId: activation,
      contentRevision: content,
      presentationRevision: presentation,
      accepted: true,
    );
