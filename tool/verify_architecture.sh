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

if (( failed != 0 )); then
  exit 1
fi

echo "Architecture guard passed."
