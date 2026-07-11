import 'package:interaction_foundation/interaction_foundation.dart';

String? normalizeVoiceTranscript(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}

String roomVoiceStatusText(VoiceCaptureStatusCode code) => switch (code) {
  VoiceCaptureStatusCode.ready => 'Готово к записи',
  VoiceCaptureStatusCode.checkingAccess => 'Проверяю доступ...',
  VoiceCaptureStatusCode.speechDenied => 'Нет доступа к распознаванию речи',
  VoiceCaptureStatusCode.microphoneDenied => 'Нет доступа к микрофону',
  VoiceCaptureStatusCode.startingMicrophone => 'Запускаю микрофон...',
  VoiceCaptureStatusCode.recording => 'Идёт запись...',
  VoiceCaptureStatusCode.finishingTranscription => 'Завершаю расшифровку...',
  VoiceCaptureStatusCode.noRecording => 'Нет записи',
  VoiceCaptureStatusCode.speechUnavailable => 'Распознавание недоступно',
  VoiceCaptureStatusCode.completed => 'Готово',
  VoiceCaptureStatusCode.noRecognizedText => 'Нет распознанного текста',
  VoiceCaptureStatusCode.microphoneFailure => 'Не удалось запустить микрофон',
  VoiceCaptureStatusCode.interrupted => 'Запись прервана системой',
  VoiceCaptureStatusCode.mediaServicesReset => 'Аудиосистема была перезапущена',
  VoiceCaptureStatusCode.cancelled => 'Запись отменена',
  VoiceCaptureStatusCode.busy => 'Другая запись уже идёт',
  VoiceCaptureStatusCode.unsupported => 'Запись недоступна',
};
