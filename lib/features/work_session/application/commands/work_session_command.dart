sealed class WorkSessionCommand {
  const WorkSessionCommand({
    required this.commandId,
    required this.issuedAt,
    this.version = 1,
  });

  final String commandId;
  final DateTime issuedAt;
  final int version;
}

final class AssignRoomCommand extends WorkSessionCommand {
  const AssignRoomCommand({
    required super.commandId,
    required super.issuedAt,
    required this.assignmentId,
    required this.roomNumber,
  });

  final String assignmentId;
  final String roomNumber;
}

final class UnassignRoomCommand extends WorkSessionCommand {
  const UnassignRoomCommand({
    required super.commandId,
    required super.issuedAt,
    required this.assignmentId,
    required this.roomNumber,
  });

  final String assignmentId;
  final String roomNumber;
}

final class LockWorkdayCommand extends WorkSessionCommand {
  const LockWorkdayCommand({required super.commandId, required super.issuedAt});
}

final class UnlockWorkdayCommand extends WorkSessionCommand {
  const UnlockWorkdayCommand({
    required super.commandId,
    required super.issuedAt,
  });
}

final class AdvanceRoomCommand extends WorkSessionCommand {
  const AdvanceRoomCommand({
    required super.commandId,
    required super.issuedAt,
    required this.roomNumber,
  });

  final String roomNumber;
}

final class ResetRoomCommand extends WorkSessionCommand {
  const ResetRoomCommand({
    required super.commandId,
    required super.issuedAt,
    required this.roomNumber,
  });

  final String roomNumber;
}
