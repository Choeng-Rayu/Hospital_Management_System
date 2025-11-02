import '../../entities/room.dart';
import '../../entities/enums/room_type.dart';
import '../../entities/enums/room_status.dart';
import '../../repositories/room_repository.dart';
import '../base/use_case.dart';

/// Criteria for searching available rooms
class SearchAvailableRoomsInput {
  final RoomType? type;
  final RoomStatus? status;
  final bool? requiresAvailableBeds;
  final int? minimumBeds;
  final List<String>? requiredEquipmentIds;
  final int? minimumCapacity;

  SearchAvailableRoomsInput({
    this.type,
    this.status,
    this.requiresAvailableBeds = true,
    this.minimumBeds,
    this.requiredEquipmentIds,
    this.minimumCapacity,
  });
}

/// Use case for searching available rooms based on various criteria
/// Provides flexible room search with multiple filters
class SearchAvailableRooms
    extends UseCase<SearchAvailableRoomsInput, List<Room>> {
  final RoomRepository roomRepository;

  SearchAvailableRooms({required this.roomRepository});

  @override
  Future<List<Room>> execute(SearchAvailableRoomsInput input) async {
    List<Room> rooms;

    // Start with base query
    if (input.type != null && input.status != null) {
      // Get by both type and status
      final roomsByType = await roomRepository.getRoomsByType(input.type!);
      rooms = roomsByType.where((room) => room.status == input.status).toList();
    } else if (input.type != null) {
      // Get by type only
      rooms = await roomRepository.getRoomsByType(input.type!);
    } else if (input.status != null) {
      // Get by status only
      rooms = await roomRepository.getRoomsByStatus(input.status!);
    } else {
      // Get all available rooms
      rooms = await roomRepository.getAvailableRooms();
    }

    // Apply additional filters
    List<Room> filteredRooms = rooms;

    // Filter by available beds requirement
    if (input.requiresAvailableBeds == true) {
      filteredRooms =
          filteredRooms.where((room) => room.hasAvailableBeds).toList();
    }

    // Filter by minimum beds
    if (input.minimumBeds != null) {
      filteredRooms = filteredRooms
          .where((room) => room.beds.length >= input.minimumBeds!)
          .toList();
    }

    // Filter by minimum available capacity
    if (input.minimumCapacity != null) {
      filteredRooms = filteredRooms.where((room) {
        final availableBeds = room.beds.where((bed) => bed.isAvailable).length;
        return availableBeds >= input.minimumCapacity!;
      }).toList();
    }

    // Filter by required equipment
    if (input.requiredEquipmentIds != null &&
        input.requiredEquipmentIds!.isNotEmpty) {
      filteredRooms = filteredRooms.where((room) {
        final roomEquipmentIds =
            room.equipment.map((e) => e.equipmentId).toSet();
        return input.requiredEquipmentIds!
            .every((reqId) => roomEquipmentIds.contains(reqId));
      }).toList();
    }

    // Sort by available capacity (descending)
    filteredRooms.sort((a, b) {
      final aAvailable = a.beds.where((bed) => bed.isAvailable).length;
      final bAvailable = b.beds.where((bed) => bed.isAvailable).length;
      return bAvailable.compareTo(aAvailable);
    });

    return filteredRooms;
  }
}
