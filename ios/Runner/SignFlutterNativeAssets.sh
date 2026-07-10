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

frameworks_dir="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"

if [ ! -d "${frameworks_dir}" ]; then
  exit 0
fi

for framework in "${frameworks_dir}"/*.framework; do
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
    echo "error: ${framework_name}.framework targets ${actual_platform:-UNKNOWN}; expected ${expected_platform}." >&2
    exit 1
  fi

  if [ "${PLATFORM_NAME}" != "iphoneos" ] || \
     [ "${CODE_SIGNING_ALLOWED:-YES}" = "NO" ] || \
     [ -z "${EXPANDED_CODE_SIGN_IDENTITY:-}" ]; then
    continue
  fi

  team_identifier="$(/usr/bin/codesign -d --verbose=4 "${executable}" 2>&1 \
    | /usr/bin/sed -n 's/^TeamIdentifier=//p')"

  if [ -z "${team_identifier}" ] || [ "${team_identifier}" = "not set" ]; then
    /usr/bin/codesign \
      --force \
      --verbose \
      --sign "${EXPANDED_CODE_SIGN_IDENTITY}" \
      "${framework}"
  fi
done
