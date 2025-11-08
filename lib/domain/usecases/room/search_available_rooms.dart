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
      final roomsByType = await roomRepository.getRoomsByType(input.type!);
      rooms = roomsByType.where((room) => room.status == input.status).toList();
    } else if (input.type != null) {
      rooms = await roomRepository.getRoomsByType(input.type!);
    } else if (input.status != null) {
      rooms = await roomRepository.getRoomsByStatus(input.status!);
    } else {
      rooms = await roomRepository.getAvailableRooms();
    }

    List<Room> filteredRooms = rooms;

    if (input.requiresAvailableBeds == true) {
      filteredRooms =
          filteredRooms.where((room) => room.hasAvailableBeds).toList();
    }

    if (input.minimumBeds != null) {
      filteredRooms = filteredRooms
          .where((room) => room.beds.length >= input.minimumBeds!)
          .toList();
    }

    if (input.minimumCapacity != null) {
      filteredRooms = filteredRooms.where((room) {
        final availableBeds = room.beds.where((bed) => bed.isAvailable).length;
        return availableBeds >= input.minimumCapacity!;
      }).toList();
    }

    if (input.requiredEquipmentIds != null &&
        input.requiredEquipmentIds!.isNotEmpty) {
      filteredRooms = filteredRooms.where((room) {
        final roomEquipmentIds =
            room.equipment.map((e) => e.equipmentId).toSet();
        return input.requiredEquipmentIds!
            .every((reqId) => roomEquipmentIds.contains(reqId));
      }).toList();
    }

    filteredRooms.sort((a, b) {
      final aAvailable = a.beds.where((bed) => bed.isAvailable).length;
      final bAvailable = b.beds.where((bed) => bed.isAvailable).length;
      return bAvailable.compareTo(aAvailable);
    });

    return filteredRooms;
  }
}
