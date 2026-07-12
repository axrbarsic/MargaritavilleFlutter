import '../../domain/models/work_session_command_descriptor.dart';
import 'work_session_command.dart';

extension WorkSessionCommandDescriptorAdapter on WorkSessionCommand {
  WorkSessionCommandDescriptor toDescriptor() {
    final type = _commandType(this);
    return WorkSessionCommandDescriptor(
      commandId: commandId,
      version: version,
      issuedAt: issuedAt,
      commandType: type,
      canonicalPayload: {
        'type': type,
        'version': version,
        'issuedAtMicros': issuedAt.microsecondsSinceEpoch,
        'payload': _semanticPayload(this),
      },
      eventType: 'work_session.$type',
      eventPayload: _eventPayload(this),
    );
  }
}

String _commandType(WorkSessionCommand command) => switch (command) {
  ToggleHousekeeperWorkItemCommand() => 'housekeeper_work_item_toggled',
  SetAssignmentTerritoryCommand() => 'assignment_territory_set',
  ToggleRoomSelectionCommand() => 'room_selection_toggled',
  AssignRoomCommand() => 'room_assigned',
  UnassignRoomCommand() => 'room_unassigned',
  ReplaceAllRoomAssignmentsCommand() => 'all_room_assignments_replaced',
  LockWorkdayCommand() => 'workday_locked',
  UnlockWorkdayCommand() => 'workday_unlocked',
  AdvanceRoomCommand() => 'room_advanced',
  ResetRoomCommand() => 'room_reset',
  SetRoomVipCommand() => 'room_vip_set',
  SetRoomScheduleCommand() => 'room_schedule_set',
  AdvanceScheduledRoomsCommand() => 'scheduled_rooms_advanced',
};

Map<String, Object?> _semanticPayload(WorkSessionCommand command) =>
    switch (command) {
      ToggleHousekeeperWorkItemCommand(
        :final housekeeperId,
        :final displayName,
        :final paletteKey,
      ) =>
        {
          'housekeeperId': housekeeperId,
          'displayName': displayName,
          'paletteKey': paletteKey,
        },
      SetAssignmentTerritoryCommand(:final assignmentId, :final territoryId) =>
        {'assignmentId': assignmentId, 'territoryId': territoryId},
      ToggleRoomSelectionCommand(:final assignmentId, :final roomNumber) ||
      AssignRoomCommand(:final assignmentId, :final roomNumber) ||
      UnassignRoomCommand(
        :final assignmentId,
        :final roomNumber,
      ) => {'assignmentId': assignmentId, 'roomNumber': roomNumber},
      ReplaceAllRoomAssignmentsCommand(
        :final roomNumbers,
        :final housekeepers,
        :final testRooms,
      ) =>
        {
          'roomNumbers': roomNumbers,
          'housekeepers': [
            for (final value in housekeepers)
              {
                'id': value.id,
                'displayName': value.displayName,
                'paletteKey': value.paletteKey,
                'updatedAtMicros': value.updatedAt.microsecondsSinceEpoch,
                'deletedAtMicros': value.deletedAt?.microsecondsSinceEpoch,
              },
          ],
          if (testRooms != null)
            'testRooms': [for (final room in testRooms) room.toJson()],
        },
      LockWorkdayCommand() ||
      UnlockWorkdayCommand() ||
      AdvanceScheduledRoomsCommand() => const {},
      AdvanceRoomCommand(:final roomNumber) ||
      ResetRoomCommand(:final roomNumber) => {'roomNumber': roomNumber},
      SetRoomVipCommand(:final roomNumber, :final isVip) => {
        'roomNumber': roomNumber,
        'isVip': isVip,
      },
      SetRoomScheduleCommand(:final roomNumber, :final scheduledFor) => {
        'roomNumber': roomNumber,
        'scheduledForMicros': scheduledFor?.microsecondsSinceEpoch,
      },
    };

Map<String, Object?> _eventPayload(
  WorkSessionCommand command,
) => switch (command) {
  ToggleHousekeeperWorkItemCommand(:final housekeeperId) => {
    'housekeeperId': housekeeperId,
  },
  SetAssignmentTerritoryCommand(:final assignmentId, :final territoryId) => {
    'assignmentId': assignmentId,
    'territoryId': territoryId,
  },
  ToggleRoomSelectionCommand(:final assignmentId, :final roomNumber) ||
  AssignRoomCommand(:final assignmentId, :final roomNumber) ||
  UnassignRoomCommand(
    :final assignmentId,
    :final roomNumber,
  ) => {'assignmentId': assignmentId, 'roomNumber': roomNumber},
  ReplaceAllRoomAssignmentsCommand(:final roomNumbers, :final housekeepers) => {
    'roomCount': roomNumbers.length,
    'housekeeperIds': [for (final value in housekeepers) value.id],
  },
  LockWorkdayCommand() ||
  UnlockWorkdayCommand() ||
  AdvanceScheduledRoomsCommand() => const {},
  AdvanceRoomCommand(:final roomNumber) ||
  ResetRoomCommand(:final roomNumber) => {'roomNumber': roomNumber},
  SetRoomVipCommand(:final roomNumber, :final isVip) => {
    'roomNumber': roomNumber,
    'isVip': isVip,
  },
  SetRoomScheduleCommand(:final roomNumber, :final scheduledFor) => {
    'roomNumber': roomNumber,
    'scheduledForMicros': scheduledFor?.microsecondsSinceEpoch,
  },
};
