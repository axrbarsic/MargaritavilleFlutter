part of 'edr_overlay_controller.dart';

extension EdrOverlayPresentation on EdrOverlayController {
  Future<EdrPresentationOcclusion> acquirePresentationOcclusion() async {
    if (!supported || _disposed) {
      return EdrPresentationOcclusion._(() {});
    }
    _presentationOcclusionCount += 1;
    final mustAwaitNativeFence =
        _nativeMayPaint ||
        _presentationSuspension != null ||
        _renderedTiles.isNotEmpty ||
        _pendingConfigurations.isNotEmpty;
    final suspension =
        _presentationSuspension ??
        _trackPresentationSuspension(_applyEffectiveVisibility);
    if (mustAwaitNativeFence) {
      if (_nativeMayPaint) {
        // A window-level native scene can only be covered by an exact native
        // display receipt. The emergency deadline is safe solely before any
        // native membership has ever acquired paint ownership.
        try {
          await suspension;
        } catch (_) {
          _presentationRecoveryPending = true;
          _releasePresentationOcclusion();
          rethrow;
        }
      } else {
        try {
          await suspension.timeout(
            EdrOverlayController.presentationSuspendDeadline,
          );
        } catch (error) {
          _replaceRenderedTiles(const {});
          debugPrint(
            'Native presentation suspend не подтвердился до дедлайна; '
            'native paint ещё не получал ownership: $error',
          );
        }
      }
    } else {
      // Until an exact ready commit, native is contractually transparent. Do
      // not let an absent/stalled host hold Flutter navigation hostage.
      unawaited(
        suspension.catchError((Object error) {
          debugPrint('Фоновый native presentation suspend недоступен: $error');
        }),
      );
    }
    return EdrPresentationOcclusion._(() {
      _releasePresentationOcclusion();
    });
  }

  Future<void> _trackPresentationSuspension(Future<void> Function() start) {
    final existing = _presentationSuspension;
    if (existing != null) return existing;
    final suspension = start();
    _presentationSuspension = suspension;
    unawaited(
      suspension.then(
        (_) => _settlePresentationSuspension(suspension),
        onError: (Object error, StackTrace stackTrace) =>
            _settlePresentationSuspension(suspension),
      ),
    );
    return suspension;
  }

  void _releasePresentationOcclusion() {
    if (_disposed || _presentationOcclusionCount == 0) return;
    _presentationOcclusionCount -= 1;
    if (_presentationOcclusionCount == 0 && _presentationSuspension == null) {
      _resumeOrRecoverPresentationOwner();
    }
  }

  void _settlePresentationSuspension(Future<void> suspension) {
    if (_disposed || !identical(_presentationSuspension, suspension)) return;
    _presentationSuspension = null;
    if (_presentationOcclusionCount == 0) {
      _resumeOrRecoverPresentationOwner();
    }
  }

  void _resumeOrRecoverPresentationOwner() {
    if (_presentationRecoveryPending) {
      _recoverPresentationOwner();
      return;
    }
    _applyEffectiveVisibility().ignore();
  }

  void _recoverPresentationOwner() {
    if (_disposed || !_routeVisible || _presentationOcclusionCount != 0) return;
    _presentationRecoveryPending = false;
    _windowVisible = true;
    _replaceRenderedTiles(const {});
    _geometryCache.invalidate();
    _lastViewportBounds = null;
    _beginActivation();
    _scheduleSync();
  }

  Future<void> _applyEffectiveVisibility() async {
    var visible = _routeVisible && _presentationOcclusionCount == 0;
    if (visible && _presentationSuspension != null) {
      final suspension = _presentationSuspension!;
      try {
        await suspension;
      } catch (_) {
        _presentationRecoveryPending = true;
        if (identical(_presentationSuspension, suspension)) {
          _presentationSuspension = null;
        }
      }
      visible = _routeVisible && _presentationOcclusionCount == 0;
    }
    if (visible && _presentationRecoveryPending) {
      _recoverPresentationOwner();
      return;
    }
    if (_windowVisible == visible) return;
    _windowVisible = visible;
    if (!visible) {
      _replaceRenderedTiles(const {});
      if (_attached) {
        try {
          await _suspendNative();
        } catch (_) {
          _presentationRecoveryPending = true;
          rethrow;
        }
      }
      return;
    }
    _geometryCache.invalidate();
    _lastViewportBounds = null;
    _beginActivation();
    _scheduleSync();
  }
}

final class EdrPresentationOcclusion {
  EdrPresentationOcclusion._(this._onRelease);

  final VoidCallback _onRelease;
  bool _released = false;

  void release() {
    if (_released) return;
    _released = true;
    _onRelease();
  }
}
