enum HotelWorkflow { simpleCycle }

final class HotelProfile {
  const HotelProfile({
    required this.id,
    required this.name,
    required this.workflow,
  });

  static const margaritaville = HotelProfile(
    id: 'margaritaville',
    name: 'Margaritaville',
    workflow: HotelWorkflow.simpleCycle,
  );

  final String id;
  final String name;
  final HotelWorkflow workflow;

  factory HotelProfile.fromJson(Map<String, Object?> json) {
    return HotelProfile(
      id: json['id']! as String,
      name: json['name']! as String,
      workflow: HotelWorkflow.values.byName(json['workflow']! as String),
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'workflow': workflow.name,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HotelProfile &&
          id == other.id &&
          name == other.name &&
          workflow == other.workflow;

  @override
  int get hashCode => Object.hash(id, name, workflow);
}
