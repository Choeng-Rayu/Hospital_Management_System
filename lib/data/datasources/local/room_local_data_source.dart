import 'json_data_source.dart';
import '../../models/room_model.dart';
import '../interfaces/room_data_source.dart';

/// Local data source for Room entity
/// Provides specialized queries for room data
class RoomLocalDataSource extends JsonDataSource<RoomModel>
    implements RoomDataSource {
  RoomLocalDataSource()
      : super(
          fileName: 'rooms.json',
          fromJson: RoomModel.fromJson,
        );

  /// Find a room by room ID
  Future<RoomModel?> findByRoomId(String roomId) {
    return findById(
      roomId,
      (room) => room.roomId,
      (room) => room.toJson(),
    );
  }

  /// Check if a room exists
  Future<bool> roomExists(String roomId) {
    return exists(roomId, (room) => room.roomId);
  }

  /// Find a room by room number
  Future<RoomModel?> findByRoomNumber(String roomNumber) async {
    final rooms = await findWhere((room) => room.number == roomNumber);
    return rooms.isEmpty ? null : rooms.first;
  }

  /// Find rooms by type
  Future<List<RoomModel>> findRoomsByType(String roomType) {
    return findWhere((room) => room.roomType == roomType);
  }

  /// Find rooms by status
  Future<List<RoomModel>> findRoomsByStatus(String status) {
    return findWhere((room) => room.status == status);
  }

  /// Find available rooms (status = AVAILABLE and has available beds)
  Future<List<RoomModel>> findAvailableRooms() {
    return findWhere((room) {
      // A room is available if it has AVAILABLE status
      return room.status.contains('AVAILABLE');
    });
  }

  /// Find rooms with available beds
  Future<List<RoomModel>> findRoomsWithAvailableBeds() {
    return findWhere((room) => room.bedIds.isNotEmpty);
  }

  /// Find rooms by equipment ID
  Future<List<RoomModel>> findRoomsByEquipmentId(String equipmentId) {
    return findWhere((room) => room.equipmentIds.contains(equipmentId));
  }

  /// Find rooms by bed ID
  Future<List<RoomModel>> findRoomsByBedId(String bedId) {
    return findWhere((room) => room.bedIds.contains(bedId));
  }
}
