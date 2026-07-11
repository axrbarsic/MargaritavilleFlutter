import '../models/room_media_item.dart';

abstract interface class RoomMediaGarbageRepository {
  Future<List<RoomMediaItem>> tombstonedMedia();
}
