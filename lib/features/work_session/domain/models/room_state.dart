import 'room_timestamps.dart';

enum RoomPhase { pending, open, ready }

enum RoomDisplayStatus { pending, open, ready, scheduled }

enum RoomTransitionOutcome { changed, ignored }

final class RoomTransition {
  const RoomTransition({required this.room, required this.outcome});

  final RoomState room;
  final RoomTransitionOutcome outcome;
}

final class RoomState {
  const RoomState({
    required this.roomNumber,
    required this.phase,
    required this.isVip,
    required this.timestamps,
    this.scheduledFor,
    this.deletedAt,
  });

  factory RoomState.pending({
    required String roomNumber,
    required DateTime selectedAt,
  }) {
    return RoomState(
      roomNumber: roomNumber,
      phase: RoomPhase.pending,
      isVip: false,
      timestamps: RoomTimestamps(
        selectedAt: selectedAt,
        phaseUpdatedAt: selectedAt,
      ),
    );
  }

  final String roomNumber;
  final RoomPhase phase;
  final bool isVip;
  final DateTime? scheduledFor;
  final DateTime? deletedAt;
  final RoomTimestamps timestamps;

  bool get isDeleted => deletedAt != null;

  RoomDisplayStatus get displayStatus {
    if (scheduledFor != null) return RoomDisplayStatus.scheduled;
    return RoomDisplayStatus.values.byName(phase.name);
  }

  RoomTransition advanceSimpleCycle({required DateTime changedAt}) {
    if (scheduledFor != null) {
      final nextPhase = phase == RoomPhase.pending ? RoomPhase.open : phase;
      var nextTimestamps = timestamps.changingSchedule(changedAt);
      if (nextPhase != phase) {
        nextTimestamps = nextTimestamps.changingPhase(
          changedAt: changedAt,
          marksOpened: true,
          marksCompleted: false,
        );
      }
      return RoomTransition(
        outcome: RoomTransitionOutcome.changed,
        room: _copy(
          phase: nextPhase,
          scheduledFor: null,
          timestamps: nextTimestamps,
        ),
      );
    }

    return switch (phase) {
      RoomPhase.pending => RoomTransition(
        outcome: RoomTransitionOutcome.changed,
        room: _copy(
          phase: RoomPhase.open,
          timestamps: timestamps.changingPhase(
            changedAt: changedAt,
            marksOpened: true,
            marksCompleted: false,
          ),
        ),
      ),
      RoomPhase.open => RoomTransition(
        outcome: RoomTransitionOutcome.changed,
        room: _copy(
          phase: RoomPhase.ready,
          timestamps: timestamps.changingPhase(
            changedAt: changedAt,
            marksOpened: false,
            marksCompleted: true,
          ),
        ),
      ),
      RoomPhase.ready => RoomTransition(
        outcome: RoomTransitionOutcome.ignored,
        room: this,
      ),
    };
  }

  RoomTransition resetSimpleCycle({required DateTime changedAt}) {
    if (phase == RoomPhase.pending && scheduledFor == null) {
      return RoomTransition(room: this, outcome: RoomTransitionOutcome.ignored);
    }
    var nextTimestamps = timestamps.changingPhase(
      changedAt: changedAt,
      marksOpened: false,
      marksCompleted: false,
    );
    if (scheduledFor != null) {
      nextTimestamps = nextTimestamps.changingSchedule(changedAt);
    }
    return RoomTransition(
      outcome: RoomTransitionOutcome.changed,
      room: _copy(
        phase: RoomPhase.pending,
        scheduledFor: null,
        timestamps: nextTimestamps,
      ),
    );
  }

  RoomState schedule({
    required DateTime? scheduledFor,
    required DateTime changedAt,
  }) {
    if (this.scheduledFor == scheduledFor) return this;
    return _copy(
      scheduledFor: scheduledFor,
      timestamps: timestamps.changingSchedule(changedAt),
    );
  }

  RoomTransition advanceScheduledIfDue({required DateTime now}) {
    final dueAt = scheduledFor;
    if (dueAt == null || dueAt.isAfter(now)) {
      return RoomTransition(room: this, outcome: RoomTransitionOutcome.ignored);
    }
    final nextPhase = phase == RoomPhase.pending ? RoomPhase.open : phase;
    var nextTimestamps = timestamps.changingSchedule(now);
    if (nextPhase != phase) {
      nextTimestamps = nextTimestamps.changingPhase(
        changedAt: now,
        marksOpened: true,
        marksCompleted: false,
      );
    }
    return RoomTransition(
      outcome: RoomTransitionOutcome.changed,
      room: _copy(
        phase: nextPhase,
        scheduledFor: null,
        timestamps: nextTimestamps,
      ),
    );
  }

  RoomState setVip({required bool isVip, required DateTime changedAt}) {
    if (this.isVip == isVip) return this;
    return _copy(isVip: isVip, timestamps: timestamps.changingVip(changedAt));
  }

  RoomState tombstone({required DateTime changedAt}) {
    return _copy(deletedAt: changedAt);
  }

  RoomState _copy({
    RoomPhase? phase,
    bool? isVip,
    Object? scheduledFor = _unchanged,
    Object? deletedAt = _unchanged,
    RoomTimestamps? timestamps,
  }) {
    return RoomState(
      roomNumber: roomNumber,
      phase: phase ?? this.phase,
      isVip: isVip ?? this.isVip,
      scheduledFor: scheduledFor == _unchanged
          ? this.scheduledFor
          : scheduledFor as DateTime?,
      deletedAt: deletedAt == _unchanged
          ? this.deletedAt
          : deletedAt as DateTime?,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  factory RoomState.fromJson(Map<String, Object?> json) {
    return RoomState(
      roomNumber: json['roomNumber']! as String,
      phase: RoomPhase.values.byName(json['phase']! as String),
      isVip: json['isVip']! as bool,
      scheduledFor: _dateTime(json['scheduledFor']),
      deletedAt: _dateTime(json['deletedAt']),
      timestamps: RoomTimestamps.fromJson(
        json['timestamps']! as Map<String, Object?>,
      ),
    );
  }

  Map<String, Object?> toJson() => {
    'roomNumber': roomNumber,
    'phase': phase.name,
    'isVip': isVip,
    'scheduledFor': scheduledFor?.toUtc().toIso8601String(),
    'deletedAt': deletedAt?.toUtc().toIso8601String(),
    'timestamps': timestamps.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomState &&
          roomNumber == other.roomNumber &&
          phase == other.phase &&
          isVip == other.isVip &&
          scheduledFor == other.scheduledFor &&
          deletedAt == other.deletedAt &&
          timestamps == other.timestamps;

  @override
  int get hashCode => Object.hash(
    roomNumber,
    phase,
    isVip,
    scheduledFor,
    deletedAt,
    timestamps,
  );
}

const _unchanged = Object();

DateTime? _dateTime(Object? value) {
  return value == null ? null : DateTime.parse(value as String);
}
