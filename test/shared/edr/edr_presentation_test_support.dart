part of 'edr_viewport_controller_test.dart';

final class _DeferredSuspendEdrBridge extends _RecordingEdrBridge {
  Completer<void>? pendingSuspend;

  @override
  Future<void> suspendWindow(
    int surfaceSessionId,
    int activationId,
    int presentationRevision,
  ) async {
    await super.suspendWindow(
      surfaceSessionId,
      activationId,
      presentationRevision,
    );
    final completer = Completer<void>();
    pendingSuspend = completer;
    await completer.future;
  }
}
