import '../domain/models/hotel_profile.dart';
import '../domain/models/work_session.dart';

WorkSession makeInitialWorkSession(DateTime startedAt) {
  return WorkSession.create(
    id: 'session-${startedAt.microsecondsSinceEpoch}',
    hotel: HotelProfile.margaritaville,
    startedAt: startedAt,
    assignments: const [],
  );
}
