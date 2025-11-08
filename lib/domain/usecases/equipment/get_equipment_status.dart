import '../../entities/equipment.dart';
import '../../entities/enums/equipment_status.dart';
import '../../repositories/room_repository.dart';
import '../base/use_case.dart';

/// Input for getting equipment status
class GetEquipmentStatusInput {
  final String? equipmentId;
  final String? roomId;
  final String?
      statusFilter; // 'AVAILABLE', 'IN_USE', 'MAINTENANCE', 'OUT_OF_SERVICE'
  final bool includeMaintenanceHistory;

  GetEquipmentStatusInput({
    this.equipmentId,
    this.roomId,
    this.statusFilter,
    this.includeMaintenanceHistory = false,
  });
}

/// Equipment status information
class EquipmentStatusInfo {
  final Equipment equipment;
  final String roomNumber;
  final String roomId;
  final int daysSinceLastMaintenance;
  final int daysUntilNextMaintenance;
  final bool maintenanceOverdue;
  final String healthScore; // 'EXCELLENT', 'GOOD', 'FAIR', 'POOR'

  EquipmentStatusInfo({
    required this.equipment,
    required this.roomNumber,
    required this.roomId,
    required this.daysSinceLastMaintenance,
    required this.daysUntilNextMaintenance,
    required this.maintenanceOverdue,
    required this.healthScore,
  });

  @override
  String toString() {
    final statusEmoji = equipment.status == EquipmentStatus.OPERATIONAL
        ? '✅'
        : equipment.status == EquipmentStatus.IN_MAINTENANCE
            ? '🔧'
            : '❌';
    return '''
$statusEmoji ${equipment.name} (ID: ${equipment.equipmentId})
Location: Room $roomNumber
Status: ${equipment.status}
Health: $healthScore
Last Maintenance: $daysSinceLastMaintenance days ago
Next Maintenance: ${maintenanceOverdue ? '⚠️ OVERDUE' : 'in $daysUntilNextMaintenance days'}
''';
  }
}

/// Result containing multiple equipment statuses
class EquipmentStatusResult {
  final List<EquipmentStatusInfo> equipmentList;
  final int totalCount;
  final int availableCount;
  final int maintenanceCount;
  final int outOfServiceCount;

  EquipmentStatusResult({
    required this.equipmentList,
    required this.totalCount,
    required this.availableCount,
    required this.maintenanceCount,
    required this.outOfServiceCount,
  });

  @override
  String toString() {
    return '''
📊 Equipment Status Summary
━━━━━━━━━━━━━━━━━━━━━━━━
Total: $totalCount
Available: $availableCount (${(availableCount / totalCount * 100).toStringAsFixed(1)}%)
Maintenance: $maintenanceCount
Out of Service: $outOfServiceCount

${equipmentList.map((e) => e.toString()).join('\n')}
''';
  }
}

/// Use case for getting comprehensive equipment status information
/// Useful for equipment management and maintenance planning
class GetEquipmentStatus
    extends UseCase<GetEquipmentStatusInput, EquipmentStatusResult> {
  final RoomRepository roomRepository;

  GetEquipmentStatus({required this.roomRepository});

  @override
  Future<EquipmentStatusResult> execute(GetEquipmentStatusInput input) async {
    final now = DateTime.now();
    final equipmentStatusList = <EquipmentStatusInfo>[];

    final rooms = input.roomId != null
        ? [await roomRepository.getRoomById(input.roomId!)]
        : await roomRepository.getAllRooms();

    int availableCount = 0;
    int maintenanceCount = 0;
    int outOfServiceCount = 0;

    for (final room in rooms) {
      for (final equipment in room.equipment) {
        if (input.equipmentId != null &&
            equipment.equipmentId != input.equipmentId) {
          continue;
        }

        if (input.statusFilter != null &&
            equipment.status.toString().split('.').last !=
                input.statusFilter!) {
          continue;
        }

        final daysSinceLastMaintenance =
            now.difference(equipment.lastServiceDate).inDays;
        final daysUntilNextMaintenance =
            equipment.nextServiceDate.difference(now).inDays;
        final maintenanceOverdue = daysUntilNextMaintenance < 0;

        final healthScore = _calculateHealthScore(
          equipment,
          daysSinceLastMaintenance,
          maintenanceOverdue,
        );

        if (equipment.status == EquipmentStatus.OPERATIONAL) {
          availableCount++;
        } else if (equipment.status == EquipmentStatus.IN_MAINTENANCE) {
          maintenanceCount++;
        } else if (equipment.status == EquipmentStatus.OUT_OF_SERVICE) {
          outOfServiceCount++;
        }

        equipmentStatusList.add(EquipmentStatusInfo(
          equipment: equipment,
          roomNumber: room.number,
          roomId: room.roomId,
          daysSinceLastMaintenance: daysSinceLastMaintenance,
          daysUntilNextMaintenance: daysUntilNextMaintenance,
          maintenanceOverdue: maintenanceOverdue,
          healthScore: healthScore,
        ));
      }
    }

    return EquipmentStatusResult(
      equipmentList: equipmentStatusList,
      totalCount: equipmentStatusList.length,
      availableCount: availableCount,
      maintenanceCount: maintenanceCount,
      outOfServiceCount: outOfServiceCount,
    );
  }

  String _calculateHealthScore(
    Equipment equipment,
    int daysSinceLastMaintenance,
    bool maintenanceOverdue,
  ) {
    // If out of service, health is poor
    if (equipment.status == EquipmentStatus.OUT_OF_SERVICE) {
      return 'POOR';
    }

    // If maintenance overdue, health is degraded
    if (maintenanceOverdue) {
      return 'FAIR';
    }

    // If recently maintained (< 30 days), excellent
    if (daysSinceLastMaintenance < 30) {
      return 'EXCELLENT';
    }

    // If well maintained (30-60 days), good
    if (daysSinceLastMaintenance < 60) {
      return 'GOOD';
    }

    // Otherwise fair
    return 'FAIR';
  }
}
