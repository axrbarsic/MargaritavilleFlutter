import 'package:flutter/foundation.dart';

import 'generated/edr_overlay_api.g.dart';

/// Routes first-GPU-frame acknowledgements from stable native EDR surfaces.
final class EdrReadyRouter implements EdrOverlayFlutterApi {
  EdrReadyRouter._();

  static final instance = EdrReadyRouter._();

  ValueChanged<int>? _callback;
  bool _isSetUp = false;

  void ensureSetUp() {
    if (_isSetUp) return;
    EdrOverlayFlutterApi.setUp(this);
    _isSetUp = true;
  }

  void register(ValueChanged<int> callback) {
    _callback = callback;
  }

  void unregister() {
    _callback = null;
  }

  @override
  void windowReady(int revision) {
    _callback?.call(revision);
  }
}
