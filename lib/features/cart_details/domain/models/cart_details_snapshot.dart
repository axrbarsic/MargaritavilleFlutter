import 'cart_consumable.dart';

final class CartDetailsSnapshot {
  const CartDetailsSnapshot({
    required this.sessionId,
    required this.assignmentId,
    required this.note,
    required this.noteUpdatedAt,
    required this.consumables,
  });

  final String sessionId;
  final String assignmentId;
  final String? note;
  final DateTime? noteUpdatedAt;
  final List<CartConsumable> consumables;
}
