sealed class HousekeeperCatalogCommand {
  const HousekeeperCatalogCommand({
    required this.commandId,
    required this.issuedAt,
  });

  final String commandId;
  final DateTime issuedAt;
  int get version => 1;
}

final class AddHousekeeperCommand extends HousekeeperCatalogCommand {
  const AddHousekeeperCommand({
    required super.commandId,
    required super.issuedAt,
    required this.displayName,
  });

  final String displayName;
}

final class RenameHousekeeperCommand extends HousekeeperCatalogCommand {
  const RenameHousekeeperCommand({
    required super.commandId,
    required super.issuedAt,
    required this.housekeeperId,
    required this.displayName,
  });

  final String housekeeperId;
  final String displayName;
}

final class SetHousekeeperPaletteCommand extends HousekeeperCatalogCommand {
  const SetHousekeeperPaletteCommand({
    required super.commandId,
    required super.issuedAt,
    required this.housekeeperId,
    required this.paletteKey,
  });

  final String housekeeperId;
  final String paletteKey;
}
