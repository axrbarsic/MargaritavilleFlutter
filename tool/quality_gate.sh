#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

dart run build_runner build
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --no-pub
dart run tool/check_file_size.dart
tool/verify_architecture.sh
