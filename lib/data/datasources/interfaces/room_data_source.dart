import '../../models/room_model.dart';

/// Abstract interface for Room data source operations
abstract class RoomDataSource {
  /// Read all rooms
  Future<List<RoomModel>> readAll();

  /// Add a new room
  Future<void> add(
    RoomModel room,
    String Function(RoomModel) getId,
    Map<String, dynamic> Function(RoomModel) toJson,
  );

  /// Update an existing room
  Future<void> update(
    String id,
    RoomModel room,
    String Function(RoomModel) getId,
    Map<String, dynamic> Function(RoomModel) toJson,
  );

  /// Delete a room
  Future<void> delete(
    String id,
    String Function(RoomModel) getId,
    Map<String, dynamic> Function(RoomModel) toJson,
  );

  /// Find a room by room ID
  Future<RoomModel?> findByRoomId(String roomId);

  /// Check if a room exists
  Future<bool> roomExists(String roomId);

  /// Find a room by room number
  Future<RoomModel?> findByRoomNumber(String roomNumber);

  /// Find rooms by type
  Future<List<RoomModel>> findRoomsByType(String roomType);

  /// Find rooms by status
  Future<List<RoomModel>> findRoomsByStatus(String status);

  /// Find available rooms (status = AVAILABLE and has available beds)
  Future<List<RoomModel>> findAvailableRooms();

  /// Find rooms with available beds
  Future<List<RoomModel>> findRoomsWithAvailableBeds();

  /// Find rooms by equipment ID
  Future<List<RoomModel>> findRoomsByEquipmentId(String equipmentId);

  /// Find rooms by bed ID
  Future<List<RoomModel>> findRoomsByBedId(String bedId);
}
