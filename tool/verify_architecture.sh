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

visual_clock_files=$(rg -l "AnimationController" \
  lib/shared/visual_runtime --glob '*.dart' | wc -l | tr -d ' ')
if [[ "$visual_clock_files" != "1" ]]; then
  echo "ERROR: shared visual runtime must own exactly one AnimationController"
  failed=1
fi

if (( failed != 0 )); then
  exit 1
fi

echo "Architecture guard passed."
