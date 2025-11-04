import 'package:hospital_management/domain/entities/room.dart';
import 'package:hospital_management/domain/entities/bed.dart';

abstract class RoomDataSource {
  Future<Room> getRoomById(String roomId);
  Future<List<Room>> getAllRooms();
  Future<void> saveRoom(Room room);
  Future<void> updateRoom(Room room);
  Future<void> deleteRoom(String roomId);
  Future<bool> roomExists(String roomId);
}

/// Local implementation of RoomDataSource that stores data in memory
class LocalRoomDataSource implements RoomDataSource {
  final Map<String, Room> _rooms = {};

  @override
  Future<Room> getRoomById(String roomId) async {
    final room = _rooms[roomId];
    if (room == null) {
      throw Exception('Room not found');
    }
    return room;
  }

  @override
  Future<List<Room>> getAllRooms() async {
    return _rooms.values.toList();
  }

  @override
  Future<void> saveRoom(Room room) async {
    if (_rooms.containsKey(room.number)) {
      throw Exception('Room already exists');
    }
    _rooms[room.number] = room;
  }

  @override
  Future<void> updateRoom(Room room) async {
    if (!_rooms.containsKey(room.number)) {
      throw Exception('Room not found');
    }
    _rooms[room.number] = room;
  }

  @override
  Future<void> deleteRoom(String roomId) async {
    if (!_rooms.containsKey(roomId)) {
      throw Exception('Room not found');
    }
    _rooms.remove(roomId);
  }

  @override
  Future<bool> roomExists(String roomId) async {
    return _rooms.containsKey(roomId);
  }
}

abstract class BedDataSource {
  Future<Bed> getBedById(String bedId);
  Future<List<Bed>> getAllBeds();
  Future<void> saveBed(Bed bed);
  Future<void> updateBed(Bed bed);
  Future<void> deleteBed(String bedId);
  Future<bool> bedExists(String bedId);
}

/// Local implementation of BedDataSource that stores data in memory
class LocalBedDataSource implements BedDataSource {
  final Map<String, Bed> _beds = {};

  @override
  Future<Bed> getBedById(String bedId) async {
    final bed = _beds[bedId];
    if (bed == null) {
      throw Exception('Bed not found');
    }
    return bed;
  }

  @override
  Future<List<Bed>> getAllBeds() async {
    return _beds.values.toList();
  }

  @override
  Future<void> saveBed(Bed bed) async {
    if (_beds.containsKey(bed.bedNumber)) {
      throw Exception('Bed already exists');
    }
    _beds[bed.bedNumber] = bed;
  }

  @override
  Future<void> updateBed(Bed bed) async {
    if (!_beds.containsKey(bed.bedNumber)) {
      throw Exception('Bed not found');
    }
    _beds[bed.bedNumber] = bed;
  }

  @override
  Future<void> deleteBed(String bedId) async {
    if (!_beds.containsKey(bedId)) {
      throw Exception('Bed not found');
    }
    _beds.remove(bedId);
  }

  @override
  Future<bool> bedExists(String bedId) async {
    return _beds.containsKey(bedId);
  }
}
