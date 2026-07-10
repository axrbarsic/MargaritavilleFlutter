import 'package:flutter/foundation.dart';

enum InteractionFeedbackCue {
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

enum InteractionAudioContext {
  interactive,
  voiceCapture,
  voicePlayback,
  background,
}

@immutable
final class InteractionSoundRegistration {
  const InteractionSoundRegistration({
    required this.id,
    required this.packageAssetPath,
    this.volume = 0.30,
    this.rate = 1,
    this.pan = 0,
  });

  final String id;
  final String packageAssetPath;
  final double volume;
  final double rate;
  final double pan;
}

@immutable
final class InteractionFeedbackConfiguration {
  const InteractionFeedbackConfiguration({
    required this.sounds,
    this.contractVersion = 1,
    this.soundCoalescingWindow = const Duration(milliseconds: 45),
    this.playerPoolSize = 4,
    this.respectSilentMode = true,
    this.mixWithOthers = true,
  });

  final int contractVersion;
  final Duration soundCoalescingWindow;
  final int playerPoolSize;
  final bool respectSilentMode;
  final bool mixWithOthers;
  final List<InteractionSoundRegistration> sounds;
}

@immutable
final class InteractionFeedbackRequest {
  const InteractionFeedbackRequest({
    required this.requestId,
    required this.cue,
    required this.soundPriority,
    this.soundId,
  });

  final String requestId;
  final InteractionFeedbackCue cue;
  final String? soundId;
  final int soundPriority;
}
