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

processes_json="$(mktemp)"
trap 'rm -f "$processes_json"' EXIT

xcrun devicectl device info processes \
  --device "$device_id" \
  --json-output "$processes_json" >/dev/null

# CoreDevice can leave a process from an older dev bundle alive after the app
# registry already points at a newer installation URL. Those orphaned processes
# are no longer discoverable by bundle id, but keep Runner's SQLite connection.
while IFS= read -r pid; do
  [[ -z "$pid" ]] && continue
  echo "Terminating stale Flutter Runner process $pid before update..."
  xcrun devicectl device process terminate \
    --device "$device_id" \
    --pid "$pid" \
    --kill
done < <(
  jq -r \
    '.result.runningProcesses[] |
     select((.executable // "") | endswith("/Runner.app/Runner")) |
     .processIdentifier' \
    "$processes_json"
)

xcrun devicectl device install app \
  --device "$device_id" \
  "$app_path"

xcrun devicectl device process launch \
  --device "$device_id" \
  --terminate-existing \
  "$bundle_id"

xcrun devicectl device info processes \
  --device "$device_id" \
  --json-output "$processes_json" >/dev/null

runner_count="$({
  jq '[.result.runningProcesses[] |
       select((.executable // "") | endswith("/Runner.app/Runner"))] |
      length' "$processes_json"
})"
if [[ "$runner_count" != "1" ]]; then
  echo "Expected one Flutter Runner after install, found $runner_count" >&2
  exit 1
fi
