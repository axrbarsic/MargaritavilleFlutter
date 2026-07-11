import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/persistence/app_database_provider.dart';
import '../../data/repositories/drift_room_details_repository.dart';
import '../../domain/models/room_details_snapshot.dart';
import '../../domain/repositories/room_details_repository.dart';

typedef RoomDetailsRequest = ({String sessionId, String roomNumber});

final roomDetailsRepositoryProvider = Provider<RoomDetailsRepository>((ref) {
  return DriftRoomDetailsRepository(ref.watch(appDatabaseProvider));
});

final roomDetailsControllerProvider = AsyncNotifierProvider.autoDispose
    .family<RoomDetailsController, RoomDetailsSnapshot, RoomDetailsRequest>(
      RoomDetailsController.new,
    );

final class RoomDetailsController extends AsyncNotifier<RoomDetailsSnapshot> {
  RoomDetailsController(this.request);

  final RoomDetailsRequest request;

  @override
  Future<RoomDetailsSnapshot> build() {
    return ref
        .watch(roomDetailsRepositoryProvider)
        .load(sessionId: request.sessionId, roomNumber: request.roomNumber);
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}
