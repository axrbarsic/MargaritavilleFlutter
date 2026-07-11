import '../models/housekeeper.dart';

final class HousekeeperCatalogEntry {
  const HousekeeperCatalogEntry({
    required this.id,
    required this.displayName,
    required this.paletteKey,
  });

  final String id;
  final String displayName;
  final String paletteKey;

  Housekeeper housekeeper(DateTime updatedAt) => Housekeeper(
    id: id,
    displayName: displayName,
    paletteKey: paletteKey,
    updatedAt: updatedAt,
  );
}

abstract final class MargaritavilleHousekeeperCatalog {
  static const entries = <HousekeeperCatalogEntry>[
    HousekeeperCatalogEntry(
      id: 'kerlange',
      displayName: 'Kerlange',
      paletteKey: 'slate',
    ),
    HousekeeperCatalogEntry(
      id: 'anazline',
      displayName: 'Ana',
      paletteKey: 'aqua',
    ),
    HousekeeperCatalogEntry(
      id: 'bebitha',
      displayName: 'Bebita',
      paletteKey: 'amber',
    ),
    HousekeeperCatalogEntry(
      id: 'denise',
      displayName: 'Denise',
      paletteKey: 'coral',
    ),
    HousekeeperCatalogEntry(
      id: 'fabiola',
      displayName: 'Fabiola',
      paletteKey: 'orchid',
    ),
    HousekeeperCatalogEntry(
      id: 'francia',
      displayName: 'Francia',
      paletteKey: 'sky',
    ),
    HousekeeperCatalogEntry(
      id: 'gurline',
      displayName: 'Gurlene',
      paletteKey: 'mint',
    ),
    HousekeeperCatalogEntry(
      id: 'ketty',
      displayName: 'Ketty',
      paletteKey: 'ruby',
    ),
    HousekeeperCatalogEntry(
      id: 'luisa',
      displayName: 'Luisa',
      paletteKey: 'violet',
    ),
    HousekeeperCatalogEntry(
      id: 'marie',
      displayName: 'Marie',
      paletteKey: 'lime',
    ),
    HousekeeperCatalogEntry(
      id: 'marie-pierre',
      displayName: 'Marie Pierre',
      paletteKey: 'slate',
    ),
    HousekeeperCatalogEntry(
      id: 'nadia',
      displayName: 'Nadia',
      paletteKey: 'aqua',
    ),
    HousekeeperCatalogEntry(
      id: 'nadia-m-dc',
      displayName: 'Nadia M (DC)',
      paletteKey: 'amber',
    ),
    HousekeeperCatalogEntry(
      id: 'nidia',
      displayName: 'Nidia',
      paletteKey: 'coral',
    ),
    HousekeeperCatalogEntry(
      id: 'omelene-pm',
      displayName: 'Omelene PM',
      paletteKey: 'orchid',
    ),
    HousekeeperCatalogEntry(
      id: 'ritza',
      displayName: 'Ritza',
      paletteKey: 'sky',
    ),
    HousekeeperCatalogEntry(
      id: 'rosalie',
      displayName: 'Rosaire',
      paletteKey: 'mint',
    ),
    HousekeeperCatalogEntry(
      id: 'simone',
      displayName: 'Simone',
      paletteKey: 'ruby',
    ),
    HousekeeperCatalogEntry(
      id: 'vida',
      displayName: 'Vida',
      paletteKey: 'violet',
    ),
    HousekeeperCatalogEntry(
      id: 'wonderline',
      displayName: 'Wonderline',
      paletteKey: 'lime',
    ),
  ];

  static List<Housekeeper> housekeepers(DateTime updatedAt) => [
    for (final entry in entries) entry.housekeeper(updatedAt),
  ];
}
