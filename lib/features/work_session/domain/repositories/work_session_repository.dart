import '../models/work_session.dart';

abstract interface class WorkSessionRepository {
  Future<WorkSession?> loadSession(String sessionId);

  Future<WorkSession?> loadLatestSession();

  Future<void> replaceSession(WorkSession session);

  Stream<WorkSession?> watchLatestSession();
}
