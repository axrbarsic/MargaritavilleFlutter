import 'dart:async';

import 'package:flutter/widgets.dart';

import '../domain/hold_action_policy.dart';

final class HoldActionTarget extends StatefulWidget {
  const HoldActionTarget({
    required this.semanticLabel,
    required this.onActivate,
    required this.child,
    this.onHoldStart,
    this.onHoldWarning,
    this.onHoldCommit,
    this.policy = HoldActionPolicy.donor,
    this.enabled = true,
    super.key,
  });

  final String semanticLabel;
  final VoidCallback onActivate;
  final Widget child;
  final VoidCallback? onHoldStart;
  final VoidCallback? onHoldWarning;
  final VoidCallback? onHoldCommit;
  final HoldActionPolicy policy;
  final bool enabled;

  @override
  State<HoldActionTarget> createState() => _HoldActionTargetState();
}

final class _HoldActionTargetState extends State<HoldActionTarget> {
  Timer? _startTimer;
  Timer? _warningTimer;
  Timer? _commitTimer;
  int? _activePointer;
  Offset? _origin;
  var _didCommit = false;

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: widget.semanticLabel,
      onTap: widget.enabled ? widget.onActivate : null,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _begin,
        onPointerMove: _move,
        onPointerUp: _end,
        onPointerCancel: _cancel,
        child: widget.child,
      ),
    );
  }

  void _begin(PointerDownEvent event) {
    if (!widget.enabled || _activePointer != null) return;
    _activePointer = event.pointer;
    _origin = event.position;
    _didCommit = false;
    _cancelTimers();
    _startTimer = Timer(widget.policy.holdStartDelay, () {
      if (_isActive) widget.onHoldStart?.call();
    });
    _warningTimer = Timer(widget.policy.holdWarningDelay, () {
      if (_isActive) widget.onHoldWarning?.call();
    });
    _commitTimer = Timer(widget.policy.commitDelay, _commit);
  }

  void _move(PointerMoveEvent event) {
    if (event.pointer != _activePointer || _didCommit) return;
    final origin = _origin;
    if (origin == null) return;
    if ((event.position - origin).distance > widget.policy.maximumMovement) {
      _cancelPress();
    }
  }

  void _end(PointerUpEvent event) {
    if (event.pointer == _activePointer) _cancelPress();
  }

  void _cancel(PointerCancelEvent event) {
    if (event.pointer == _activePointer) _cancelPress();
  }

  void _commit() {
    if (!_isActive) return;
    _didCommit = true;
    _cancelTimers();
    widget.onHoldCommit?.call();
    widget.onActivate();
  }

  bool get _isActive => _activePointer != null && !_didCommit;

  void _cancelPress() {
    _cancelTimers();
    _activePointer = null;
    _origin = null;
    _didCommit = false;
  }

  void _cancelTimers() {
    _startTimer?.cancel();
    _warningTimer?.cancel();
    _commitTimer?.cancel();
    _startTimer = null;
    _warningTimer = null;
    _commitTimer = null;
  }
}
