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
  final GlobalKey surfaceKey = GlobalKey(debugLabel: 'summary-edr-viewport');
  final Map<String, _EdrTileEntry> _entries = {};
  Set<String> _renderedRoomIds = const {};
  int? _viewId;
  bool _syncScheduled = false;
  bool _syncInProgress = false;
  bool _syncAgain = false;
  bool _scrollSyncInProgress = false;
  bool _disposed = false;
  int _layoutRevision = 0;
  int _scrollSequence = 0;
  double _scrollOffset = 0;
  double? _pendingScrollOffset;

  static const double effectBleed = 24;

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

  void updateScrollOffset(double scrollOffset) {
    if (!supported || _disposed || !scrollOffset.isFinite) return;
    _scrollOffset = scrollOffset;
    _pendingScrollOffset = scrollOffset;
    unawaited(_flushScrollOffset());
  }

  @override
  void dispose() {
    _disposed = true;
    final viewId = _viewId;
    if (viewId != null) {
      unawaited(_bridge.clearViewport(viewId, ++_layoutRevision));
    }
    _entries.clear();
    _pendingScrollOffset = null;
    _renderedRoomIds = const {};
    super.dispose();
  }

  void _scheduleSync() {
    if (!supported || _disposed || _syncScheduled) return;
    _syncScheduled = true;
    WidgetsBinding.instance.scheduleFrame();
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
    final surface = surfaceKey.currentContext?.findRenderObject();
    if (viewId == null || surface is! RenderBox || !surface.hasSize) return;
    final surfaceOrigin = surface.localToGlobal(Offset.zero);
    final viewport = (surfaceOrigin & surface.size).inflate(effectBleed);
    final measuredTiles = _measureTiles()
        .where((tile) => tile.bounds.overlaps(viewport))
        .toList(growable: false);
    final tiles = <EdrTileSnapshot>[
      for (final measured in measuredTiles)
        measured.snapshot(relativeTo: surfaceOrigin),
    ];
    final revision = ++_layoutRevision;
    try {
      await _bridge.configureViewport(viewId, revision, _scrollOffset, tiles);
    } catch (error) {
      debugPrint('Нативный EDR-overlay недоступен: $error');
      _replaceRenderedIds(const {});
      return;
    }
    if (_disposed || _viewId != viewId) return;
    _replaceRenderedIds({for (final tile in tiles) tile.roomId});
  }

  Future<void> _flushScrollOffset() async {
    if (_scrollSyncInProgress || _disposed) return;
    _scrollSyncInProgress = true;
    while (!_disposed) {
      final scrollOffset = _pendingScrollOffset;
      if (scrollOffset == null) break;
      _pendingScrollOffset = null;
      final viewId = _viewId;
      if (viewId == null) continue;
      try {
        await _bridge.updateScrollOffset(
          viewId,
          _layoutRevision,
          ++_scrollSequence,
          scrollOffset,
        );
      } catch (error) {
        debugPrint('Нативная синхронизация EDR-scroll недоступна: $error');
      }
    }
    _scrollSyncInProgress = false;
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
