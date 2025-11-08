import '../../entities/enums/bed_type.dart';
import '../../repositories/room_repository.dart';
import '../base/use_case.dart';
import 'search_available_beds.dart';

/// Output for ICU bed availability search
class ICUBedAvailability {
  final List<BedSearchResult> availableBeds;
  final int totalICUBeds;
  final int availableICUBeds;
  final int occupiedICUBeds;
  final double occupancyPercentage;
  final bool criticalCapacity; // Less than 20% available

  ICUBedAvailability({
    required this.availableBeds,
    required this.totalICUBeds,
    required this.availableICUBeds,
    required this.occupiedICUBeds,
    required this.occupancyPercentage,
    required this.criticalCapacity,
  });

  @override
  String toString() {
    final status = criticalCapacity ? '🔴 CRITICAL' : '🟢 NORMAL';
    return '''
$status ICU Capacity
━━━━━━━━━━━━━━━━━━━━━
Available: $availableICUBeds/$totalICUBeds beds (${(100 - occupancyPercentage).toStringAsFixed(1)}% free)
Occupied: $occupiedICUBeds beds
Occupancy: ${occupancyPercentage.toStringAsFixed(1)}%
${availableBeds.isEmpty ? '⚠️ NO BEDS AVAILABLE' : '✓ ${availableBeds.length} beds ready'}
''';
  }
}

/// Use case for getting available ICU beds - CRITICAL for emergency operations
/// Provides immediate visibility into critical care capacity
class GetAvailableICUBeds extends NoInputUseCase<ICUBedAvailability> {
  final RoomRepository roomRepository;

  GetAvailableICUBeds({required this.roomRepository});

  @override
  Future<ICUBedAvailability> execute() async {
    final allRooms = await roomRepository.getAllRooms();
    final icuRooms = allRooms
        .where((room) => room.roomType.toString().contains('ICU'))
        .toList();

    int totalICUBeds = 0;
    int availableICUBeds = 0;
    int occupiedICUBeds = 0;
    List<BedSearchResult> availableBeds = [];

    for (final room in icuRooms) {
      for (final bed in room.beds) {
        if (bed.bedType == BedType.ICU_BED) {
          totalICUBeds++;

          if (bed.isAvailable) {
            availableICUBeds++;
            availableBeds.add(BedSearchResult(
              bed: bed,
              roomId: room.roomId,
              roomNumber: room.number,
              roomType: room.roomType.toString(),
            ));
          } else {
            occupiedICUBeds++;
          }
        }
      }
    }

    final occupancyPercentage = totalICUBeds > 0
        ? (occupiedICUBeds / totalICUBeds * 100).toDouble()
        : 0.0;

    final criticalCapacity = occupancyPercentage > 80;

    availableBeds.sort((a, b) {
      final aFeatureCount = a.bed.features.length;
      final bFeatureCount = b.bed.features.length;
      return bFeatureCount.compareTo(aFeatureCount);
    });

    return ICUBedAvailability(
      availableBeds: availableBeds,
      totalICUBeds: totalICUBeds,
      availableICUBeds: availableICUBeds,
      occupiedICUBeds: occupiedICUBeds,
      occupancyPercentage: occupancyPercentage,
      criticalCapacity: criticalCapacity,
    );
  }
}
