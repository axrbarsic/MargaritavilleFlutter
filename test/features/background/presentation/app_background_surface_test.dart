import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margaritaville_flutter/features/background/presentation/app_background_surface.dart';
import 'package:margaritaville_flutter/features/settings/domain/models/app_background_mode.dart';
import 'package:margaritaville_flutter/shared/visual_runtime/visual_frame_clock.dart';
import 'package:margaritaville_flutter/shared/visual_runtime/visual_runtime_scope.dart';

void main() {
  testWidgets('Matrix mode mounts one shared-clock canvas', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: VisualRuntimeScope(
          policy: const VisualFramePolicy(),
          enabled: true,
          child: const AppBackgroundSurface(
            mode: AppBackgroundMode.matrixRain,
            matrixSpeed: 1,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('matrix-rain-canvas')), findsOneWidget);
  });

  testWidgets('off mode leaves a static black surface', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AppBackgroundSurface(mode: AppBackgroundMode.off, matrixSpeed: 1),
      ),
    );

    expect(find.byKey(const Key('matrix-rain-canvas')), findsNothing);
    expect(find.byType(ColoredBox), findsWidgets);
  });
}
