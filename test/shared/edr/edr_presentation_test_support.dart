part of 'edr_viewport_controller_test.dart';

void _dispatchReady(
  int surfaceSessionId,
  int activationId,
  int contentRevision,
  int presentationRevision,
) {
  unawaited(
    EdrReadyRouter.instance.windowReady(
      surfaceSessionId,
      activationId,
      contentRevision,
      presentationRevision,
    ),
  );
}

final class _DeferredSuspendEdrBridge extends _RecordingEdrBridge {
  Completer<void>? pendingSuspend;

  @override
  Future<EdrPresentationAck> suspendWindow(
    int surfaceSessionId,
    int activationId,
    int presentationRevision,
  ) async {
    final ack = await super.suspendWindow(
      surfaceSessionId,
      activationId,
      presentationRevision,
    );
    final completer = Completer<void>();
    pendingSuspend = completer;
    await completer.future;
    return ack;
  }
}

final class _RejectedSuspendEdrBridge extends _RecordingEdrBridge {
  @override
  Future<EdrPresentationAck> suspendWindow(
    int surfaceSessionId,
    int activationId,
    int presentationRevision,
  ) async {
    await super.suspendWindow(
      surfaceSessionId,
      activationId,
      presentationRevision,
    );
    return EdrPresentationAck(
      surfaceSessionId: surfaceSessionId,
      activationId: activationId,
      presentationRevision: presentationRevision,
      suppressed: false,
      outcome: EdrPresentationOutcome.staleRejected,
      nativeGeneration: 0,
      presentedAtNanos: 0,
    );
  }
}

final class _RejectThenAcceptDeferredSuspendBridge extends _RecordingEdrBridge {
  final pending = <Completer<void>>[];

  void completeNext() => pending.removeAt(0).complete();

  @override
  Future<EdrPresentationAck> suspendWindow(
    int surfaceSessionId,
    int activationId,
    int presentationRevision,
  ) async {
    final accepted = await super.suspendWindow(
      surfaceSessionId,
      activationId,
      presentationRevision,
    );
    final attempt = pending.length + suspensions.length;
    final completer = Completer<void>();
    pending.add(completer);
    await completer.future;
    if (attempt == 1) {
      return EdrPresentationAck(
        surfaceSessionId: surfaceSessionId,
        activationId: activationId,
        presentationRevision: presentationRevision,
        suppressed: false,
        outcome: EdrPresentationOutcome.failed,
        nativeGeneration: 0,
        presentedAtNanos: 0,
      );
    }
    return accepted;
  }
}
