#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

require() {
  local pattern="$1"
  local path="$2"
  local label="$3"
  if ! rg -q -- "$pattern" "$path"; then
    echo "Media foundation guard failed: missing $label" >&2
    exit 1
  fi
}

reject() {
  local pattern="$1"
  local path="$2"
  local label="$3"
  if rg -n -- "$pattern" "$path"; then
    echo "Media foundation guard failed: forbidden $label" >&2
    exit 1
  fi
}

require '^  camera: \^0\.12\.0\+1$' pubspec.yaml 'official camera dependency'
require 'ResolutionPreset\.max' \
  lib/shared/media/capture/photo_camera_session.dart \
  'maximum photo resolution policy'
require 'enableAudio: false' \
  lib/shared/media/capture/photo_camera_session.dart \
  'photo capture without AVAudioSession ownership'
require 'NSCameraUsageDescription' ios/Runner/Info.plist \
  'iOS camera permission copy'
require 'class MediaPromotionRecords' \
  lib/shared/persistence/tables/sync_contract_tables.dart \
  'durable promotion journal'
require 'MediaArtifactPresence' lib/shared/media/local_media_artifact_store.dart \
  'artifact recovery inspection'
require 'RoomMediaPromotionRecovery' lib/features/room_details/application/media \
  'startup promotion recovery'
require 'RoomMediaGarbageCollector' lib/features/room_details/application/media \
  'tombstone-first file garbage collection'
require '\.copying' lib/shared/media/local_media_artifact_store.dart \
  'untrusted copy before verified partial rename'
require 'quarantineMediaPromotion' \
  lib/features/room_details/application/media/room_media_promotion_recovery.dart \
  'terminal recovery quarantine'
require 'RoomMediaRecoveryGate' lib/app/margaritaville_app.dart \
  'startup recovery gate before work session UI'

reject 'image_picker|photo_manager' pubspec.yaml \
  'secondary camera or gallery dependency'
reject 'image_picker|photo_manager' lib \
  'secondary camera or gallery engine'
reject 'decodeImageFromList|instantiateImageCodec|encodeJpg|jpegData|Bitmap\.compress' \
  lib/shared/media 'original-media decode or re-encode in storage'
reject 'MethodChannel|EventChannel' lib/shared/media \
  'handwritten raw platform channel in media storage'

echo 'Media foundation contract guard passed.'
