import 'package:flutter/widgets.dart';

import 'visual_runtime_activity_controller.dart';
import 'visual_runtime_scope.dart';

export 'visual_runtime_activity_controller.dart';

final class VisualRuntimeActivity extends StatefulWidget {
  const VisualRuntimeActivity({
    required this.active,
    required this.child,
    super.key,
  });

  final bool active;
  final Widget child;

  @override
  State<VisualRuntimeActivity> createState() => _VisualRuntimeActivityState();
}

final class _VisualRuntimeActivityState extends State<VisualRuntimeActivity> {
  final _client = Object();
  VisualRuntimeActivityController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextController = VisualRuntimeScope.maybeActivityControllerOf(
      context,
    );
    if (identical(nextController, _controller)) return;
    _controller?.remove(_client);
    _controller = nextController;
    _syncActivity();
  }

  @override
  void didUpdateWidget(covariant VisualRuntimeActivity oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) _syncActivity();
  }

  @override
  void dispose() {
    _controller?.remove(_client);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;

  void _syncActivity() {
    _controller?.setActive(_client, active: widget.active);
  }
}
