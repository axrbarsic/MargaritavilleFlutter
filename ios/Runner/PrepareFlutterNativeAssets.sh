#!/bin/sh

set -eu

case "${PLATFORM_NAME:-}" in
  iphoneos)
    expected_platform="IOS"
    ;;
  iphonesimulator)
    expected_platform="IOSSIMULATOR"
    ;;
  *)
    exit 0
    ;;
esac

native_assets_dir="${SRCROOT}/../${FLUTTER_BUILD_DIR:-build}/native_assets/ios"
flutter_build_root="${SRCROOT}/../.dart_tool/flutter_build"

invalidate_ios_install_stamps() {
  if [ ! -d "${flutter_build_root}" ]; then
    return
  fi

  for manifest in "${flutter_build_root}"/*/native_assets.json; do
    if [ -f "${manifest}" ] && /usr/bin/grep -q '"ios_' "${manifest}"; then
      /bin/rm -f "$(dirname "${manifest}")/install_code_assets.stamp"
    fi
  done
}

if [ ! -d "${native_assets_dir}" ]; then
  invalidate_ios_install_stamps
  exit 0
fi

for framework in "${native_assets_dir}"/*.framework; do
  if [ ! -d "${framework}" ]; then
    continue
  fi

  framework_name="$(basename "${framework}" .framework)"
  executable="${framework}/${framework_name}"
  if [ ! -f "${executable}" ]; then
    continue
  fi

  actual_platform="$(xcrun vtool -show-build "${executable}" 2>/dev/null \
    | /usr/bin/awk '$1 == "platform" { print $2; exit }')"

  if [ "${actual_platform}" != "${expected_platform}" ]; then
    echo "warning: Removing stale Flutter native assets: ${actual_platform:-UNKNOWN}, expected ${expected_platform}."
    /bin/rm -rf "${native_assets_dir}"
    invalidate_ios_install_stamps
    exit 0
  fi
done
