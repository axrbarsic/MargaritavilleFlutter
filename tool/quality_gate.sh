#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

tool/verify_pigeon_generated.sh
tool/verify_voice_capture_contract.sh
tool/verify_media_foundation_contract.sh
tool/verify_drift_schema.sh
dart run build_runner build
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --no-pub
(
  cd android
  if [[ -z "${JAVA_HOME:-}" ]] && \
    [[ -d /opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home ]]; then
    export JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home
  fi
  ./gradlew :app:testDebugUnitTest
)
dart run tool/check_file_size.dart
tool/verify_architecture.sh
