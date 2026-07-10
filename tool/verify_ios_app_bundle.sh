#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

app_path="${1:-build/ios/iphoneos/Runner.app}"
expected_platform="${2:-IOS}"

if [[ ! -d "$app_path" ]]; then
  echo "ERROR: iOS app bundle not found: $app_path" >&2
  exit 1
fi

checked=0
while IFS= read -r -d '' framework; do
  framework_name="$(basename "$framework" .framework)"
  executable="$framework/$framework_name"
  [[ -f "$executable" ]] || continue

  actual_platform="$(xcrun vtool -show-build "$executable" 2>/dev/null \
    | awk '$1 == "platform" { print $2; exit }')"
  if [[ "$actual_platform" != "$expected_platform" ]]; then
    echo "ERROR: $framework_name targets ${actual_platform:-UNKNOWN}; expected $expected_platform." >&2
    exit 1
  fi
  ((checked += 1))
done < <(find "$app_path/Frameworks" -maxdepth 1 -type d -name '*.framework' -print0)

if (( checked == 0 )); then
  echo "ERROR: no embedded iOS frameworks were checked." >&2
  exit 1
fi

codesign --verify --deep --strict --verbose=2 "$app_path"
echo "iOS bundle guard passed ($checked frameworks, platform $expected_platform)."
