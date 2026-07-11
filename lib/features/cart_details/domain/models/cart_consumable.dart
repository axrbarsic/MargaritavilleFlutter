final class CartConsumable {
  const CartConsumable({
    required this.id,
    required this.title,
    required this.quantity,
    this.updatedAt,
    this.completedAt,
  });

  final String id;
  final String title;
  final int quantity;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  bool get isCompleted => completedAt != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartConsumable &&
          id == other.id &&
          title == other.title &&
          quantity == other.quantity &&
          updatedAt == other.updatedAt &&
          completedAt == other.completedAt;

  @override
  int get hashCode => Object.hash(id, title, quantity, updatedAt, completedAt);
}
