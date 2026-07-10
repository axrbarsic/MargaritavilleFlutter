import '../domain/models/hotel_profile.dart';
import '../domain/models/housekeeper.dart';
import '../domain/models/work_assignment.dart';
import '../domain/models/work_session.dart';

WorkSession makeInitialWorkSession(DateTime startedAt) {
  final housekeepers = [
    Housekeeper(
      id: 'ketty',
      displayName: 'Ketty',
      paletteKey: 'ruby',
      updatedAt: startedAt,
    ),
    Housekeeper(
      id: 'omelene-pm',
      displayName: 'Omelene PM',
      paletteKey: 'orchid',
      updatedAt: startedAt,
    ),
  ];

  return WorkSession.create(
    id: 'session-${startedAt.microsecondsSinceEpoch}',
    hotel: HotelProfile.margaritaville,
    startedAt: startedAt,
    assignments: [
      for (var index = 0; index < housekeepers.length; index++)
        WorkAssignment.create(
          id: 'work-block-${index + 1}',
          cartNumber: index + 1,
          housekeeper: housekeepers[index],
          assignedAt: startedAt,
        ),
    ],
  );
}
