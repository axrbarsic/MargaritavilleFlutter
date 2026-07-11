enum ContentOwnerKind { room, assignment }

/// Stable identity for content that belongs either to one room or one work
/// assignment. The two ownership modes are mutually exclusive by design.
final class ContentOwnerRef {
  const ContentOwnerRef._({
    required this.kind,
    required this.roomNumber,
    required this.assignmentId,
  });

  factory ContentOwnerRef.room(String roomNumber) => ContentOwnerRef._(
    kind: ContentOwnerKind.room,
    roomNumber: _normalized(roomNumber, 'roomNumber'),
    assignmentId: null,
  );

  factory ContentOwnerRef.assignment(String assignmentId) => ContentOwnerRef._(
    kind: ContentOwnerKind.assignment,
    roomNumber: null,
    assignmentId: _normalized(assignmentId, 'assignmentId'),
  );

  factory ContentOwnerRef.fromNullable({
    String? roomNumber,
    String? assignmentId,
  }) {
    final normalizedRoom = roomNumber?.trim();
    final normalizedAssignment = assignmentId?.trim();
    final hasRoom = normalizedRoom?.isNotEmpty ?? false;
    final hasAssignment = normalizedAssignment?.isNotEmpty ?? false;
    if (hasRoom == hasAssignment) {
      throw ArgumentError(
        'Content must have exactly one non-empty room or assignment owner.',
      );
    }
    return hasRoom
        ? ContentOwnerRef.room(normalizedRoom!)
        : ContentOwnerRef.assignment(normalizedAssignment!);
  }

  final ContentOwnerKind kind;
  final String? roomNumber;
  final String? assignmentId;

  Map<String, String> get eventPayload => switch (kind) {
    ContentOwnerKind.room => {'roomNumber': roomNumber!},
    ContentOwnerKind.assignment => {'assignmentId': assignmentId!},
  };

  String get stableKey => switch (kind) {
    ContentOwnerKind.room => 'room:$roomNumber',
    ContentOwnerKind.assignment => 'assignment:$assignmentId',
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentOwnerRef &&
          kind == other.kind &&
          roomNumber == other.roomNumber &&
          assignmentId == other.assignmentId;

  @override
  int get hashCode => Object.hash(kind, roomNumber, assignmentId);

  @override
  String toString() => 'ContentOwnerRef($stableKey)';
}

String _normalized(String value, String fieldName) {
  final normalized = value.trim();
  if (normalized.isEmpty) {
    throw ArgumentError.value(value, fieldName, 'must not be blank');
  }
  return normalized;
}
