import '../../application/commands/room_details_command.dart';
import '../models/room_details_snapshot.dart';

enum RoomDetailsCommitStatus { applied, duplicate, ignored }

abstract interface class RoomDetailsRepository {
  Future<RoomDetailsSnapshot> load({
    required String sessionId,
    required String roomNumber,
  });

  Future<RoomDetailsCommitStatus> commit(RoomDetailsCommand command);
}
