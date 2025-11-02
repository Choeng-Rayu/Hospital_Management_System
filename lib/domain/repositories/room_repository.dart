import '../entities/room.dart';
import '../entities/enums/room_type.dart';
import '../entities/enums/room_status.dart';
import '../entities/patient.dart';
import '../entities/bed.dart';

/// Repository interface for Room entity
/// Defines all data operations needed for room management
abstract class RoomRepository {
  /// Retrieve a room by its ID
  Future<Room> getRoomById(String roomId);

  /// Retrieve all rooms in the system
  Future<List<Room>> getAllRooms();

  /// Save a new room to the system
  Future<void> saveRoom(Room room);

  /// Update an existing room's information
  Future<void> updateRoom(Room room);

  /// Delete a room from the system
  Future<void> deleteRoom(String roomId);

  /// Get rooms by type (ICU, General Ward, etc.)
  Future<List<Room>> getRoomsByType(RoomType type);

  /// Get rooms by status (Available, Occupied, etc.)
  Future<List<Room>> getRoomsByStatus(RoomStatus status);

  /// Get available rooms with available beds
  Future<List<Room>> getAvailableRooms();

  /// Get room by room number
  Future<Room> getRoomByNumber(String number);

  /// Get all patients in a specific room
  Future<List<Patient>> getRoomPatients(String roomId);

  /// Get all beds in a specific room
  Future<List<Bed>> getRoomBeds(String roomId);

  /// Check if a room exists
  Future<bool> roomExists(String roomId);
}
