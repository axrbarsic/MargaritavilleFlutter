import 'dart:async';

import 'package:interaction_foundation/interaction_foundation.dart';

import 'room_voice_capture_save.dart';
import 'room_voice_capture_state.dart';
import 'room_voice_capture_status.dart';
import 'room_voice_id_factory.dart';

final class RoomVoiceCaptureCoordinator {
  RoomVoiceCaptureCoordinator({
    required this.sessionId,
    required this.roomNumber,
    required VoiceCaptureBridge bridge,
    required RoomVoiceCaptureSave saveCapture,
    required RoomVoiceIdFactory idFactory,
    required DateTime Function() now,
  }) : _bridge = bridge,
       _saveCapture = saveCapture,
       _idFactory = idFactory,
       _now = now;

  final String sessionId;
  final String roomNumber;
  final VoiceCaptureBridge _bridge;
  final RoomVoiceCaptureSave _saveCapture;
  final RoomVoiceIdFactory _idFactory;
  final DateTime Function() _now;
  final StreamController<RoomVoiceCaptureState> _states =
      StreamController.broadcast();

  RoomVoiceCaptureState _state = const RoomVoiceCaptureState.idle();
  VoiceCaptureEventSubscription? _subscription;
  VoiceCaptureResult? _pendingResult;
  VoiceCaptureStatusCode? _pendingTerminalStatus;
  Future<void>? _finalizeFuture;
  var _disposed = false;
  var _finalizing = false;

  RoomVoiceCaptureState get state => _state;
  Stream<RoomVoiceCaptureState> get states => _states.stream;

  Future<void> initialize() async {
    try {
      final capabilities = await _bridge.getCapabilities();
      if (!capabilities.supported) {
        _set(
          RoomVoiceCaptureState(
            phase: RoomVoiceCapturePhase.unsupported,
            statusText: capabilities.unavailableReason ?? 'Запись недоступна',
          ),
        );
      }
    } on VoiceCaptureFailure catch (error) {
      _set(_failure(error.message));
    }
  }

  Future<void> toggle() async {
    if (_disposed) return;
    if (_state.canRetrySave && _pendingResult != null) {
      await _beginFinalize(
        _pendingResult!,
        _pendingTerminalStatus ?? VoiceCaptureStatusCode.completed,
      );
      return;
    }
    switch (_state.phase) {
      case RoomVoiceCapturePhase.idle:
      case RoomVoiceCapturePhase.saved:
        await _start();
        return;
      case RoomVoiceCapturePhase.recording:
        await _stop();
        return;
      case RoomVoiceCapturePhase.requestingPermission:
      case RoomVoiceCapturePhase.starting:
      case RoomVoiceCapturePhase.finishing:
      case RoomVoiceCapturePhase.failed:
      case RoomVoiceCapturePhase.unsupported:
        return;
    }
  }

  Future<void> cancel() async {
    await _finalizeFuture;
    final pendingResult = _pendingResult;
    if (pendingResult != null) {
      try {
        await _bridge.releaseResult(pendingResult.resultId);
      } catch (_) {}
      _resetOperation();
      _set(const RoomVoiceCaptureState.idle());
      return;
    }
    final operationId = _state.operationId;
    if (operationId == null) return;
    try {
      await _bridge.cancelCapture(operationId);
    } finally {
      _resetOperation();
      _set(const RoomVoiceCaptureState.idle());
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _finalizeFuture;
    final operationId = _state.operationId;
    final pendingResult = _pendingResult;
    if (pendingResult != null) {
      try {
        await _bridge.releaseResult(pendingResult.resultId);
      } catch (_) {}
    } else if (operationId != null &&
        _state.phase != RoomVoiceCapturePhase.saved) {
      try {
        await _bridge.cancelCapture(operationId);
      } catch (_) {}
    }
    _subscription?.cancel();
    if (operationId != null) _bridge.forgetOperation(operationId);
    await _states.close();
  }

  Future<void> _start() async {
    final operationId = _idFactory('voice-operation');
    final mediaId = _idFactory('voice-media');
    _resetOperation();
    _subscription = _bridge.subscribe(operationId, _handleEvent);
    _set(
      RoomVoiceCaptureState(
        phase: RoomVoiceCapturePhase.requestingPermission,
        statusText: 'Проверяю доступ...',
        operationId: operationId,
        mediaId: mediaId,
      ),
    );
    try {
      final acknowledgement = await _bridge.startCapture(
        VoiceCaptureStartRequest(operationId: operationId, mediaId: mediaId),
      );
      if (!acknowledgement.accepted &&
          _state.operationId == operationId &&
          _state.phase != RoomVoiceCapturePhase.failed) {
        _set(_failure(roomVoiceStatusText(acknowledgement.statusCode)));
      }
    } on VoiceCaptureFailure catch (error) {
      if (_state.operationId == operationId) _set(_failure(error.message));
    }
  }

  Future<void> _stop() async {
    final operationId = _state.operationId;
    if (operationId == null) return;
    _set(_stateFor(RoomVoiceCapturePhase.finishing, 'Завершаю расшифровку...'));
    try {
      final acknowledgement = await _bridge.stopCapture(operationId);
      if (!acknowledgement.accepted && _state.operationId == operationId) {
        _set(_failure(roomVoiceStatusText(acknowledgement.statusCode)));
      }
    } on VoiceCaptureFailure catch (error) {
      if (_state.operationId == operationId) _set(_failure(error.message));
    }
  }

  void _handleEvent(VoiceCaptureEvent event) {
    if (_disposed || event.operationId != _state.operationId) return;
    switch (event.phase) {
      case VoiceCapturePhase.requestingPermissions:
        _set(
          _stateFor(
            RoomVoiceCapturePhase.requestingPermission,
            'Проверяю доступ...',
          ),
        );
        return;
      case VoiceCapturePhase.starting:
        _set(_stateFor(RoomVoiceCapturePhase.starting, 'Запускаю микрофон...'));
        return;
      case VoiceCapturePhase.recording:
        _set(_stateFor(RoomVoiceCapturePhase.recording, 'Идёт запись...'));
        return;
      case VoiceCapturePhase.finishing:
        _set(
          _stateFor(RoomVoiceCapturePhase.finishing, 'Завершаю расшифровку...'),
        );
        return;
      case VoiceCapturePhase.completed:
      case VoiceCapturePhase.interrupted:
        final result = event.result;
        if (result == null) {
          _set(_failure(roomVoiceStatusText(event.statusCode)));
        } else {
          unawaited(_beginFinalize(result, event.statusCode));
        }
        return;
      case VoiceCapturePhase.failed:
        _set(_failure(roomVoiceStatusText(event.statusCode)));
        return;
      case VoiceCapturePhase.cancelled:
        _resetOperation();
        _set(const RoomVoiceCaptureState.idle());
        return;
      case VoiceCapturePhase.idle:
        _set(const RoomVoiceCaptureState.idle());
        return;
    }
  }

  Future<void> _finalize(
    VoiceCaptureResult result,
    VoiceCaptureStatusCode terminalStatus,
  ) async {
    if (_finalizing || _disposed) return;
    _finalizing = true;
    _pendingResult = result;
    _pendingTerminalStatus = terminalStatus;
    _set(_stateFor(RoomVoiceCapturePhase.finishing, 'Сохраняю запись...'));
    try {
      final mediaId = _state.mediaId!;
      await _saveCapture(
        result: result,
        mediaId: mediaId,
        sessionId: sessionId,
        roomNumber: roomNumber,
        issuedAt: _now().toUtc(),
      );
      _pendingResult = null;
      _pendingTerminalStatus = null;
      _subscription?.cancel();
      _bridge.forgetOperation(result.operationId);
      try {
        await _bridge.releaseResult(result.resultId);
      } catch (_) {
        // Durable app media must never be deleted because temp cleanup failed.
      }
      _set(
        RoomVoiceCaptureState(
          phase: RoomVoiceCapturePhase.saved,
          statusText: roomVoiceStatusText(terminalStatus),
          operationId: result.operationId,
          mediaId: mediaId,
        ),
      );
    } catch (_) {
      _finalizing = false;
      _set(
        RoomVoiceCaptureState(
          phase: RoomVoiceCapturePhase.failed,
          statusText: 'Не удалось сохранить запись. Нажмите, чтобы повторить.',
          operationId: result.operationId,
          mediaId: _state.mediaId,
          canRetrySave: true,
        ),
      );
    } finally {
      _finalizing = false;
    }
  }

  Future<void> _beginFinalize(
    VoiceCaptureResult result,
    VoiceCaptureStatusCode terminalStatus,
  ) {
    final existing = _finalizeFuture;
    if (existing != null) return existing;
    final future = _finalize(result, terminalStatus);
    _finalizeFuture = future.whenComplete(() {
      _finalizeFuture = null;
    });
    return _finalizeFuture!;
  }

  RoomVoiceCaptureState _stateFor(RoomVoiceCapturePhase phase, String status) =>
      RoomVoiceCaptureState(
        phase: phase,
        statusText: status,
        operationId: _state.operationId,
        mediaId: _state.mediaId,
      );

  RoomVoiceCaptureState _failure(String status) =>
      _stateFor(RoomVoiceCapturePhase.failed, status);
  void _resetOperation() {
    final operationId = _state.operationId;
    _subscription?.cancel();
    _subscription = null;
    if (operationId != null) _bridge.forgetOperation(operationId);
    _pendingResult = null;
    _pendingTerminalStatus = null;
  }

  void _set(RoomVoiceCaptureState value) {
    if (_disposed) return;
    _state = value;
    _states.add(value);
  }
}
