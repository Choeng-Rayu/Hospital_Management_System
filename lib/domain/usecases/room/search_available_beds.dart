import '../../entities/bed.dart';
import '../../entities/enums/bed_type.dart';
import '../../repositories/room_repository.dart';
import '../base/use_case.dart';

/// Criteria for searching available beds
class SearchAvailableBedsInput {
  final BedType? bedType;
  final String? roomId;
  final String? roomType;
  final List<String>? requiredFeatures;
  final bool onlyAvailable;

  SearchAvailableBedsInput({
    this.bedType,
    this.roomId,
    this.roomType,
    this.requiredFeatures,
    this.onlyAvailable = true,
  });
}

/// Output for bed search with room context
class BedSearchResult {
  final Bed bed;
  final String roomId;
  final String roomNumber;
  final String roomType;

  BedSearchResult({
    required this.bed,
    required this.roomId,
    required this.roomNumber,
    required this.roomType,
  });

  @override
  String toString() {
    return 'Bed ${bed.bedNumber} in Room $roomNumber ($roomType) - ${bed.isAvailable ? "Available" : "Occupied"}';
  }
}

/// Use case for searching available beds across the hospital
/// Provides detailed bed availability with room context
class SearchAvailableBeds
    extends UseCase<SearchAvailableBedsInput, List<BedSearchResult>> {
  final RoomRepository roomRepository;

  SearchAvailableBeds({required this.roomRepository});

  @override
  Future<List<BedSearchResult>> execute(SearchAvailableBedsInput input) async {
    List<BedSearchResult> results = [];

    final rooms = input.roomId != null
        ? [await roomRepository.getRoomById(input.roomId!)]
        : await roomRepository.getAllRooms();

    for (final room in rooms) {
      if (input.roomType != null &&
          !room.roomType.toString().contains(input.roomType!)) {
        continue;
      }

      for (final bed in room.beds) {
        if (input.onlyAvailable && !bed.isAvailable) {
          continue;
        }

        if (input.bedType != null && bed.bedType != input.bedType) {
          continue;
        }

        if (input.requiredFeatures != null &&
            input.requiredFeatures!.isNotEmpty) {
          final hasAllFeatures = input.requiredFeatures!
              .every((feature) => bed.features.contains(feature));
          if (!hasAllFeatures) {
            continue;
          }
        }

        results.add(BedSearchResult(
          bed: bed,
          roomId: room.roomId,
          roomNumber: room.number,
          roomType: room.roomType.toString(),
        ));
      }
    }

    results.sort((a, b) {
      const typePriority = {
        'BedType.ICU': 0,
        'BedType.ELECTRIC': 1,
        'BedType.STANDARD': 2,
      };

      final aPriority = typePriority[a.bed.bedType.toString()] ?? 999;
      final bPriority = typePriority[b.bed.bedType.toString()] ?? 999;

      return aPriority.compareTo(bPriority);
    });

    return results;
  }
}
