part of 'drift_room_details_repository.dart';

final class DriftRoomMediaGarbageRepository
    implements RoomMediaGarbageRepository {
  const DriftRoomMediaGarbageRepository(this._database);

  final AppDatabase _database;

  @override
  Future<List<RoomMediaItem>> tombstonedMedia() async {
    final query = _database.select(_database.mediaManifestRecords)
      ..where((row) => row.deletedAt.isNotNull())
      ..orderBy([(row) => OrderingTerm.asc(row.deletedAt)]);
    return (await query.get()).map(_mapMedia).toList(growable: false);
  }
}
