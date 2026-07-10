import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'edr_overlay_bridge.dart';
import 'edr_ready_router.dart';
import 'generated/edr_overlay_api.g.dart';

part 'edr_overlay_measurement.dart';

final class EdrOverlayController extends ChangeNotifier {
  EdrOverlayController({EdrOverlayBridge? bridge, bool? supported})
    : _bridge = bridge ?? PigeonEdrOverlayBridge(),
      supported =
          supported ?? (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS);

  final EdrOverlayBridge _bridge;
  final bool supported;
  final GlobalKey surfaceKey = GlobalKey(debugLabel: 'summary-edr-window');
  final Map<String, _EdrTileEntry> _entries = {};
  Map<String, GlobalKey> _renderedTiles = const {};
  bool _attached = false;
  bool _windowVisible = true;
  bool _syncScheduled = false;
  bool _syncInProgress = false;
  bool _syncAgain = false;
  bool _disposed = false;
  int _layoutRevision = 0;
  int _contentRevision = 0;
  int _configuredContentRevision = -1;
  final Map<int, _PendingEdrConfiguration> _pendingConfigurations = {};

  static const double effectBleed = 24;
  static const double verticalPreload = 240;

  bool isTileRendered(String roomId, GlobalKey renderKey) {
    return supported && identical(_renderedTiles[roomId], renderKey);
  }

  void attachWindow() {
    if (!supported || _disposed) return;
    _attached = true;
    EdrReadyRouter.instance
      ..ensureSetUp()
      ..register(_markNativeReady);
    _scheduleSync();
  }

  void detachWindow() {
    if (!_attached) return;
    EdrReadyRouter.instance.unregister();
    _attached = false;
    _configuredContentRevision = -1;
    _pendingConfigurations.clear();
    _replaceRenderedTiles(const {});
    _bridge.clearWindow(++_layoutRevision).ignore();
  }

  void setWindowVisible(bool visible) {
    if (!supported || _disposed || _windowVisible == visible) return;
    _windowVisible = visible;
    _contentRevision++;
    _configuredContentRevision = -1;
    _pendingConfigurations.clear();
    if (!visible) {
      _replaceRenderedTiles(const {});
      if (_attached) _bridge.clearWindow(++_layoutRevision).ignore();
      return;
    }
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
    _contentRevision++;
    if (identical(_renderedTiles[roomId], renderKey)) {
      _replaceRenderedTiles({..._renderedTiles}..remove(roomId));
    }
    _scheduleSync();
  }

  void requestGeometrySync() {
    _contentRevision++;
    _scheduleSync();
  }

  void requestVisibilitySync() {
    _contentRevision++;
    _scheduleSync();
  }

  @override
  void dispose() {
    _disposed = true;
    if (_attached) {
      EdrReadyRouter.instance.unregister();
      _bridge.clearWindow(++_layoutRevision).ignore();
    }
    _entries.clear();
    _pendingConfigurations.clear();
    _configuredContentRevision = -1;
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

  Future<void> _sendCurrentSnapshot() async {
    if (_disposed) return;
    final surface = surfaceKey.currentContext?.findRenderObject();
    if (!_attached ||
        !_windowVisible ||
        surface is! RenderBox ||
        !surface.hasSize) {
      return;
    }
    final surfaceOrigin = surface.localToGlobal(Offset.zero);
    final viewport = (surfaceOrigin & surface.size).inflate(verticalPreload);
    final measuredTiles = _measureTiles()
        .where((tile) => tile.bounds.overlaps(viewport))
        .toList(growable: false);
    final tiles = <EdrTileSnapshot>[
      for (final measured in measuredTiles)
        measured.snapshot(relativeTo: surfaceOrigin),
    ];
    final contentRevision = _contentRevision;
    final nextRenderedTiles = {
      for (final measured in measuredTiles)
        if (identical(
          _entries[measured.roomId]?.renderKey,
          measured.entry.renderKey,
        ))
          measured.roomId: measured.entry.renderKey,
    };
    if (_configuredContentRevision == contentRevision &&
        mapEquals(_renderedTiles, nextRenderedTiles)) {
      return;
    }
    final revision = ++_layoutRevision;
    _pendingConfigurations[revision] = _PendingEdrConfiguration(
      contentRevision: contentRevision,
      renderedTiles: nextRenderedTiles,
    );
    try {
      await _bridge.configureWindow(
        revision,
        surfaceOrigin.dx,
        surfaceOrigin.dy,
        surface.size.width,
        surface.size.height,
        tiles,
      );
    } catch (error) {
      _pendingConfigurations.remove(revision);
      debugPrint('Нативный EDR-overlay недоступен: $error');
      _replaceRenderedTiles(const {});
      return;
    }
    if (_disposed || !_attached) return;
    if (_contentRevision != contentRevision) {
      _syncAgain = true;
    }
  }

  void _markNativeReady(int revision) {
    final configuration = _pendingConfigurations.remove(revision);
    if (_disposed || configuration == null || revision != _layoutRevision) {
      return;
    }
    if (configuration.contentRevision != _contentRevision) {
      _scheduleSync();
      return;
    }
    _pendingConfigurations.removeWhere((key, _) => key < revision);
    _configuredContentRevision = configuration.contentRevision;
    _replaceRenderedTiles(configuration.renderedTiles);
  }

  List<_MeasuredEdrTile> _measureTiles() {
    final tiles = <_MeasuredEdrTile>[];
    for (final MapEntry(key: roomId, value: entry) in _entries.entries) {
      final renderObject = entry.renderKey.currentContext?.findRenderObject();
      if (renderObject is! RenderBox || !renderObject.hasSize) continue;
      final globalOrigin = renderObject.localToGlobal(Offset.zero);
      tiles.add(
        _MeasuredEdrTile(
          roomId: roomId,
          globalOrigin: globalOrigin,
          bounds: globalOrigin & renderObject.size,
          entry: entry,
        ),
      );
    }
    return tiles;
  }

  void _replaceRenderedTiles(Map<String, GlobalKey> next) {
    if (mapEquals(_renderedTiles, next)) return;
    final affectedRoomIds = {..._renderedTiles.keys, ...next.keys};
    _renderedTiles = Map.unmodifiable(next);
    for (final roomId in affectedRoomIds) {
      final entry = _entries[roomId];
      if (entry == null) continue;
      final rendered = identical(next[roomId], entry.renderKey);
      if (entry.renderState.value != rendered) {
        entry.renderState.value = rendered;
      }
    }
  }
}
