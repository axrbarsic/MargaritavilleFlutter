import 'generated/edr_overlay_api.g.dart';

/// Routes first-GPU-frame acknowledgements from stable native EDR surfaces.
final class EdrReadyRouter implements EdrOverlayFlutterApi {
  EdrReadyRouter._();

  static final instance = EdrReadyRouter._();

  final Map<
    int,
    Future<EdrReadyAck> Function(
      int activationId,
      int contentRevision,
      int presentationRevision,
    )
  >
  _callbacks = {};
  bool _isSetUp = false;

  void ensureSetUp() {
    if (_isSetUp) return;
    EdrOverlayFlutterApi.setUp(this);
    _isSetUp = true;
  }

  void register(
    int surfaceSessionId,
    Future<EdrReadyAck> Function(
      int activationId,
      int contentRevision,
      int presentationRevision,
    )
    callback,
  ) {
    _callbacks[surfaceSessionId] = callback;
  }

  void unregister(int surfaceSessionId) {
    _callbacks.remove(surfaceSessionId);
  }

  @override
  Future<EdrReadyAck> windowReady(
    int surfaceSessionId,
    int activationId,
    int contentRevision,
    int presentationRevision,
  ) async {
    final callback = _callbacks[surfaceSessionId];
    if (callback != null) {
      return callback(activationId, contentRevision, presentationRevision);
    }
    return EdrReadyAck(
      surfaceSessionId: surfaceSessionId,
      activationId: activationId,
      contentRevision: contentRevision,
      presentationRevision: presentationRevision,
      accepted: false,
    );
  }
}
