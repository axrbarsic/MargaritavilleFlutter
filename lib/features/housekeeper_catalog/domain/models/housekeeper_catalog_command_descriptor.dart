final class HousekeeperCatalogCommandDescriptor {
  HousekeeperCatalogCommandDescriptor({
    required this.commandId,
    required this.version,
    required this.issuedAt,
    required this.commandType,
    required Map<String, Object?> canonicalPayload,
    required this.eventType,
  }) : canonicalPayload = Map.unmodifiable(canonicalPayload);

  final String commandId;
  final int version;
  final DateTime issuedAt;
  final String commandType;
  final Map<String, Object?> canonicalPayload;
  final String eventType;
}
