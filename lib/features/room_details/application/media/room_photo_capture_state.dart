enum RoomPhotoCapturePhase { idle, saving, saved, failed }

final class RoomPhotoCaptureState {
  const RoomPhotoCaptureState({
    required this.phase,
    required this.statusText,
    this.mediaId,
  });

  const RoomPhotoCaptureState.idle()
    : this(phase: RoomPhotoCapturePhase.idle, statusText: 'Готово к фото');

  final RoomPhotoCapturePhase phase;
  final String statusText;
  final String? mediaId;

  bool get isBusy => phase == RoomPhotoCapturePhase.saving;
}
