#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

failed=0

if rg -n "package:(flutter|flutter_riverpod|drift)" \
  lib/features/work_session/domain --glob '*.dart'; then
  echo "ERROR: pure domain imports a framework package"
  failed=1
fi

if rg -n "features/.+/(data|presentation)/" \
  lib/features/work_session/domain --glob '*.dart'; then
  echo "ERROR: domain depends on an outer layer"
  failed=1
fi

if rg -n "package:(flutter|flutter_riverpod|shared_preferences)" \
  lib/features/settings/domain --glob '*.dart'; then
  echo "ERROR: settings domain imports a framework package"
  failed=1
fi

if rg -n "dart:convert|json(Encode|Decode)" \
  lib/features/settings/data --glob '*.dart'; then
  echo "ERROR: app settings must persist typed values, not a JSON blob"
  failed=1
fi

if rg -n "OceanKeyFlutterRun|com\.alex\.margaritaville\.swift" \
  lib pubspec.yaml ios/Runner; then
  echo "ERROR: sibling app identity leaked into Flutter runtime"
  failed=1
fi

if ! rg -q "com\.alex\.margaritaville\.flutter\.beta" \
  ios/Runner.xcodeproj/project.pbxproj; then
  echo "ERROR: beta bundle identity is missing"
  failed=1
fi

if ! rg -q 'applicationId = "com\.alex\.margaritaville\.flutter\.beta"' \
  android/app/build.gradle.kts; then
  echo "ERROR: Android beta application identity is missing"
  failed=1
fi

if rg -n "com\.alex\.margaritaville\.margaritaville_flutter" android; then
  echo "ERROR: generated Android identity leaked into the app shell"
  failed=1
fi

if rg -n "AnimationController|TickerProvider|Timer\.periodic" \
  lib/features/summary/presentation/widgets/room_status_tile.dart \
  lib/features/summary/presentation/widgets/room_visual_effect_surface.dart; then
  echo "ERROR: room cells must use the shared visual runtime, not per-cell clocks"
  failed=1
fi

if rg -n "AnimationController|TickerProvider|Timer\.periodic|BackdropFilter" \
  lib/features/background --glob '*.dart'; then
  echo "ERROR: background must use the shared visual runtime and no heavy blur"
  failed=1
fi

visual_runtime_hosts=$(rg -l "VisualRuntimeScope\(" lib/app lib/features \
  --glob '*.dart' | wc -l | tr -d ' ')
if [[ "$visual_runtime_hosts" != "1" ]]; then
  echo "ERROR: app must mount exactly one process-wide visual runtime scope"
  failed=1
fi

visual_clock_files=$(rg -l "AnimationController" \
  lib/shared/visual_runtime --glob '*.dart' | wc -l | tr -d ' ')
if [[ "$visual_clock_files" != "1" ]]; then
  echo "ERROR: shared visual runtime must own exactly one AnimationController"
  failed=1
fi

if rg -n "maxFramesPerSecond|minimumFrameInterval" \
  lib/app lib/shared/visual_runtime --glob '*.dart'; then
  echo "ERROR: shared visual runtime must follow OS vsync without an app FPS cap"
  failed=1
fi

if rg -n "MethodChannel|BasicMessageChannel" \
  lib/shared/edr ios/Runner \
  --glob '*.dart' --glob 'Edr*.swift' \
  --glob '!*.g.dart' --glob '!*.g.swift'; then
  echo "ERROR: EDR bridge must remain generated and type-safe through Pigeon"
  failed=1
fi

if rg -n "CADisplayLink|Timer\." ios/Runner/Edr*.swift; then
  echo "ERROR: native EDR must use Core Animation, not its own frame ticker"
  failed=1
fi

if rg -n "scaleForSectionWidth|geometryScale" \
  lib/features/summary test/features/summary --glob '*.dart'; then
  echo "ERROR: donor Summary geometry must stay fixed; only column width is flexible"
  failed=1
fi

if rg -n "MethodChannel|BasicMessageChannel" \
  packages/interaction_foundation/lib \
  packages/interaction_foundation/ios/Classes \
  packages/interaction_foundation/android/src/main \
  --glob '*.dart' --glob '*.swift' --glob '*.kt' \
  --glob '!*.g.dart' --glob '!*.g.swift' --glob '!*.g.kt'; then
  echo "ERROR: interaction feedback bridge must remain generated through Pigeon"
  failed=1
fi

if rg -n "Margaritaville|RoomDisplayStatus|com\.alex\.margaritaville" \
  packages/interaction_foundation/lib \
  packages/interaction_foundation/ios/Classes \
  packages/interaction_foundation/android/src/main \
  --glob '*.dart' --glob '*.swift' --glob '*.kt'; then
  echo "ERROR: shared interaction foundation contains app-specific policy or identity"
  failed=1
fi

if ! rg -q "RGBA16Float" ios/Runner/EdrFillView.swift || \
   ! rg -q "preferredDynamicRange = \.high" ios/Runner/EdrFillView.swift; then
  echo "ERROR: native iOS EDR surface lost its 16-bit/high-range contract"
  failed=1
fi

if (( failed != 0 )); then
  exit 1
fi

echo "Architecture guard passed."
