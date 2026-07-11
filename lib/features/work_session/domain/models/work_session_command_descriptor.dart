final class WorkSessionCommandDescriptor {
  WorkSessionCommandDescriptor({
    required this.commandId,
    required this.version,
    required this.issuedAt,
    required this.commandType,
    required Map<String, Object?> canonicalPayload,
    required this.eventType,
    required Map<String, Object?> eventPayload,
  }) : canonicalPayload = Map.unmodifiable(canonicalPayload),
       eventPayload = Map.unmodifiable(eventPayload);

  final String commandId;
  final int version;
  final DateTime issuedAt;
  final String commandType;
  final Map<String, Object?> canonicalPayload;
  final String eventType;
  final Map<String, Object?> eventPayload;
}
