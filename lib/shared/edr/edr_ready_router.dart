import 'generated/edr_overlay_api.g.dart';

/// Routes first-GPU-frame acknowledgements from stable native EDR surfaces.
final class EdrReadyRouter implements EdrOverlayFlutterApi {
  EdrReadyRouter._();

  static final instance = EdrReadyRouter._();

  final Map<
    int,
    void Function(
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
    void Function(
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
  void windowReady(
    int surfaceSessionId,
    int activationId,
    int contentRevision,
    int presentationRevision,
  ) {
    _callbacks[surfaceSessionId]?.call(
      activationId,
      contentRevision,
      presentationRevision,
    );
  }
}
