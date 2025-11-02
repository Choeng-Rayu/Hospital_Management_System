import '../../repositories/room_repository.dart';
import '../../entities/room.dart';
import '../../entities/enums/equipment_status.dart';
import '../base/use_case.dart';

/// Input for room search
class SearchRoomsInput {
  final String? roomType;
  final bool? isAvailable;
  final bool? hasEmergencyEquipment;
  final int? minCapacity;
  final int? limit;

  SearchRoomsInput({
    this.roomType,
    this.isAvailable,
    this.hasEmergencyEquipment,
    this.minCapacity,
    this.limit = 100,
  });

  bool get hasAnyFilter =>
      roomType != null ||
      isAvailable != null ||
      hasEmergencyEquipment != null ||
      minCapacity != null;
}

/// Room search result
class RoomSearchResult {
  final List<Room> rooms;
  final int totalFound;
  final String query;

  RoomSearchResult({
    required this.rooms,
    required this.totalFound,
    required this.query,
  });

  @override
  String toString() =>
      '🔍 Found $totalFound rooms | Query: $query\n${rooms.take(10).map((r) => '${r.number} (${r.roomType}) - Beds: ${r.beds.length}').join('\n')}';
}

class SearchRooms extends UseCase<SearchRoomsInput, RoomSearchResult> {
  final RoomRepository roomRepository;

  SearchRooms({required this.roomRepository});

  @override
  Future<bool> validate(SearchRoomsInput input) async {
    if (!input.hasAnyFilter) {
      throw UseCaseValidationException(
          'At least one search criterion required');
    }

    if (input.minCapacity != null && input.minCapacity! < 0) {
      throw UseCaseValidationException('Minimum capacity cannot be negative');
    }
    return true;
  }

  @override
  Future<RoomSearchResult> execute(SearchRoomsInput input) async {
    List<Room> results = await roomRepository.getAllRooms();

    if (input.roomType != null) {
      results = results
          .where((r) => r.roomType
              .toString()
              .split('.')
              .last
              .toLowerCase()
              .contains(input.roomType!.toLowerCase()))
          .toList();
    }

    if (input.isAvailable != null) {
      results = results
          .where((r) => r.hasAvailableBeds == input.isAvailable!)
          .toList();
    }

    if (input.hasEmergencyEquipment != null && input.hasEmergencyEquipment!) {
      results = results
          .where((r) =>
              r.equipment.any((e) => e.status == EquipmentStatus.OPERATIONAL))
          .toList();
    }

    if (input.minCapacity != null) {
      results =
          results.where((r) => r.beds.length >= input.minCapacity!).toList();
    }

    final totalFound = results.length;
    if (input.limit != null) {
      results = results.take(input.limit!).toList();
    }

    final queryParts = <String>[];
    if (input.roomType != null) queryParts.add('type:"${input.roomType}"');
    if (input.isAvailable != null)
      queryParts.add('available:${input.isAvailable}');
    if (input.hasEmergencyEquipment != null)
      queryParts.add('equipment:${input.hasEmergencyEquipment}');
    if (input.minCapacity != null)
      queryParts.add('capacity≥${input.minCapacity}');

    return RoomSearchResult(
      rooms: results,
      totalFound: totalFound,
      query: queryParts.join(' AND '),
    );
  }

  @override
  Future<void> onSuccess(
      RoomSearchResult result, SearchRoomsInput input) async {
    print('✅ Found ${result.totalFound} rooms');
  }

  @override
  Future<void> onError(Exception error, SearchRoomsInput input) async {
    print('❌ Room search failed: $error');
  }
}
