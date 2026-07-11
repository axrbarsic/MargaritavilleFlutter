import '../models/cart_consumable.dart';

final class CartConsumableCatalogEntry {
  const CartConsumableCatalogEntry({required this.id, required this.title});

  final String id;
  final String title;
}

abstract final class CartConsumableCatalog {
  static const entries = <CartConsumableCatalogEntry>[
    CartConsumableCatalogEntry(id: 'bath_towel', title: 'Полотенца банные'),
    CartConsumableCatalogEntry(id: 'hand_towel', title: 'Полотенца ручные'),
    CartConsumableCatalogEntry(id: 'washcloth', title: 'Салфетки'),
    CartConsumableCatalogEntry(id: 'bath_mat', title: 'Коврики'),
    CartConsumableCatalogEntry(id: 'sheet', title: 'Простыни'),
    CartConsumableCatalogEntry(id: 'pillowcase', title: 'Наволочки'),
  ];

  static List<CartConsumable> merge(Iterable<CartConsumable> stored) {
    final byId = {for (final item in stored) item.id: item};
    return [
      for (final entry in entries)
        CartConsumable(
          id: entry.id,
          title: entry.title,
          quantity: byId[entry.id]?.quantity ?? 0,
          updatedAt: byId[entry.id]?.updatedAt,
          completedAt: byId[entry.id]?.completedAt,
        ),
    ];
  }
}
