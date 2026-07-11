import '../catalogs/margaritaville_room_catalog.dart';
import 'housekeeper.dart';
import 'room_state.dart';

final class WorkAssignment {
  WorkAssignment({
    required this.id,
    required this.cartNumber,
    required this.housekeeper,
    required this.assignedAt,
    required this.updatedAt,
    required List<RoomState> rooms,
    String? territoryId,
    this.deletedAt,
  }) : territoryId =
           territoryId ??
           MargaritavilleRoomCatalog.preferredTerritoryId(cartNumber),
       rooms = List.unmodifiable(rooms);

  factory WorkAssignment.create({
    required String id,
    required int cartNumber,
    required Housekeeper housekeeper,
    required DateTime assignedAt,
    String? territoryId,
  }) {
    return WorkAssignment(
      id: id,
      cartNumber: cartNumber,
      housekeeper: housekeeper,
      assignedAt: assignedAt,
      updatedAt: assignedAt,
      territoryId: territoryId,
      rooms: const [],
    );
  }

  final String id;
  final int cartNumber;
  final Housekeeper housekeeper;
  final DateTime assignedAt;
  final DateTime updatedAt;
  final String territoryId;
  final DateTime? deletedAt;
  final List<RoomState> rooms;

  Iterable<RoomState> get activeRooms => rooms.where((room) => !room.isDeleted);

  RoomState? room(String roomNumber) {
    return activeRooms.cast<RoomState?>().firstWhere(
      (room) => room?.roomNumber == roomNumber,
      orElse: () => null,
    );
  }

  WorkAssignment replacingRoom(RoomState room, {required DateTime changedAt}) {
    final index = rooms.indexWhere(
      (candidate) => candidate.roomNumber == room.roomNumber,
    );
    final nextRooms = [...rooms];
    if (index == -1) {
      nextRooms.add(room);
    } else {
      nextRooms[index] = room;
    }
    return copyWith(rooms: nextRooms, updatedAt: changedAt);
  }

  WorkAssignment removingRoomRecord(
    String roomNumber, {
    required DateTime changedAt,
  }) {
    return copyWith(
      rooms: rooms.where((room) => room.roomNumber != roomNumber).toList(),
      updatedAt: changedAt,
    );
  }

  WorkAssignment copyWith({
    Housekeeper? housekeeper,
    DateTime? updatedAt,
    String? territoryId,
    List<RoomState>? rooms,
  }) {
    return WorkAssignment(
      id: id,
      cartNumber: cartNumber,
      housekeeper: housekeeper ?? this.housekeeper,
      assignedAt: assignedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      territoryId: territoryId ?? this.territoryId,
      deletedAt: deletedAt,
      rooms: rooms ?? this.rooms,
    );
  }

  factory WorkAssignment.fromJson(Map<String, Object?> json) {
    return WorkAssignment(
      id: json['id']! as String,
      cartNumber: json['cartNumber']! as int,
      housekeeper: Housekeeper.fromJson(
        json['housekeeper']! as Map<String, Object?>,
      ),
      assignedAt: DateTime.parse(json['assignedAt']! as String),
      updatedAt: DateTime.parse(json['updatedAt']! as String),
      territoryId: json['territoryId'] as String?,
      deletedAt: _dateTime(json['deletedAt']),
      rooms: (json['rooms']! as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(RoomState.fromJson)
          .toList(),
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'cartNumber': cartNumber,
    'housekeeper': housekeeper.toJson(),
    'assignedAt': assignedAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'territoryId': territoryId,
    'deletedAt': deletedAt?.toUtc().toIso8601String(),
    'rooms': rooms.map((room) => room.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkAssignment &&
          id == other.id &&
          cartNumber == other.cartNumber &&
          housekeeper == other.housekeeper &&
          assignedAt == other.assignedAt &&
          updatedAt == other.updatedAt &&
          territoryId == other.territoryId &&
          deletedAt == other.deletedAt &&
          _listEquals(rooms, other.rooms);

  @override
  int get hashCode => Object.hash(
    id,
    cartNumber,
    housekeeper,
    assignedAt,
    updatedAt,
    territoryId,
    deletedAt,
    Object.hashAll(rooms),
  );
}

bool _listEquals<T>(List<T> first, List<T> second) {
  if (first.length != second.length) return false;
  for (var index = 0; index < first.length; index++) {
    if (first[index] != second[index]) return false;
  }
  return true;
}

DateTime? _dateTime(Object? value) {
  return value == null ? null : DateTime.parse(value as String);
}
