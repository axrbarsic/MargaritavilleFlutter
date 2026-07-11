import '../domain/commands/housekeeper_catalog_command.dart';
import '../domain/models/housekeeper_catalog_command_descriptor.dart';

extension HousekeeperCatalogCommandDescriptorAdapter
    on HousekeeperCatalogCommand {
  HousekeeperCatalogCommandDescriptor toDescriptor() {
    final type = switch (this) {
      AddHousekeeperCommand() => 'add',
      RenameHousekeeperCommand() => 'rename',
      SetHousekeeperPaletteCommand() => 'set_palette',
    };
    final payload = switch (this) {
      AddHousekeeperCommand(:final displayName) => {
        'displayName': displayName.trim(),
      },
      RenameHousekeeperCommand(:final housekeeperId, :final displayName) => {
        'housekeeperId': housekeeperId.trim(),
        'displayName': displayName.trim(),
      },
      SetHousekeeperPaletteCommand(:final housekeeperId, :final paletteKey) => {
        'housekeeperId': housekeeperId.trim(),
        'paletteKey': paletteKey.trim(),
      },
    };
    return HousekeeperCatalogCommandDescriptor(
      commandId: commandId,
      version: version,
      issuedAt: issuedAt,
      commandType: 'housekeeper_catalog.$type',
      canonicalPayload: {
        'type': type,
        'version': version,
        'issuedAtMicros': issuedAt.microsecondsSinceEpoch,
        'payload': payload,
      },
      eventType: 'housekeeper_catalog.changed',
    );
  }
}
