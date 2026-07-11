import '../domain/catalogs/housekeeper_catalog_rules.dart';
import '../domain/commands/housekeeper_catalog_command.dart';
import '../domain/models/housekeeper_catalog_mutation.dart';
import '../domain/repositories/housekeeper_catalog_repository.dart';
import 'housekeeper_catalog_command_descriptor.dart';

final class HousekeeperCatalogCommandHandler {
  const HousekeeperCatalogCommandHandler(
    this._repository, {
    HousekeeperCatalogRules rules = const HousekeeperCatalogRules(),
  }) : _rules = rules;

  final HousekeeperCatalogRepository _repository;
  final HousekeeperCatalogRules _rules;

  Future<HousekeeperCatalogMutation> execute(
    HousekeeperCatalogCommand command,
  ) {
    if (command case SetHousekeeperPaletteCommand(
      :final paletteKey,
    ) when !HousekeeperCatalogRules.paletteKeys.contains(paletteKey.trim())) {
      throw ArgumentError.value(paletteKey, 'paletteKey');
    }
    return _repository.commitCommand(
      descriptor: command.toDescriptor(),
      mutate: (snapshot) => _reduce(snapshot, command),
    );
  }

  HousekeeperCatalogMutation _reduce(
    HousekeeperCatalogSnapshot snapshot,
    HousekeeperCatalogCommand command,
  ) {
    return switch (command) {
      AddHousekeeperCommand(:final displayName, :final issuedAt) => _add(
        snapshot,
        displayName,
        issuedAt,
      ),
      RenameHousekeeperCommand(
        :final housekeeperId,
        :final displayName,
        :final issuedAt,
      ) =>
        _rename(snapshot, housekeeperId, displayName, issuedAt),
      SetHousekeeperPaletteCommand(
        :final housekeeperId,
        :final paletteKey,
        :final issuedAt,
      ) =>
        _setPalette(snapshot, housekeeperId, paletteKey, issuedAt),
    };
  }

  HousekeeperCatalogMutation _add(
    HousekeeperCatalogSnapshot snapshot,
    String displayName,
    DateTime issuedAt,
  ) {
    final housekeeper = _rules.makeHousekeeper(
      displayName: displayName,
      existing: snapshot.active,
      reservedIds: snapshot.reservedIds,
      changedAt: issuedAt,
    );
    if (housekeeper == null) return const HousekeeperCatalogMutation.ignored();
    return HousekeeperCatalogMutation.changed(
      housekeeper: housekeeper,
      changedFields: const {
        HousekeeperCatalogChangedField.displayName,
        HousekeeperCatalogChangedField.paletteKey,
      },
      sortOrder: snapshot.nextSortOrder,
    );
  }

  HousekeeperCatalogMutation _rename(
    HousekeeperCatalogSnapshot snapshot,
    String housekeeperId,
    String displayName,
    DateTime issuedAt,
  ) {
    final value = _rules.renameHousekeeper(
      housekeeperId: housekeeperId,
      displayName: displayName,
      existing: snapshot.active,
      changedAt: issuedAt,
    );
    if (value == null) return const HousekeeperCatalogMutation.ignored();
    return HousekeeperCatalogMutation.changed(
      housekeeper: value,
      changedFields: const {HousekeeperCatalogChangedField.displayName},
    );
  }

  HousekeeperCatalogMutation _setPalette(
    HousekeeperCatalogSnapshot snapshot,
    String housekeeperId,
    String paletteKey,
    DateTime issuedAt,
  ) {
    final value = _rules.setPalette(
      housekeeperId: housekeeperId,
      paletteKey: paletteKey,
      existing: snapshot.active,
      changedAt: issuedAt,
    );
    if (value == null) return const HousekeeperCatalogMutation.ignored();
    return HousekeeperCatalogMutation.changed(
      housekeeper: value,
      changedFields: const {HousekeeperCatalogChangedField.paletteKey},
    );
  }
}
