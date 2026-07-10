final class RoomTimestamps {
  const RoomTimestamps({
    required this.selectedAt,
    required this.phaseUpdatedAt,
    this.openedAt,
    this.completedAt,
    this.vipUpdatedAt,
    this.scheduledUpdatedAt,
  });

  final DateTime selectedAt;
  final DateTime phaseUpdatedAt;
  final DateTime? openedAt;
  final DateTime? completedAt;
  final DateTime? vipUpdatedAt;
  final DateTime? scheduledUpdatedAt;

  RoomTimestamps changingPhase({
    required DateTime changedAt,
    required bool marksOpened,
    required bool marksCompleted,
  }) {
    return RoomTimestamps(
      selectedAt: selectedAt,
      phaseUpdatedAt: changedAt,
      openedAt: marksOpened ? openedAt ?? changedAt : openedAt,
      completedAt: marksCompleted ? completedAt ?? changedAt : completedAt,
      vipUpdatedAt: vipUpdatedAt,
      scheduledUpdatedAt: scheduledUpdatedAt,
    );
  }

  RoomTimestamps changingVip(DateTime changedAt) => RoomTimestamps(
    selectedAt: selectedAt,
    phaseUpdatedAt: phaseUpdatedAt,
    openedAt: openedAt,
    completedAt: completedAt,
    vipUpdatedAt: changedAt,
    scheduledUpdatedAt: scheduledUpdatedAt,
  );

  RoomTimestamps changingSchedule(DateTime changedAt) => RoomTimestamps(
    selectedAt: selectedAt,
    phaseUpdatedAt: phaseUpdatedAt,
    openedAt: openedAt,
    completedAt: completedAt,
    vipUpdatedAt: vipUpdatedAt,
    scheduledUpdatedAt: changedAt,
  );

  factory RoomTimestamps.fromJson(Map<String, Object?> json) {
    return RoomTimestamps(
      selectedAt: DateTime.parse(json['selectedAt']! as String),
      phaseUpdatedAt: DateTime.parse(json['phaseUpdatedAt']! as String),
      openedAt: _dateTime(json['openedAt']),
      completedAt: _dateTime(json['completedAt']),
      vipUpdatedAt: _dateTime(json['vipUpdatedAt']),
      scheduledUpdatedAt: _dateTime(json['scheduledUpdatedAt']),
    );
  }

  Map<String, Object?> toJson() => {
    'selectedAt': selectedAt.toUtc().toIso8601String(),
    'phaseUpdatedAt': phaseUpdatedAt.toUtc().toIso8601String(),
    'openedAt': openedAt?.toUtc().toIso8601String(),
    'completedAt': completedAt?.toUtc().toIso8601String(),
    'vipUpdatedAt': vipUpdatedAt?.toUtc().toIso8601String(),
    'scheduledUpdatedAt': scheduledUpdatedAt?.toUtc().toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomTimestamps &&
          selectedAt == other.selectedAt &&
          phaseUpdatedAt == other.phaseUpdatedAt &&
          openedAt == other.openedAt &&
          completedAt == other.completedAt &&
          vipUpdatedAt == other.vipUpdatedAt &&
          scheduledUpdatedAt == other.scheduledUpdatedAt;

  @override
  int get hashCode => Object.hash(
    selectedAt,
    phaseUpdatedAt,
    openedAt,
    completedAt,
    vipUpdatedAt,
    scheduledUpdatedAt,
  );
}

DateTime? _dateTime(Object? value) {
  return value == null ? null : DateTime.parse(value as String);
}
