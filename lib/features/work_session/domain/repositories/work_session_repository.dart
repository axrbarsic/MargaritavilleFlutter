import '../models/work_session.dart';
import '../models/work_session_command_descriptor.dart';

abstract interface class WorkSessionRepository {
  Future<WorkSession?> loadSession(String sessionId);

  Future<WorkSession?> loadLatestSession();

  Future<void> replaceSession(WorkSession session);

  Future<WorkSessionMutation> commitCommand({
    required WorkSession fallbackSession,
    required WorkSessionCommandDescriptor descriptor,
    required WorkSessionMutation Function(WorkSession session) mutate,
  });

  Stream<WorkSession?> watchLatestSession();
}
