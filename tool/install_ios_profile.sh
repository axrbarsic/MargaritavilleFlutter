#!/usr/bin/env bash
set -euo pipefail

device_id="${1:-00008150-001418301E68C01C}"
app_path="${2:-build/ios/iphoneos/Runner.app}"
bundle_id="com.alex.margaritaville.flutter.beta"

if [[ ! -d "$app_path" ]]; then
  echo "iOS app bundle not found: $app_path" >&2
  exit 1
fi

tool/verify_ios_app_bundle.sh "$app_path"

apps_json="$(mktemp)"
processes_json="$(mktemp)"
trap 'rm -f "$apps_json" "$processes_json"' EXIT

xcrun devicectl device info apps \
  --device "$device_id" \
  --json-output "$apps_json" >/dev/null

installed_url="$({
  jq -r \
    --arg bundle_id "$bundle_id" \
    '.result.apps[] | select(.bundleIdentifier == $bundle_id) | .url' \
    "$apps_json"
} | head -n 1)"

if [[ -n "$installed_url" ]]; then
  xcrun devicectl device info processes \
    --device "$device_id" \
    --json-output "$processes_json" >/dev/null

  while IFS= read -r pid; do
    [[ -z "$pid" ]] && continue
    echo "Terminating installed Margaritaville process $pid before update..."
    xcrun devicectl device process terminate \
      --device "$device_id" \
      --pid "$pid" \
      --kill
  done < <(
    jq -r \
      --arg installed_url "$installed_url" \
      '.result.runningProcesses[] |
       select(.executable | startswith($installed_url)) |
       .processIdentifier' \
      "$processes_json"
  )
fi

xcrun devicectl device install app \
  --device "$device_id" \
  "$app_path"

xcrun devicectl device process launch \
  --device "$device_id" \
  --terminate-existing \
  "$bundle_id"
