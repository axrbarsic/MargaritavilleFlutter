import 'housekeeper.dart';

enum HousekeeperCatalogMutationStatus { changed, ignored }

enum HousekeeperCatalogChangedField { displayName, paletteKey }

final class HousekeeperCatalogSnapshot {
  const HousekeeperCatalogSnapshot({
    required this.active,
    required this.reservedIds,
    required this.nextSortOrder,
  });

  final List<Housekeeper> active;
  final Set<String> reservedIds;
  final int nextSortOrder;
}

final class HousekeeperCatalogMutation {
  const HousekeeperCatalogMutation._({
    required this.status,
    this.housekeeper,
    this.changedFields = const {},
    this.sortOrder,
  });

  const HousekeeperCatalogMutation.ignored()
    : this._(status: HousekeeperCatalogMutationStatus.ignored);

  HousekeeperCatalogMutation.changed({
    required Housekeeper housekeeper,
    required Set<HousekeeperCatalogChangedField> changedFields,
    int? sortOrder,
  }) : this._(
         status: HousekeeperCatalogMutationStatus.changed,
         housekeeper: housekeeper,
         changedFields: Set.unmodifiable(changedFields),
         sortOrder: sortOrder,
       );

  final HousekeeperCatalogMutationStatus status;
  final Housekeeper? housekeeper;
  final Set<HousekeeperCatalogChangedField> changedFields;
  final int? sortOrder;
}
