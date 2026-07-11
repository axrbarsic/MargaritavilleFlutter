import '../models/housekeeper.dart';
import '../models/housekeeper_catalog_command_descriptor.dart';
import '../models/housekeeper_catalog_mutation.dart';

abstract interface class HousekeeperCatalogRepository {
  Future<void> ensureDefaults(DateTime seededAt);

  Future<List<Housekeeper>> loadActive();

  Stream<List<Housekeeper>> watchActive();

  Future<HousekeeperCatalogMutation> commitCommand({
    required HousekeeperCatalogCommandDescriptor descriptor,
    required HousekeeperCatalogMutation Function(
      HousekeeperCatalogSnapshot snapshot,
    )
    mutate,
  });
}
