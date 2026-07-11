#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

ios_dir="packages/interaction_foundation/ios/Classes"
android_dir="packages/interaction_foundation/android/src/main/kotlin/com/axr/interaction_foundation"
failed=0

require_pattern() {
  local pattern="$1"
  local path="$2"
  local message="$3"
  if ! rg -q "$pattern" "$path"; then
    echo "ERROR: $message"
    failed=1
  fi
}

require_pattern 'VoiceCaptureHostApi' \
  packages/interaction_foundation/pigeons/voice_capture_api.dart \
  "voice capture должен оставаться typed Pigeon API"
require_pattern "errorClassName: 'VoiceCapturePigeonError'" \
  packages/interaction_foundation/pigeons/voice_capture_api.dart \
  "Swift voice Pigeon error обязан иметь уникальное имя"
require_pattern "errorClassName: 'VoiceCaptureFlutterError'" \
  packages/interaction_foundation/pigeons/voice_capture_api.dart \
  "Kotlin voice Pigeon error обязан иметь уникальное имя"
require_pattern 'AVAudioRecorder' "$ios_dir/NativeVoiceCaptureRuntime.swift" \
  "voice capture обязан записывать файл через AVAudioRecorder"
require_pattern 'SFSpeechURLRecognitionRequest' "$ios_dir/NativeVoiceRecognition.swift" \
  "Speech обязан распознавать готовый файл"
require_pattern 'request\.addsPunctuation = addsPunctuation' \
  "$ios_dir/NativeVoiceRecognition.swift" \
  "addsPunctuation из typed request не должен игнорироваться"
require_pattern 'AVSampleRateKey: 44_100' "$ios_dir/NativeVoiceCaptureRuntime.swift" \
  "AAC sample rate должен оставаться 44.1 kHz"
require_pattern 'AVNumberOfChannelsKey: 1' "$ios_dir/NativeVoiceCaptureRuntime.swift" \
  "voice capture должен оставаться mono"
require_pattern 'interruptionNotification' "$ios_dir/NativeVoiceCaptureService.swift" \
  "native voice runtime обязан обрабатывать audio interruption"
require_pattern 'mediaServicesWereResetNotification' \
  "$ios_dir/NativeVoiceCaptureService.swift" \
  "native voice runtime обязан обрабатывать media-services reset"
require_pattern 'active\.terminalPhase = \.interrupted' \
  "$ios_dir/NativeVoiceCaptureRuntime.swift" \
  "interruption во время file transcription обязан стать terminal event"
require_pattern 'if active\.speechAllowed' \
  "$ios_dir/NativeVoiceCaptureRuntime.swift" \
  "отказ Speech не должен запрещать сохранение самой аудиозаметки"
require_pattern 'applicationDidEnterBackground' \
  "$ios_dir/NativeVoiceCaptureService.swift" \
  "native voice runtime обязан завершать запись при background"
require_pattern 'AndroidVoiceCaptureUnavailableService' \
  "$android_dir/InteractionFoundationPlugin.kt" \
  "Android обязан регистрировать typed unsupported voice adapter"

if rg -n 'AVAudioEngine|installTap|SFSpeechAudioBufferRecognitionRequest' \
  "$ios_dir" --glob '*.swift' --glob '!*.g.swift'; then
  echo "ERROR: live Speech/audio tap запрещён; используется только file transcription"
  failed=1
fi

if rg -n 'setCategory\(|setActive\(' "$ios_dir" \
  --glob '*.swift' \
  --glob '!*.g.swift' \
  --glob '!NativeAudioSessionCoordinator.swift'; then
  echo "ERROR: только NativeAudioSessionCoordinator может менять AVAudioSession"
  failed=1
fi

if rg -n 'MethodChannel|BasicMessageChannel' \
  packages/interaction_foundation/pigeons \
  packages/interaction_foundation/ios/Classes \
  packages/interaction_foundation/android/src/main \
  --glob '*.dart' --glob '*.swift' --glob '*.kt' \
  --glob '!*.g.swift' --glob '!*.g.kt'; then
  echo "ERROR: voice capture не должен обходить generated Pigeon bridge"
  failed=1
fi

while IFS= read -r file; do
  lines=$(wc -l < "$file" | tr -d ' ')
  if (( lines > 300 )); then
    echo "ERROR: handwritten native file $file содержит $lines строк (>300)"
    failed=1
  fi
done < <(
  find packages/interaction_foundation/ios/Classes \
       packages/interaction_foundation/android/src/main \
    -type f \( -name '*.swift' -o -name '*.kt' \) \
    ! -name '*.g.swift' ! -name '*.g.kt' | sort
)

if [[ "$failed" != "0" ]]; then
  exit 1
fi

echo "Voice capture native contract passed."
