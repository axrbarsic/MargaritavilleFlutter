final class Housekeeper {
  const Housekeeper({
    required this.id,
    required this.displayName,
    required this.paletteKey,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String displayName;
  final String paletteKey;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  factory Housekeeper.fromJson(Map<String, Object?> json) {
    return Housekeeper(
      id: json['id']! as String,
      displayName: json['displayName']! as String,
      paletteKey: json['paletteKey']! as String,
      updatedAt: DateTime.parse(json['updatedAt']! as String),
      deletedAt: _dateTime(json['deletedAt']),
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'displayName': displayName,
    'paletteKey': paletteKey,
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'deletedAt': deletedAt?.toUtc().toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Housekeeper &&
          id == other.id &&
          displayName == other.displayName &&
          paletteKey == other.paletteKey &&
          updatedAt == other.updatedAt &&
          deletedAt == other.deletedAt;

  @override
  int get hashCode =>
      Object.hash(id, displayName, paletteKey, updatedAt, deletedAt);
}

DateTime? _dateTime(Object? value) {
  return value == null ? null : DateTime.parse(value as String);
}
