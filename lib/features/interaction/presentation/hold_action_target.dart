import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../domain/hold_action_policy.dart';

final class HoldActionTarget extends StatefulWidget {
  const HoldActionTarget({
    required this.semanticLabel,
    required this.onActivate,
    required this.child,
    this.policy = HoldActionPolicy.donor,
    this.enabled = true,
    super.key,
  });

  final String semanticLabel;
  final VoidCallback onActivate;
  final Widget child;
  final HoldActionPolicy policy;
  final bool enabled;

  @override
  State<HoldActionTarget> createState() => _HoldActionTargetState();
}

final class _HoldActionTargetState extends State<HoldActionTarget> {
  var _activationLocked = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: widget.semanticLabel,
      onLongPress: widget.enabled ? _activateOnce : null,
      child: RawGestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        gestures: <Type, GestureRecognizerFactory>{
          LongPressGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
                () => LongPressGestureRecognizer(
                  duration: widget.policy.commitDelay,
                ),
                (recognizer) {
                  recognizer.onLongPress = widget.enabled
                      ? _activateOnce
                      : null;
                },
              ),
        },
        child: widget.child,
      ),
    );
  }

  void _activateOnce() {
    if (!widget.enabled || _activationLocked) return;
    _activationLocked = true;
    widget.onActivate();
    scheduleMicrotask(() {
      if (mounted) _activationLocked = false;
    });
  }
}
