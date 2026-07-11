import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'generated/voice_capture_api.g.dart';
import 'voice_capture_contract.dart';
import 'voice_capture_mapping.dart';

typedef VoiceCaptureEventListener = void Function(VoiceCaptureEvent event);

final class VoiceCaptureEventSubscription {
  VoiceCaptureEventSubscription(this._onCancel);

  final VoidCallback _onCancel;
  var _cancelled = false;

  bool get isCancelled => _cancelled;

  void cancel() {
    if (_cancelled) return;
    _cancelled = true;
    _onCancel();
  }
}

final class VoiceCaptureEventRouter implements VoiceCaptureFlutterApi {
  VoiceCaptureEventRouter._();

  @visibleForTesting
  VoiceCaptureEventRouter.forTesting();

  static final VoiceCaptureEventRouter instance = VoiceCaptureEventRouter._();

  final Map<String, _OperationRoute> _operations = {};
  final Map<int, VoiceCaptureEventListener> _allListeners = {};
  var _nextToken = 0;
  var _installed = false;

  void ensureInstalled({BinaryMessenger? binaryMessenger}) {
    if (_installed) return;
    VoiceCaptureFlutterApi.setUp(this, binaryMessenger: binaryMessenger);
    _installed = true;
  }

  VoiceCaptureEventSubscription subscribe(
    String operationId,
    VoiceCaptureEventListener listener, {
    bool replayLatest = true,
  }) {
    if (operationId.isEmpty) {
      throw ArgumentError.value(
        operationId,
        'operationId',
        'Must not be empty',
      );
    }
    final route = _operations.putIfAbsent(operationId, _OperationRoute.new);
    final token = _nextToken++;
    route.listeners[token] = listener;
    final latest = route.latest;
    if (replayLatest && latest != null) {
      scheduleMicrotask(() {
        if (route.listeners[token] == listener) _notify(listener, latest);
      });
    }
    return VoiceCaptureEventSubscription(() {
      route.listeners.remove(token);
    });
  }

  VoiceCaptureEventSubscription subscribeAll(
    VoiceCaptureEventListener listener,
  ) {
    final token = _nextToken++;
    _allListeners[token] = listener;
    return VoiceCaptureEventSubscription(() {
      _allListeners.remove(token);
    });
  }

  void forgetOperation(String operationId) {
    _operations.remove(operationId);
  }

  @override
  void onCaptureEvent(VoiceCaptureEventDto event) {
    try {
      route(mapVoiceEvent(event));
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'interaction_foundation',
          context: ErrorDescription('while routing a native voice event'),
        ),
      );
    }
  }

  @visibleForTesting
  void route(VoiceCaptureEvent event) {
    if (event.operationId.isEmpty || event.sequence < 0) return;
    final route = _operations.putIfAbsent(
      event.operationId,
      _OperationRoute.new,
    );
    if (route.terminal || event.sequence <= route.lastSequence) return;
    route
      ..lastSequence = event.sequence
      ..latest = event
      ..terminal = event.isTerminal;

    for (final listener in List.of(route.listeners.values)) {
      _notify(listener, event);
    }
    for (final listener in List.of(_allListeners.values)) {
      _notify(listener, event);
    }
  }

  void _notify(VoiceCaptureEventListener listener, VoiceCaptureEvent event) {
    try {
      listener(event);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'interaction_foundation',
          context: ErrorDescription('while notifying a voice event listener'),
        ),
      );
    }
  }
}

final class _OperationRoute {
  final Map<int, VoiceCaptureEventListener> listeners = {};
  var lastSequence = -1;
  var terminal = false;
  VoiceCaptureEvent? latest;
}
