part of 'edr_overlay_controller.dart';

extension EdrOverlayPresentation on EdrOverlayController {
  Future<EdrPresentationOcclusion> acquirePresentationOcclusion() async {
    if (!supported || _disposed) {
      return EdrPresentationOcclusion._(() {});
    }
    _presentationOcclusionCount += 1;
    final mustAwaitNativeFence =
        _renderedTiles.isNotEmpty || _pendingConfigurations.isNotEmpty;
    final suspension = _applyEffectiveVisibility();
    if (mustAwaitNativeFence) {
      try {
        await suspension.timeout(
          EdrOverlayController.presentationSuspendDeadline,
        );
      } catch (error) {
        _replaceRenderedTiles(const {});
        debugPrint(
          'Native presentation suspend не подтвердился до дедлайна, '
          'используется Flutter fallback: '
          '$error',
        );
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
      if (_disposed || _presentationOcclusionCount == 0) return;
      _presentationOcclusionCount -= 1;
      _applyEffectiveVisibility().ignore();
    });
  }

  Future<void> _applyEffectiveVisibility() async {
    final visible = _routeVisible && _presentationOcclusionCount == 0;
    if (_windowVisible == visible) return;
    _windowVisible = visible;
    if (!visible) {
      _replaceRenderedTiles(const {});
      if (_attached) await _suspendNative();
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
