import '../../entities/enums/equipment_status.dart';
import '../../repositories/room_repository.dart';
import '../base/use_case.dart';

/// Input for scheduling equipment maintenance
class ScheduleEquipmentMaintenanceInput {
  final String equipmentId;
  final DateTime maintenanceDate;
  final String
      maintenanceType; // 'ROUTINE', 'REPAIR', 'INSPECTION', 'CALIBRATION'
  final String? technician;
  final String? notes;
  final int estimatedDurationMinutes;

  ScheduleEquipmentMaintenanceInput({
    required this.equipmentId,
    required this.maintenanceDate,
    required this.maintenanceType,
    this.technician,
    this.notes,
    this.estimatedDurationMinutes = 60,
  });
}

/// Result of maintenance scheduling
class MaintenanceScheduleResult {
  final String equipmentId;
  final String equipmentName;
  final DateTime scheduledDate;
  final DateTime expectedCompletion;
  final String maintenanceType;
  final String confirmationNumber;
  final String? roomAffected;

  MaintenanceScheduleResult({
    required this.equipmentId,
    required this.equipmentName,
    required this.scheduledDate,
    required this.expectedCompletion,
    required this.maintenanceType,
    required this.confirmationNumber,
    this.roomAffected,
  });

  @override
  String toString() {
    return '''
🔧 Maintenance Scheduled: $confirmationNumber
Equipment: $equipmentName
Type: $maintenanceType
Date: ${scheduledDate.toString().split(' ')[0]}
Duration: ${expectedCompletion.difference(scheduledDate).inMinutes} minutes
${roomAffected != null ? 'Room: $roomAffected' : ''}
''';
  }
}

/// Use case for scheduling equipment maintenance
/// Ensures equipment is properly maintained and tracked
class ScheduleEquipmentMaintenance extends UseCase<
    ScheduleEquipmentMaintenanceInput, MaintenanceScheduleResult> {
  final RoomRepository roomRepository;

  ScheduleEquipmentMaintenance({required this.roomRepository});

  @override
  Future<bool> validate(ScheduleEquipmentMaintenanceInput input) async {
    final validTypes = ['ROUTINE', 'REPAIR', 'INSPECTION', 'CALIBRATION'];
    if (!validTypes.contains(input.maintenanceType)) {
      throw UseCaseValidationException(
        'Invalid maintenance type. Must be one of: ${validTypes.join(", ")}',
      );
    }

    // Validate maintenance date is not in the past (allow same day)
    final today = DateTime.now();
    if (input.maintenanceDate
        .isBefore(today.subtract(const Duration(hours: 1)))) {
      throw UseCaseValidationException(
        'Maintenance date cannot be in the past',
      );
    }

    // Validate duration is reasonable (10 min - 8 hours)
    if (input.estimatedDurationMinutes < 10 ||
        input.estimatedDurationMinutes > 480) {
      throw UseCaseValidationException(
        'Estimated duration must be between 10 minutes and 8 hours',
      );
    }
    return true;
  }

  @override
  Future<MaintenanceScheduleResult> execute(
      ScheduleEquipmentMaintenanceInput input) async {
    // Find the equipment in rooms
    final allRooms = await roomRepository.getAllRooms();
    String? equipmentName;
    String? roomAffected;

    for (final room in allRooms) {
      final equipment = room.equipment.firstWhere(
        (eq) => eq.equipmentId == input.equipmentId,
        orElse: () => throw EntityNotFoundException(
          'Equipment',
          input.equipmentId,
        ),
      );

      if (equipment.equipmentId == input.equipmentId) {
        equipmentName = equipment.name;
        roomAffected = room.number;

        // Update equipment status to IN_MAINTENANCE
        equipment.updateStatus(EquipmentStatus.IN_MAINTENANCE);

        // Update room (equipment is already modified in-place)
        await roomRepository.updateRoom(room);
        break;
      }
    }

    if (equipmentName == null) {
      throw EntityNotFoundException(
        'Equipment',
        input.equipmentId,
      );
    }

    // Calculate expected completion time
    final expectedCompletion = input.maintenanceDate
        .add(Duration(minutes: input.estimatedDurationMinutes));

    // Generate confirmation number
    final confirmationNumber =
        'MNT-${input.maintenanceType.substring(0, 3)}-${DateTime.now().millisecondsSinceEpoch % 10000}';

    return MaintenanceScheduleResult(
      equipmentId: input.equipmentId,
      equipmentName: equipmentName,
      scheduledDate: input.maintenanceDate,
      expectedCompletion: expectedCompletion,
      maintenanceType: input.maintenanceType,
      confirmationNumber: confirmationNumber,
      roomAffected: roomAffected,
    );
  }

  @override
  Future<void> onSuccess(MaintenanceScheduleResult result,
      ScheduleEquipmentMaintenanceInput input) async {
    print('🔧 Maintenance scheduled: ${result.confirmationNumber}');
    if (result.roomAffected != null) {
      print('   Room ${result.roomAffected} will be affected');
    }
  }
}
