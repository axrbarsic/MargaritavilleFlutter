import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'edr_overlay_bridge.dart';
import 'generated/edr_overlay_api.g.dart';

part 'edr_overlay_measurement.dart';

final class EdrOverlayController extends ChangeNotifier {
  EdrOverlayController({EdrOverlayBridge? bridge, bool? supported})
    : _bridge = bridge ?? PigeonEdrOverlayBridge(),
      supported =
          supported ?? (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS);

  final EdrOverlayBridge _bridge;
  final bool supported;
  final GlobalKey contentKey = GlobalKey(debugLabel: 'summary-edr-content');
  final GlobalKey surfaceKey = GlobalKey(debugLabel: 'summary-edr-overlay');
  final Map<String, _EdrTileEntry> _entries = {};
  Set<String> _renderedRoomIds = const {};
  Rect? _overlayBounds;
  int? _viewId;
  bool _syncScheduled = false;
  bool _syncInProgress = false;
  bool _syncAgain = false;
  bool _disposed = false;

  static const double horizontalEffectBleed = 11;
  static const double verticalEffectBleed = 24;

  Rect? get overlayBounds => _overlayBounds;

  bool isTileRendered(String roomId) {
    return supported && _renderedRoomIds.contains(roomId);
  }

  void attachView(int viewId) {
    if (!supported || _disposed) return;
    _viewId = viewId;
    _scheduleSync();
  }

  void detachView(int viewId) {
    if (_viewId != viewId) return;
    _viewId = null;
    _replaceRenderedIds(const {});
  }

  void upsertTile({
    required String roomId,
    required GlobalKey renderKey,
    required int baseColorArgb,
    required double cornerRadius,
    required bool vipHdrEnabled,
    required bool vipJellyEnabled,
    required double vipJellySpeed,
    required double springIntensity,
    int? pulseGeneration,
    int? pulseColorArgb,
    int? pulseStartedAtMicros,
  }) {
    if (!supported || _disposed) return;
    final next = _EdrTileEntry(
      renderKey: renderKey,
      baseColorArgb: baseColorArgb,
      cornerRadius: cornerRadius,
      vipHdrEnabled: vipHdrEnabled,
      vipJellyEnabled: vipJellyEnabled,
      vipJellySpeed: vipJellySpeed,
      pulseGeneration: pulseGeneration,
      pulseColorArgb: pulseColorArgb,
      pulseStartedAtMicros: pulseStartedAtMicros,
      springIntensity: springIntensity,
    );
    if (_entries[roomId] == next) return;
    _entries[roomId] = next;
    _scheduleSync();
  }

  void removeTile(String roomId) {
    if (_entries.remove(roomId) == null) return;
    if (_renderedRoomIds.contains(roomId)) {
      _replaceRenderedIds({..._renderedRoomIds}..remove(roomId));
    }
    _scheduleSync();
  }

  void requestGeometrySync() {
    _scheduleSync();
  }

  @override
  void dispose() {
    _disposed = true;
    final viewId = _viewId;
    if (viewId != null) unawaited(_bridge.clearTiles(viewId));
    _entries.clear();
    _renderedRoomIds = const {};
    super.dispose();
  }

  void _scheduleSync() {
    if (!supported || _disposed || _syncScheduled) return;
    _syncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      unawaited(_synchronize());
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
    final viewId = _viewId;
    if (_disposed) return;
    final measuredTiles = _measureTiles();
    final nextBounds = _effectBounds(measuredTiles);
    if (_replaceOverlayBounds(nextBounds)) {
      if (nextBounds == null && viewId != null) {
        await _bridge.clearTiles(viewId);
        _replaceRenderedIds(const {});
      }
      _scheduleSync();
      return;
    }
    final surface = surfaceKey.currentContext?.findRenderObject();
    if (viewId == null || surface is! RenderBox || !surface.hasSize) return;
    final surfaceOrigin = surface.localToGlobal(Offset.zero);
    final tiles = <EdrTileSnapshot>[
      for (final measured in measuredTiles)
        measured.snapshot(relativeTo: surfaceOrigin),
    ];
    try {
      if (tiles.isEmpty) {
        await _bridge.clearTiles(viewId);
      } else {
        await _bridge.updateTiles(viewId, tiles);
      }
    } catch (error) {
      debugPrint('Нативный EDR-overlay недоступен: $error');
      _replaceRenderedIds(const {});
      return;
    }
    if (_disposed || _viewId != viewId) return;
    _replaceRenderedIds({for (final tile in tiles) tile.roomId});
  }

  List<_MeasuredEdrTile> _measureTiles() {
    final content = contentKey.currentContext?.findRenderObject();
    final fallbackSurface = surfaceKey.currentContext?.findRenderObject();
    final coordinateSpace = content is RenderBox && content.hasSize
        ? content
        : fallbackSurface is RenderBox && fallbackSurface.hasSize
        ? fallbackSurface
        : null;
    if (coordinateSpace == null) return const [];
    final coordinateOrigin = coordinateSpace.localToGlobal(Offset.zero);
    final tiles = <_MeasuredEdrTile>[];
    for (final MapEntry(key: roomId, value: entry) in _entries.entries) {
      final renderObject = entry.renderKey.currentContext?.findRenderObject();
      if (renderObject is! RenderBox || !renderObject.hasSize) continue;
      final globalOrigin = renderObject.localToGlobal(Offset.zero);
      final origin = globalOrigin - coordinateOrigin;
      tiles.add(
        _MeasuredEdrTile(
          roomId: roomId,
          globalOrigin: globalOrigin,
          bounds: origin & renderObject.size,
          entry: entry,
        ),
      );
    }
    return tiles;
  }

  Rect? _effectBounds(List<_MeasuredEdrTile> tiles) {
    if (tiles.isEmpty) return null;
    var union = tiles.first.bounds;
    for (final tile in tiles.skip(1)) {
      union = union.expandToInclude(tile.bounds);
    }
    return Rect.fromLTRB(
      union.left - horizontalEffectBleed,
      union.top - verticalEffectBleed,
      union.right + horizontalEffectBleed,
      union.bottom + verticalEffectBleed,
    );
  }

  bool _replaceOverlayBounds(Rect? next) {
    if (_overlayBounds == next) return false;
    _overlayBounds = next;
    notifyListeners();
    return true;
  }

  void _replaceRenderedIds(Set<String> next) {
    if (setEquals(_renderedRoomIds, next)) return;
    _renderedRoomIds = Set.unmodifiable(next);
    notifyListeners();
  }
}

@immutable
final class _EdrTileEntry {
  const _EdrTileEntry({
    required this.renderKey,
    required this.baseColorArgb,
    required this.cornerRadius,
    required this.vipHdrEnabled,
    required this.vipJellyEnabled,
    required this.vipJellySpeed,
    required this.pulseGeneration,
    required this.pulseColorArgb,
    required this.pulseStartedAtMicros,
    required this.springIntensity,
  });

  final GlobalKey renderKey;
  final int baseColorArgb;
  final double cornerRadius;
  final bool vipHdrEnabled;
  final bool vipJellyEnabled;
  final double vipJellySpeed;
  final int? pulseGeneration;
  final int? pulseColorArgb;
  final int? pulseStartedAtMicros;
  final double springIntensity;

  @override
  bool operator ==(Object other) {
    return other is _EdrTileEntry &&
        other.renderKey == renderKey &&
        other.baseColorArgb == baseColorArgb &&
        other.cornerRadius == cornerRadius &&
        other.vipHdrEnabled == vipHdrEnabled &&
        other.vipJellyEnabled == vipJellyEnabled &&
        other.vipJellySpeed == vipJellySpeed &&
        other.pulseGeneration == pulseGeneration &&
        other.pulseColorArgb == pulseColorArgb &&
        other.pulseStartedAtMicros == pulseStartedAtMicros &&
        other.springIntensity == springIntensity;
  }

  @override
  int get hashCode => Object.hash(
    renderKey,
    baseColorArgb,
    cornerRadius,
    vipHdrEnabled,
    vipJellyEnabled,
    vipJellySpeed,
    pulseGeneration,
    pulseColorArgb,
    pulseStartedAtMicros,
    springIntensity,
  );
}
