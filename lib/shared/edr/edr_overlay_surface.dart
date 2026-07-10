import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'edr_overlay_controller.dart';

final class EdrOverlaySurface extends StatefulWidget {
  const EdrOverlaySurface({required this.controller, super.key});

  static const viewType = 'margaritaville/edr-overlay';

  final EdrOverlayController controller;

  @override
  State<EdrOverlaySurface> createState() => _EdrOverlaySurfaceState();
}

final class _EdrOverlaySurfaceState extends State<EdrOverlaySurface> {
  int? _viewId;

  @override
  void dispose() {
    final viewId = _viewId;
    if (viewId != null) widget.controller.detachView(viewId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.supported ||
        kIsWeb ||
        defaultTargetPlatform != TargetPlatform.iOS) {
      return SizedBox.expand(key: widget.controller.surfaceKey);
    }
    return IgnorePointer(
      child: UiKitView(
        key: widget.controller.surfaceKey,
        viewType: EdrOverlaySurface.viewType,
        layoutDirection: TextDirection.ltr,
        hitTestBehavior: PlatformViewHitTestBehavior.transparent,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: (viewId) {
          _viewId = viewId;
          widget.controller.attachView(viewId);
        },
      ),
    );
  }
}
