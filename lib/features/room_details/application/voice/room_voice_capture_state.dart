enum RoomVoiceCapturePhase {
  idle,
  requestingPermission,
  starting,
  recording,
  finishing,
  saved,
  failed,
  unsupported,
}

final class RoomVoiceCaptureState {
  const RoomVoiceCaptureState({
    required this.phase,
    required this.statusText,
    this.operationId,
    this.mediaId,
    this.canRetrySave = false,
  });

  const RoomVoiceCaptureState.idle()
    : this(phase: RoomVoiceCapturePhase.idle, statusText: 'Готово к записи');

  final RoomVoiceCapturePhase phase;
  final String statusText;
  final String? operationId;
  final String? mediaId;
  final bool canRetrySave;

  bool get acceptsTap => switch (phase) {
    RoomVoiceCapturePhase.idle ||
    RoomVoiceCapturePhase.recording ||
    RoomVoiceCapturePhase.saved => true,
    RoomVoiceCapturePhase.failed => canRetrySave,
    _ => false,
  };

  bool get isRecording => phase == RoomVoiceCapturePhase.recording;
}
