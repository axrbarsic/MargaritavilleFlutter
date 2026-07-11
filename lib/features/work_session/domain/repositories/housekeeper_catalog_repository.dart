import '../models/housekeeper.dart';

abstract interface class HousekeeperCatalogRepository {
  Future<void> ensureDefaults(DateTime seededAt);

  Future<List<Housekeeper>> loadActive();

  Stream<List<Housekeeper>> watchActive();

  Future<void> save(Housekeeper housekeeper, {required int sortOrder});

  Future<void> remove(String housekeeperId, {required DateTime changedAt});
}
