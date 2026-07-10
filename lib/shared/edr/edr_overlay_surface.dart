import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'edr_overlay_controller.dart';

/// One fixed native viewport behind the Flutter [ListView].
///
/// The view itself never participates in scrolling. Flutter sends batched
/// visible-tile coordinates after each scroll frame, while the original
/// platform scrollable keeps full ownership of physics and gestures.
final class EdrViewportSurface extends StatefulWidget {
  const EdrViewportSurface({required this.controller, super.key});

  static const viewType = 'margaritaville/edr-viewport';

  final EdrOverlayController controller;

  @override
  State<EdrViewportSurface> createState() => _EdrViewportSurfaceState();
}

final class _EdrViewportSurfaceState extends State<EdrViewportSurface> {
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
        viewType: EdrViewportSurface.viewType,
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
