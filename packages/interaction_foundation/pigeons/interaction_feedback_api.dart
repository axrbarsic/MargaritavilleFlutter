import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut:
        'packages/interaction_foundation/lib/src/generated/interaction_feedback_api.g.dart',
    dartOptions: DartOptions(),
    dartPackageName: 'interaction_foundation',
    swiftOut:
        'packages/interaction_foundation/ios/Classes/InteractionFeedbackApi.g.swift',
    swiftOptions: SwiftOptions(),
    kotlinOut:
        'packages/interaction_foundation/android/src/main/kotlin/com/axr/interaction_foundation/InteractionFeedbackApi.g.kt',
    kotlinOptions: KotlinOptions(package: 'com.axr.interaction_foundation'),
  ),
)
enum NativeFeedbackCue {
  none,
  tap,
  confirm,
  longPress,
  holdStart,
  holdWarning,
  holdCommit,
  select,
  deselect,
  invalid,
  detent,
}

enum NativeInteractionAudioContext {
  interactive,
  voiceCapture,
  voicePlayback,
  background,
}

class NativeSoundRegistration {
  late String id;
  late String packageAssetPath;
  late double volume;
  late double rate;
  late double pan;
}

class NativeFeedbackConfiguration {
  late int contractVersion;
  late int soundCoalescingWindowMs;
  late int playerPoolSize;
  late bool respectSilentMode;
  late bool mixWithOthers;
  late List<NativeSoundRegistration> sounds;
}

class NativeFeedbackRequest {
  late String requestId;
  late NativeFeedbackCue cue;
  String? soundId;
  late int soundPriority;
}

@HostApi()
abstract class NativeInteractionFeedbackHostApi {
  void configure(NativeFeedbackConfiguration configuration);

  void emit(NativeFeedbackRequest request);

  void previewSound(String soundId);

  void setAudioContext(NativeInteractionAudioContext context);

  void clearPending();
}
