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
        cue: NativeFeedbackCue.values[request.cue.index],
        soundId: request.soundId,
        soundPriority: request.soundPriority,
      ),
    );
  }

  @override
  Future<void> previewSound(String soundId) => _api.previewSound(soundId);

  @override
  Future<void> setAudioContext(InteractionAudioContext context) {
    return _api.setAudioContext(
      NativeInteractionAudioContext.values[context.index],
    );
  }

  @override
  Future<void> clearPending() => _api.clearPending();
}
