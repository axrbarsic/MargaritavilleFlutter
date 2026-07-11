import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/generated/voice_capture_api.g.dart',
    dartOptions: DartOptions(),
    dartPackageName: 'interaction_foundation',
    swiftOut: 'ios/Classes/VoiceCaptureApi.g.swift',
    swiftOptions: SwiftOptions(errorClassName: 'VoiceCapturePigeonError'),
    kotlinOut:
        'android/src/main/kotlin/com/axr/interaction_foundation/VoiceCaptureApi.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'com.axr.interaction_foundation',
      errorClassName: 'VoiceCaptureFlutterError',
    ),
  ),
)
enum VoiceCapturePhaseDto {
  idle,
  requestingPermissions,
  starting,
  recording,
  finishing,
  completed,
  failed,
  interrupted,
  cancelled,
}

enum VoiceCaptureStatusCodeDto {
  ready,
  checkingAccess,
  speechDenied,
  microphoneDenied,
  startingMicrophone,
  recording,
  finishingTranscription,
  noRecording,
  speechUnavailable,
  completed,
  noRecognizedText,
  microphoneFailure,
  interrupted,
  mediaServicesReset,
  cancelled,
  busy,
  unsupported,
}

enum VoicePermissionStateDto {
  notDetermined,
  denied,
  restricted,
  granted,
  unsupported,
}

class VoiceCaptureCapabilitiesDto {
  late int contractVersion;
  late bool supported;
  late VoicePermissionStateDto speechPermission;
  late VoicePermissionStateDto microphonePermission;
  late bool recognizerAvailable;
  String? unavailableReason;
}

class VoiceCaptureStartRequestDto {
  late int contractVersion;
  late String operationId;
  late String mediaId;
  late String localeIdentifier;
  late bool addsPunctuation;
}

class VoiceCaptureAckDto {
  late int contractVersion;
  late String operationId;
  late bool accepted;
  late VoiceCaptureStatusCodeDto statusCode;
  String? diagnosticMessage;
}

class VoiceCaptureResultDto {
  late int contractVersion;
  late String operationId;
  late String resultId;
  late String temporaryFilePath;
  late String originDeviceId;
  late int createdAtMicros;
  late int durationMs;
  late int byteLength;
  late String mimeType;
  late String codec;
  late int sampleRateHz;
  late int channelCount;
  String? recognizedText;
}

class VoiceCaptureEventDto {
  late int contractVersion;
  late String operationId;
  late int sequence;
  late VoiceCapturePhaseDto phase;
  late VoiceCaptureStatusCodeDto statusCode;
  String? diagnosticMessage;
  VoiceCaptureResultDto? result;
}

@HostApi()
abstract class VoiceCaptureHostApi {
  @async
  VoiceCaptureCapabilitiesDto getCapabilities(String localeIdentifier);

  @async
  VoiceCaptureAckDto startCapture(VoiceCaptureStartRequestDto request);

  @async
  VoiceCaptureAckDto stopCapture(String operationId);

  @async
  VoiceCaptureAckDto cancelCapture(String operationId);

  @async
  void releaseResult(String resultId);
}

@FlutterApi()
abstract class VoiceCaptureFlutterApi {
  void onCaptureEvent(VoiceCaptureEventDto event);
}
