import '../../domain/models/housekeeper.dart';

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

final class ToggleRoomSelectionCommand extends WorkSessionCommand {
  const ToggleRoomSelectionCommand({
    required super.commandId,
    required super.issuedAt,
    required this.assignmentId,
    required this.roomNumber,
  });

  final String assignmentId;
  final String roomNumber;
}

final class ToggleHousekeeperWorkItemCommand extends WorkSessionCommand {
  const ToggleHousekeeperWorkItemCommand({
    required super.commandId,
    required super.issuedAt,
    required this.housekeeperId,
    required this.displayName,
    required this.paletteKey,
  });

  final String housekeeperId;
  final String displayName;
  final String paletteKey;
}

final class SetAssignmentTerritoryCommand extends WorkSessionCommand {
  const SetAssignmentTerritoryCommand({
    required super.commandId,
    required super.issuedAt,
    required this.assignmentId,
    required this.territoryId,
  });

  final String assignmentId;
  final String territoryId;
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

final class ReplaceAllRoomAssignmentsCommand extends WorkSessionCommand {
  ReplaceAllRoomAssignmentsCommand({
    required super.commandId,
    required super.issuedAt,
    required this.roomNumbers,
    required List<Housekeeper> housekeepers,
  }) : housekeepers = List.unmodifiable(housekeepers);

  final List<String> roomNumbers;
  final List<Housekeeper> housekeepers;
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

final class SetRoomVipCommand extends WorkSessionCommand {
  const SetRoomVipCommand({
    required super.commandId,
    required super.issuedAt,
    required this.roomNumber,
    required this.isVip,
  });

  final String roomNumber;
  final bool isVip;
}

final class SetRoomScheduleCommand extends WorkSessionCommand {
  const SetRoomScheduleCommand({
    required super.commandId,
    required super.issuedAt,
    required this.roomNumber,
    required this.scheduledFor,
  });

  final String roomNumber;
  final DateTime? scheduledFor;
}

final class AdvanceScheduledRoomsCommand extends WorkSessionCommand {
  const AdvanceScheduledRoomsCommand({
    required super.commandId,
    required super.issuedAt,
  });
}
