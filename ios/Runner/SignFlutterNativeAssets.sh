#!/bin/sh

set -eu

if [ "${PLATFORM_NAME:-}" != "iphoneos" ]; then
  exit 0
fi

if [ "${CODE_SIGNING_ALLOWED:-YES}" = "NO" ] || [ -z "${EXPANDED_CODE_SIGN_IDENTITY:-}" ]; then
  exit 0
fi

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
