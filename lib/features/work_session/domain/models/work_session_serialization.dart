part of 'work_session.dart';

abstract final class _WorkSessionSerialization {
  static WorkSession decode(Map<String, Object?> json) {
    final schemaVersion = json['schemaVersion']! as int;
    if (schemaVersion != 2) {
      throw FormatException('Unsupported work-session schema: $schemaVersion');
    }
    return WorkSession._(
      schemaVersion: schemaVersion,
      id: json['id']! as String,
      hotel: HotelProfile.fromJson(json['hotel']! as Map<String, Object?>),
      startedAt: DateTime.parse(json['startedAt']! as String),
      updatedAt: DateTime.parse(json['updatedAt']! as String),
      workdayLocked: json['workdayLocked']! as bool,
      lockUpdatedAt: _dateTime(json['lockUpdatedAt']),
      assignments: (json['assignments']! as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(WorkAssignment.fromJson)
          .toList(),
    );
  }

  static Map<String, Object?> encode(WorkSession session) => {
    'schemaVersion': session.schemaVersion,
    'id': session.id,
    'hotel': session.hotel.toJson(),
    'startedAt': session.startedAt.toUtc().toIso8601String(),
    'updatedAt': session.updatedAt.toUtc().toIso8601String(),
    'workdayLocked': session.workdayLocked,
    'lockUpdatedAt': session.lockUpdatedAt?.toUtc().toIso8601String(),
    'assignments': session.assignments.map((value) => value.toJson()).toList(),
  };

  static DateTime? _dateTime(Object? value) {
    return value == null ? null : DateTime.parse(value as String);
  }
}
