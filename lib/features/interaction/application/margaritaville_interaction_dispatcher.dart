import '../../work_session/domain/models/room_state.dart';
import '../domain/margaritaville_interaction_intent.dart';
import '../domain/margaritaville_sound_routing.dart';
import 'margaritaville_feedback_controller.dart';

final class MargaritavilleInteractionDispatcher {
  MargaritavilleInteractionDispatcher(this._feedback);

  final MargaritavilleFeedbackController _feedback;
  final Set<String> _activeAsyncActions = {};

  void accept(
    MargaritavilleInteractionIntent intent,
    void Function() operation, {
    String? eventId,
  }) {
    _feedback.perform(intent, eventId: eventId);
    operation();
  }

  Future<T> acceptAsync<T>(
    MargaritavilleInteractionIntent intent,
    Future<T> Function() operation, {
    String? eventId,
  }) {
    _feedback.perform(intent, eventId: eventId);
    return operation();
  }

  Future<T?> acceptAsyncOnce<T>(
    String actionKey,
    MargaritavilleInteractionIntent intent,
    Future<T> Function() operation, {
    String? eventId,
  }) async {
    if (!_activeAsyncActions.add(actionKey)) return null;
    _feedback.perform(intent, eventId: eventId);
    try {
      return await operation();
    } finally {
      _activeAsyncActions.remove(actionKey);
    }
  }

  void signal(MargaritavilleInteractionIntent intent, {String? eventId}) =>
      _feedback.perform(intent, eventId: eventId);

  void signalHapticOnly(
    MargaritavilleInteractionIntent intent, {
    String? eventId,
  }) => _feedback.performHapticOnly(intent, eventId: eventId);

  void actionMenuOpened() => _feedback.actionMenuOpened();

  void selectionOpenedAfterGestureCommit() => _feedback.selectionOpened();

  void roomStatusChanged(RoomDisplayStatus status) =>
      _feedback.roomStatusChanged(status);

  void previewSound(MargaritavilleSoundAsset asset) =>
      _feedback.previewSound(asset);
}
