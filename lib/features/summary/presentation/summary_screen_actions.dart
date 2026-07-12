part of 'summary_screen.dart';

extension _SummaryScreenActions on _SummaryScreenState {
  void _advanceRoom(RoomState room) {
    unawaited(_advanceRoomAndPulse(room));
  }

  Future<void> _advanceRoomAndPulse(RoomState room) async {
    final result = await ref
        .read(workSessionControllerProvider.notifier)
        .advanceRoom(room.roomNumber);
    if (result == WorkSessionMutationStatus.changed) {
      _recordStatusFeedbackAndPulse(room.roomNumber);
    }
  }

  void _resetRoom(RoomState room) {
    unawaited(_resetRoomAndPulse(room));
  }

  Future<void> _resetRoomAndPulse(RoomState room) async {
    final result = await ref
        .read(workSessionControllerProvider.notifier)
        .resetRoom(room.roomNumber);
    if (result == WorkSessionMutationStatus.changed) {
      _recordStatusFeedbackAndPulse(room.roomNumber);
    }
  }

  void _toggleVip(RoomState room) {
    unawaited(_toggleVipAndPulse(room));
  }

  Future<void> _toggleVipAndPulse(RoomState room) async {
    final result = await ref
        .read(workSessionControllerProvider.notifier)
        .setRoomVip(room.roomNumber, isVip: !room.isVip);
    if (result == WorkSessionMutationStatus.changed) {
      _recordCurrentPulse(room.roomNumber);
    }
  }

  void _openSchedule(RoomState room) {
    unawaited(_openScheduleOccluded(room));
  }

  Future<void> _openScheduleOccluded(RoomState room) async {
    try {
      await _withEdrOccluded(
        () => showRoomScheduleSheet(
          context: context,
          room: room,
          now: ref.read(clockProvider).now(),
          onSet: (date) => unawaited(
            _setRoomScheduleAndPulse(room.roomNumber, scheduledFor: date),
          ),
          onClear: () => unawaited(
            _setRoomScheduleAndPulse(room.roomNumber, scheduledFor: null),
          ),
        ),
      );
    } on StateError catch (error) {
      debugPrint(
        'Расписание не открыто: native EDR не подтвердил окклюзию: $error',
      );
    }
  }

  Future<void> _setRoomScheduleAndPulse(
    String roomNumber, {
    required DateTime? scheduledFor,
  }) async {
    final feedback = MargaritavilleFeedbackScope.dispatcherOf(context);
    if (scheduledFor == null) {
      feedback.signal(MargaritavilleInteractionIntent.deselect);
    } else {
      feedback.signal(MargaritavilleInteractionIntent.confirm);
    }
    final result = await ref
        .read(workSessionControllerProvider.notifier)
        .setRoomSchedule(roomNumber, scheduledFor: scheduledFor);
    if (result == WorkSessionMutationStatus.changed) {
      _recordStatusFeedbackAndPulse(roomNumber);
    }
  }

  void _advanceScheduledRooms() {
    unawaited(_advanceScheduledRoomsAndPulse());
  }

  Future<void> _advanceScheduledRoomsAndPulse() async {
    if (!mounted) return;
    final state = ref.read(workSessionControllerProvider);
    if (!state.hasValue || state.requireValue.id != widget.session.id) return;
    final now = ref.read(clockProvider).now();
    final dueRoomNumbers = state.requireValue.activeRooms
        .where((room) {
          final dueAt = room.scheduledFor;
          return dueAt != null && !dueAt.isAfter(now);
        })
        .map((room) => room.roomNumber)
        .toList(growable: false);
    final result = await ref
        .read(workSessionControllerProvider.notifier)
        .advanceScheduledRooms();
    if (result != WorkSessionMutationStatus.changed) return;
    for (final roomNumber in dueRoomNumbers) {
      _recordStatusFeedbackAndPulse(roomNumber);
    }
  }

  void _recordStatusFeedbackAndPulse(String roomNumber) {
    if (!mounted) return;
    final state = ref.read(workSessionControllerProvider);
    if (!state.hasValue || state.requireValue.id != widget.session.id) return;
    final room = state.requireValue.room(roomNumber);
    if (room == null) return;
    MargaritavilleFeedbackScope.dispatcherOf(
      context,
    ).roomStatusChanged(room.displayStatus);
    _recordCurrentPulse(roomNumber);
  }

  void _recordCurrentPulse(String roomNumber) {
    if (!mounted || !widget.visualPolicy.transientPulseEnabled) return;
    final state = ref.read(workSessionControllerProvider);
    if (!state.hasValue || state.requireValue.id != widget.session.id) return;
    final room = state.requireValue.room(roomNumber);
    if (room == null) return;
    _visualPulses.record(
      roomNumber: roomNumber,
      status: room.displayStatus,
      startedAt: _latestVisualTimestamp(room),
    );
  }

  DateTime _latestVisualTimestamp(RoomState room) {
    final values = <DateTime>[
      room.timestamps.phaseUpdatedAt,
      if (room.timestamps.vipUpdatedAt != null) room.timestamps.vipUpdatedAt!,
      if (room.timestamps.scheduledUpdatedAt != null)
        room.timestamps.scheduledUpdatedAt!,
    ];
    values.sort();
    return values.last;
  }

  void _unlockWorkday() {
    unawaited(ref.read(workSessionControllerProvider.notifier).unlockWorkday());
  }

  void _showSettingsNotice(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Настройки — следующий parity-блок. Выбор комнат открывается пазлом справа налево.',
          ),
          duration: Duration(seconds: 2),
        ),
      );
  }

  void _openMedia(RoomState room) {
    unawaited(_openMediaOccluded(room));
  }

  Future<void> _openMediaOccluded(RoomState room) async {
    try {
      await _withEdrOccluded(
        () => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => RoomDetailsScreen(
              sessionId: widget.session.id,
              roomNumber: room.roomNumber,
            ),
          ),
        ),
      );
    } on StateError catch (error) {
      debugPrint('Медиа не открыты: native EDR не подтвердил окклюзию: $error');
    }
  }

  Future<T> _withEdrOccluded<T>(Future<T> Function() action) async {
    final occlusion = await _edrWindow.acquirePresentationOcclusion();
    try {
      return await action();
    } finally {
      occlusion.release();
    }
  }
}
