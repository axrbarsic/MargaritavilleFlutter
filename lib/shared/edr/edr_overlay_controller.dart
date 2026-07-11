import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'edr_overlay_bridge.dart';
import 'edr_ready_router.dart';
import 'generated/edr_overlay_api.g.dart';

part 'edr_overlay_measurement.dart';
part 'edr_overlay_geometry_cache.dart';
part 'edr_overlay_lifecycle.dart';
part 'edr_overlay_synchronization.dart';

final class EdrOverlayController extends ChangeNotifier {
  EdrOverlayController({EdrOverlayBridge? bridge, bool? supported})
    : _bridge = bridge ?? PigeonEdrOverlayBridge(),
      supported =
          supported ??
          (!kIsWeb &&
              (defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.android));

  final EdrOverlayBridge _bridge;
  final bool supported;
  final GlobalKey surfaceKey = GlobalKey(debugLabel: 'summary-edr-window');
  final int surfaceSessionId = ++_nextSurfaceSessionId;
  final Map<String, _EdrTileEntry> _entries = {};
  final _geometryCache = _EdrOverlayGeometryCache();
  Map<String, GlobalKey> _renderedTiles = const {};
  Map<String, GlobalKey> _sentTiles = const {};
  bool _attached = false;
  bool _windowVisible = true;
  bool _syncScheduled = false;
  bool _syncInProgress = false;
  bool _syncAgain = false;
  bool _disposed = false;
  int _contentRevision = 0;
  int _contentConfigurationRevision = 0;
  int _geometryRevision = 0;
  int _sentContentRevision = -1;
  int _sentLayoutGeneration = -1;
  int _activationId = 0;
  Offset _scrollOffset = Offset.zero;
  Rect? _lastViewportBounds;
  Size? _lastSurfaceSize;
  Offset? _lastGeometryOffset;
  final Map<int, _PendingEdrConfiguration> _pendingConfigurations = {};

  static int _nextSurfaceSessionId = 0;
  static int _nextActivationId = 0;
  static const double effectBleed = 24;
  static const double verticalPreload = 240;

  bool isTileRendered(String roomId, GlobalKey renderKey) {
    return supported && identical(_renderedTiles[roomId], renderKey);
  }

  void attachWindow() {
    if (!supported || _disposed) return;
    _attached = true;
    _beginActivation();
    EdrReadyRouter.instance
      ..ensureSetUp()
      ..register(surfaceSessionId, _markNativeReady);
    _scheduleSync();
  }

  void detachWindow() {
    if (!_attached) return;
    EdrReadyRouter.instance.unregister(surfaceSessionId);
    _attached = false;
    _replaceRenderedTiles(const {});
    _clearNative();
  }

  void setWindowVisible(bool visible) {
    if (!supported || _disposed || _windowVisible == visible) return;
    _windowVisible = visible;
    if (!visible) {
      _replaceRenderedTiles(const {});
      if (_attached) _clearNative();
      return;
    }
    _beginActivation();
    _scheduleSync();
  }

  void upsertTile({
    required String roomId,
    required String timeText,
    required GlobalKey renderKey,
    required ValueNotifier<bool> renderState,
    required int baseColorArgb,
    required double cornerRadius,
    required bool vipHdrEnabled,
    required bool vipJellyEnabled,
    required double vipJellySpeed,
    required double springIntensity,
    int? pulseGeneration,
    int? pulseColorArgb,
    int? pulseBoostColorArgb,
    int? pulseStartedAtMicros,
  }) {
    if (!supported || _disposed) return;
    final next = _EdrTileEntry(
      renderKey: renderKey,
      renderState: renderState,
      timeText: timeText,
      baseColorArgb: baseColorArgb,
      cornerRadius: cornerRadius,
      vipHdrEnabled: vipHdrEnabled,
      vipJellyEnabled: vipJellyEnabled,
      vipJellySpeed: vipJellySpeed,
      pulseGeneration: pulseGeneration,
      pulseColorArgb: pulseColorArgb,
      pulseBoostColorArgb: pulseBoostColorArgb,
      pulseStartedAtMicros: pulseStartedAtMicros,
      springIntensity: springIntensity,
    );
    final previous = _entries[roomId];
    if (previous == next) return;
    if (previous != null && !identical(previous.renderState, renderState)) {
      previous.renderState.value = false;
    }
    _entries[roomId] = next;
    _contentRevision++;
    if (previous == null || !identical(previous.renderKey, renderKey)) {
      _geometryCache.invalidate();
    }
    if (previous != null &&
        !identical(previous.renderKey, renderKey) &&
        identical(_renderedTiles[roomId], previous.renderKey)) {
      _replaceRenderedTiles({..._renderedTiles}..remove(roomId));
    }
    _scheduleSync();
  }

  void removeTile(String roomId, {required GlobalKey renderKey}) {
    final current = _entries[roomId];
    if (current == null || !identical(current.renderKey, renderKey)) return;
    current.renderState.value = false;
    _entries.remove(roomId);
    _geometryCache
      ..remove(roomId)
      ..invalidate();
    _contentRevision++;
    if (identical(_renderedTiles[roomId], renderKey)) {
      _replaceRenderedTiles({..._renderedTiles}..remove(roomId));
    }
    _scheduleSync();
  }

  void requestGeometrySync() {
    _geometryCache.invalidate();
    _scheduleSync();
  }

  void updateScrollOffset(Offset offset) {
    if (_scrollOffset == offset) return;
    _scrollOffset = offset;
    _sendGeometryFast(offset);
    _scheduleSync();
  }

  @override
  void dispose() {
    _disposed = true;
    if (_attached) {
      EdrReadyRouter.instance.unregister(surfaceSessionId);
      _clearNative();
    }
    _entries.clear();
    _geometryCache.clear();
    _pendingConfigurations.clear();
    _renderedTiles = const {};
    super.dispose();
  }

  void _scheduleSync() {
    if (!supported || _disposed || _syncScheduled) return;
    _syncScheduled = true;
    WidgetsBinding.instance.scheduleFrame();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      _synchronize().ignore();
    });
  }

  Future<void> _synchronize() async {
    if (_syncInProgress) {
      _syncAgain = true;
      return;
    }
    _syncInProgress = true;
    do {
      _syncAgain = false;
      await _sendCurrentSnapshot();
    } while (_syncAgain && !_disposed);
    _syncInProgress = false;
  }

  void _sendGeometryFast(Offset offset) {
    final viewport = _lastViewportBounds;
    final layoutGeneration = _sentLayoutGeneration;
    if (!_attached ||
        !_windowVisible ||
        viewport == null ||
        layoutGeneration < 0 ||
        _activationId <= 0) {
      return;
    }
    final geometryRevision = ++_geometryRevision;
    _lastGeometryOffset = offset;
    _bridge
        .updateWindowGeometry(
          surfaceSessionId,
          _activationId,
          layoutGeneration,
          geometryRevision,
          viewport.left,
          viewport.top,
          viewport.width,
          viewport.height,
          offset.dx,
          offset.dy,
        )
        .catchError((Object error) {
          debugPrint('Быстрый нативный EDR-scroll недоступен: $error');
          _lastGeometryOffset = null;
          _scheduleSync();
        });
  }

  void _markNativeReady(int activationId, int revision) {
    final configuration = _pendingConfigurations[revision];
    if (_disposed ||
        activationId != _activationId ||
        configuration == null ||
        revision != _contentConfigurationRevision) {
      return;
    }
    _pendingConfigurations.remove(revision);
    if (configuration.contentRevision != _contentRevision ||
        configuration.layoutGeneration != _geometryCache.layoutGeneration) {
      _scheduleSync();
      return;
    }
    _pendingConfigurations.removeWhere((key, _) => key < revision);
    _replaceRenderedTiles(configuration.renderedTiles);
  }
}
