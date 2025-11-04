import '../../repositories/room_repository.dart';
import '../base/use_case.dart';

/// Output for room occupancy information
class RoomOccupancyReport {
  final int totalRooms;
  final int availableRooms;
  final int occupiedRooms;
  final int outOfServiceRooms;
  final double occupancyPercentage;
  final int totalBeds;
  final int availableBeds;
  final int occupiedBeds;
  final double bedOccupancyPercentage;
  final Map<String, RoomTypeOccupancy> byRoomType;

  RoomOccupancyReport({
    required this.totalRooms,
    required this.availableRooms,
    required this.occupiedRooms,
    required this.outOfServiceRooms,
    required this.occupancyPercentage,
    required this.totalBeds,
    required this.availableBeds,
    required this.occupiedBeds,
    required this.bedOccupancyPercentage,
    required this.byRoomType,
  });

  @override
  String toString() {
    return '''
📊 Room Occupancy Report
━━━━━━━━━━━━━━━━━━━━━━━━
Rooms: $occupiedRooms/$totalRooms occupied (${occupancyPercentage.toStringAsFixed(1)}%)
Beds: $occupiedBeds/$totalBeds occupied (${bedOccupancyPercentage.toStringAsFixed(1)}%)
Available Rooms: $availableRooms
Out of Service: $outOfServiceRooms
''';
  }
}

class RoomTypeOccupancy {
  final String roomType;
  final int total;
  final int available;
  final int occupied;
  final double occupancyPercentage;

  RoomTypeOccupancy({
    required this.roomType,
    required this.total,
    required this.available,
    required this.occupied,
    required this.occupancyPercentage,
  });
}

/// Use case for getting comprehensive room occupancy information
/// Provides detailed statistics for hospital management
class GetRoomOccupancy extends NoInputUseCase<RoomOccupancyReport> {
  final RoomRepository roomRepository;

  GetRoomOccupancy({required this.roomRepository});

  @override
  Future<RoomOccupancyReport> execute() async {
    // Get all rooms
    final allRooms = await roomRepository.getAllRooms();

    // Calculate totals
    final totalRooms = allRooms.length;
    final availableRooms = allRooms
        .where((room) => room.status.toString().contains('AVAILABLE'))
        .length;
    final occupiedRooms = allRooms
        .where((room) => room.status.toString().contains('OCCUPIED'))
        .length;
    final outOfServiceRooms = allRooms.length - availableRooms - occupiedRooms;
    final occupancyPercentage =
        totalRooms > 0 ? (occupiedRooms / totalRooms) * 100.0 : 0.0;

    // Calculate bed statistics
    int totalBeds = 0;
    int availableBeds = 0;
    int occupiedBeds = 0;

    for (final room in allRooms) {
      totalBeds += room.beds.length;
      availableBeds += room.beds.where((bed) => bed.isAvailable).length;
      occupiedBeds += room.beds.where((bed) => !bed.isAvailable).length;
    }

    final bedOccupancyPercentage =
        totalBeds > 0 ? (occupiedBeds / totalBeds) * 100.0 : 0.0;

    // Calculate by room type
    final byRoomType = <String, RoomTypeOccupancy>{};
    final roomsByType = <String, List<dynamic>>{};

    for (final room in allRooms) {
      final typeKey = room.roomType.toString();
      roomsByType.putIfAbsent(typeKey, () => []).add(room);
    }

    for (final entry in roomsByType.entries) {
      final rooms = entry.value;
      final total = rooms.length;
      final available =
          rooms.where((r) => r.status.toString().contains('AVAILABLE')).length;
      final occupied =
          rooms.where((r) => r.status.toString().contains('OCCUPIED')).length;
      final percentage = total > 0 ? (occupied / total) * 100.0 : 0.0;

      byRoomType[entry.key] = RoomTypeOccupancy(
        roomType: entry.key,
        total: total,
        available: available,
        occupied: occupied,
        occupancyPercentage: percentage,
      );
    }

    return RoomOccupancyReport(
      totalRooms: totalRooms,
      availableRooms: availableRooms,
      occupiedRooms: occupiedRooms,
      outOfServiceRooms: outOfServiceRooms,
      occupancyPercentage: occupancyPercentage,
      totalBeds: totalBeds,
      availableBeds: availableBeds,
      occupiedBeds: occupiedBeds,
      bedOccupancyPercentage: bedOccupancyPercentage,
      byRoomType: byRoomType,
    );
  }
}
