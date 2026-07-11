part of 'edr_overlay_controller.dart';

typedef _EdrNativeCommand = Future<void> Function();

final class _EdrNativeBarrier {
  const _EdrNativeBarrier(this.command, this.completer);

  final _EdrNativeCommand command;
  final Completer<void> completer;
}

/// Serializes all platform work and coalesces scroll geometry to latest-only.
final class _EdrNativeCommandLane {
  _EdrNativeCommandLane({required this.onGeometryError});

  final void Function(Object error) onGeometryError;
  final Queue<_EdrNativeBarrier> _barriers = Queue();
  _EdrNativeCommand? _latestGeometry;
  bool _running = false;

  Future<void> submitBarrier(
    _EdrNativeCommand command, {
    bool dropGeometry = false,
  }) {
    if (dropGeometry) _latestGeometry = null;
    final completer = Completer<void>();
    _barriers.add(_EdrNativeBarrier(command, completer));
    _startPump();
    return completer.future;
  }

  void submitGeometry(_EdrNativeCommand command) {
    _latestGeometry = command;
    _startPump();
  }

  void dropGeometry() {
    _latestGeometry = null;
  }

  void _startPump() {
    if (_running) return;
    _run().ignore();
  }

  Future<void> _run() async {
    if (_running) return;
    _running = true;
    try {
      while (_barriers.isNotEmpty || _latestGeometry != null) {
        if (_barriers.isNotEmpty) {
          final barrier = _barriers.removeFirst();
          try {
            await barrier.command();
            barrier.completer.complete();
          } catch (error, stackTrace) {
            barrier.completer.completeError(error, stackTrace);
          }
          continue;
        }
        final geometry = _latestGeometry;
        _latestGeometry = null;
        try {
          await geometry!();
        } catch (error) {
          onGeometryError(error);
        }
      }
    } finally {
      _running = false;
      if (_barriers.isNotEmpty || _latestGeometry != null) _startPump();
    }
  }
}
