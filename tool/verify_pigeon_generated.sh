#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

outputs=(
  lib/shared/edr/generated/edr_overlay_api.g.dart
  ios/Runner/EdrOverlayApi.g.swift
  android/app/src/main/kotlin/com/alex/margaritaville/flutter/beta/edr/EdrOverlayApi.g.kt
  packages/interaction_foundation/lib/src/generated/voice_capture_api.g.dart
  packages/interaction_foundation/ios/Classes/VoiceCaptureApi.g.swift
  packages/interaction_foundation/android/src/main/kotlin/com/axr/interaction_foundation/VoiceCaptureApi.g.kt
)
temporary_directory="$(mktemp -d)"

restore_outputs() {
  for output in "${outputs[@]}"; do
    cp "$temporary_directory/$output" "$output"
  done
  rm -rf "$temporary_directory"
}
trap restore_outputs EXIT

for output in "${outputs[@]}"; do
  mkdir -p "$temporary_directory/$(dirname "$output")"
  cp "$output" "$temporary_directory/$output"
done

dart run pigeon --input pigeons/edr_overlay_api.dart
dart format lib/shared/edr/generated/edr_overlay_api.g.dart >/dev/null
(
  cd packages/interaction_foundation
  dart run pigeon --input pigeons/voice_capture_api.dart
)
dart format \
  packages/interaction_foundation/lib/src/generated/voice_capture_api.g.dart \
  >/dev/null
perl -pi -e 's/[ \t]+$//' \
  packages/interaction_foundation/android/src/main/kotlin/com/axr/interaction_foundation/VoiceCaptureApi.g.kt

for output in "${outputs[@]}"; do
  if ! cmp -s "$temporary_directory/$output" "$output"; then
    echo "ERROR: $output не соответствует pigeons/edr_overlay_api.dart"
    exit 1
  fi
done

echo "Pigeon generation contract passed."
