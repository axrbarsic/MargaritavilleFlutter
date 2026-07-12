import 'generated/interaction_feedback_api.g.dart';
import 'interaction_feedback_contract.dart';

abstract interface class InteractionFeedbackBridge {
  Future<void> configure(InteractionFeedbackConfiguration configuration);

  Future<void> emit(InteractionFeedbackRequest request);

  Future<void> previewSound(String soundId);

  Future<void> setAudioContext(InteractionAudioContext context);

  Future<void> clearPending();
}

final class PigeonInteractionFeedbackBridge
    implements InteractionFeedbackBridge {
  PigeonInteractionFeedbackBridge({NativeInteractionFeedbackHostApi? api})
    : _api = api ?? NativeInteractionFeedbackHostApi();

  final NativeInteractionFeedbackHostApi _api;

  @override
  Future<void> configure(InteractionFeedbackConfiguration configuration) {
    return _api.configure(
      NativeFeedbackConfiguration(
        contractVersion: configuration.contractVersion,
        soundCoalescingWindowMs:
            configuration.soundCoalescingWindow.inMilliseconds,
        playerPoolSize: configuration.playerPoolSize,
        respectSilentMode: configuration.respectSilentMode,
        mixWithOthers: configuration.mixWithOthers,
        sounds: [
          for (final sound in configuration.sounds)
            NativeSoundRegistration(
              id: sound.id,
              packageAssetPath: sound.packageAssetPath,
              volume: sound.volume,
              rate: sound.rate,
              pan: sound.pan,
            ),
        ],
      ),
    );
  }

  @override
  Future<void> emit(InteractionFeedbackRequest request) {
    return _api.emit(
      NativeFeedbackRequest(
        requestId: request.requestId,
        cue: _nativeCue(request.cue),
        soundId: request.soundId,
        soundPriority: request.soundPriority,
      ),
    );
  }

  @override
  Future<void> previewSound(String soundId) => _api.previewSound(soundId);

  @override
  Future<void> setAudioContext(InteractionAudioContext context) {
    return _api.setAudioContext(_nativeAudioContext(context));
  }

  @override
  Future<void> clearPending() => _api.clearPending();
}

NativeFeedbackCue _nativeCue(InteractionFeedbackCue cue) => switch (cue) {
  InteractionFeedbackCue.none => NativeFeedbackCue.none,
  InteractionFeedbackCue.tap => NativeFeedbackCue.tap,
  InteractionFeedbackCue.confirm => NativeFeedbackCue.confirm,
  InteractionFeedbackCue.longPress => NativeFeedbackCue.longPress,
  InteractionFeedbackCue.holdStart => NativeFeedbackCue.holdStart,
  InteractionFeedbackCue.holdWarning => NativeFeedbackCue.holdWarning,
  InteractionFeedbackCue.holdCommit => NativeFeedbackCue.holdCommit,
  InteractionFeedbackCue.select => NativeFeedbackCue.select,
  InteractionFeedbackCue.deselect => NativeFeedbackCue.deselect,
  InteractionFeedbackCue.invalid => NativeFeedbackCue.invalid,
  InteractionFeedbackCue.detent => NativeFeedbackCue.detent,
};

NativeInteractionAudioContext _nativeAudioContext(
  InteractionAudioContext context,
) => switch (context) {
  InteractionAudioContext.interactive =>
    NativeInteractionAudioContext.interactive,
  InteractionAudioContext.voiceCapture =>
    NativeInteractionAudioContext.voiceCapture,
  InteractionAudioContext.voicePlayback =>
    NativeInteractionAudioContext.voicePlayback,
  InteractionAudioContext.background =>
    NativeInteractionAudioContext.background,
};
