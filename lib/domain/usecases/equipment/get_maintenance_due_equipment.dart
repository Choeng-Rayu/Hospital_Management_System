import '../../entities/equipment.dart';
import '../../repositories/room_repository.dart';
import '../base/use_case.dart';

/// Input for getting maintenance due equipment
class GetMaintenanceDueEquipmentInput {
  final int daysThreshold; // Get equipment due within this many days
  final bool includeOverdue;

  GetMaintenanceDueEquipmentInput({
    this.daysThreshold = 30,
    this.includeOverdue = true,
  });
}

/// Equipment maintenance due information
class MaintenanceDueInfo {
  final Equipment equipment;
  final String roomNumber;
  final String roomId;
  final DateTime nextMaintenanceDate;
  final int daysUntilMaintenance; // Negative if overdue
  final bool isOverdue;
  final String priority; // 'URGENT', 'HIGH', 'MEDIUM', 'LOW'

  MaintenanceDueInfo({
    required this.equipment,
    required this.roomNumber,
    required this.roomId,
    required this.nextMaintenanceDate,
    required this.daysUntilMaintenance,
    required this.isOverdue,
    required this.priority,
  });

  @override
  String toString() {
    final urgencyEmoji = isOverdue
        ? '🔴'
        : daysUntilMaintenance <= 7
            ? '🟡'
            : '🟢';
    return '''
$urgencyEmoji ${equipment.name} (ID: ${equipment.equipmentId})
Location: Room $roomNumber
${isOverdue ? '⚠️ OVERDUE by ${-daysUntilMaintenance} days' : 'Due in: $daysUntilMaintenance days'}
Next Maintenance: ${nextMaintenanceDate.toString().split(' ')[0]}
Priority: $priority
''';
  }
}

/// Result for maintenance due equipment
class MaintenanceDueResult {
  final List<MaintenanceDueInfo> overdueEquipment;
  final List<MaintenanceDueInfo> upcomingMaintenance;
  final int totalOverdue;
  final int totalUpcoming;

  MaintenanceDueResult({
    required this.overdueEquipment,
    required this.upcomingMaintenance,
    required this.totalOverdue,
    required this.totalUpcoming,
  });

  @override
  String toString() {
    return '''
🔧 MAINTENANCE DUE REPORT
━━━━━━━━━━━━━━━━━━━━━━━━
Overdue: $totalOverdue items
Upcoming: $totalUpcoming items

${totalOverdue > 0 ? '🔴 OVERDUE:\n${overdueEquipment.map((e) => e.toString()).join('\n')}' : ''}

${totalUpcoming > 0 ? '📅 UPCOMING:\n${upcomingMaintenance.map((e) => e.toString()).join('\n')}' : ''}
''';
  }
}

/// Use case for getting equipment that requires maintenance
/// Critical for preventive maintenance planning
class GetMaintenanceDueEquipment
    extends UseCase<GetMaintenanceDueEquipmentInput, MaintenanceDueResult> {
  final RoomRepository roomRepository;

  GetMaintenanceDueEquipment({required this.roomRepository});

  @override
  Future<bool> validate(GetMaintenanceDueEquipmentInput input) async {
    if (input.daysThreshold < 0 || input.daysThreshold > 365) {
      throw UseCaseValidationException(
        'Days threshold must be between 0 and 365',
      );
    }
    return true;
  }

  @override
  Future<MaintenanceDueResult> execute(
      GetMaintenanceDueEquipmentInput input) async {
    final now = DateTime.now();
    final thresholdDate = now.add(Duration(days: input.daysThreshold));

    final overdueList = <MaintenanceDueInfo>[];
    final upcomingList = <MaintenanceDueInfo>[];

    final allRooms = await roomRepository.getAllRooms();

    for (final room in allRooms) {
      for (final equipment in room.equipment) {
        final daysUntilMaintenance =
            equipment.nextServiceDate.difference(now).inDays;
        final isOverdue = daysUntilMaintenance < 0;

        // Skip if not including overdue and item is overdue
        if (!input.includeOverdue && isOverdue) {
          continue;
        }

        // Skip if maintenance is too far in future
        if (equipment.nextServiceDate.isAfter(thresholdDate)) {
          continue;
        }

        final priority = _calculatePriority(daysUntilMaintenance, equipment);

        final maintenanceInfo = MaintenanceDueInfo(
          equipment: equipment,
          roomNumber: room.number,
          roomId: room.roomId,
          nextMaintenanceDate: equipment.nextServiceDate,
          daysUntilMaintenance: daysUntilMaintenance,
          isOverdue: isOverdue,
          priority: priority,
        );

        if (isOverdue) {
          overdueList.add(maintenanceInfo);
        } else {
          upcomingList.add(maintenanceInfo);
        }
      }
    }

    overdueList.sort(
        (a, b) => a.daysUntilMaintenance.compareTo(b.daysUntilMaintenance));

    upcomingList.sort(
        (a, b) => a.daysUntilMaintenance.compareTo(b.daysUntilMaintenance));

    return MaintenanceDueResult(
      overdueEquipment: overdueList,
      upcomingMaintenance: upcomingList,
      totalOverdue: overdueList.length,
      totalUpcoming: upcomingList.length,
    );
  }

  String _calculatePriority(int daysUntilMaintenance, Equipment equipment) {
    final isCritical = equipment.type.toLowerCase().contains('ventilator') ||
        equipment.type.toLowerCase().contains('monitor') ||
        equipment.type.toLowerCase().contains('defibrillator');

    if (daysUntilMaintenance < -30) {
      return 'URGENT'; // More than 30 days overdue
    } else if (daysUntilMaintenance < 0) {
      return isCritical ? 'URGENT' : 'HIGH'; // Overdue
    } else if (daysUntilMaintenance <= 7) {
      return isCritical ? 'HIGH' : 'MEDIUM'; // Due within a week
    } else {
      return 'LOW'; // Due but not urgent
    }
  }

  @override
  Future<void> onSuccess(MaintenanceDueResult result,
      GetMaintenanceDueEquipmentInput input) async {
    if (result.totalOverdue > 0) {
      print(
          '⚠️ WARNING: ${result.totalOverdue} equipment items overdue for maintenance');
    }
    if (result.totalUpcoming > 0) {
      print(
          '📅 ${result.totalUpcoming} equipment items due for maintenance within ${input.daysThreshold} days');
    }
  }
}
