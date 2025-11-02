import '../../entities/equipment.dart';
import '../../entities/enums/equipment_status.dart';
import '../../repositories/room_repository.dart';
import '../base/use_case.dart';

/// Input for assigning equipment to room
class AssignEquipmentToRoomInput {
  final String equipmentId;
  final String roomId;
  final DateTime assignmentDate;
  final String? assignedBy;
  final String? notes;

  AssignEquipmentToRoomInput({
    required this.equipmentId,
    required this.roomId,
    required this.assignmentDate,
    this.assignedBy,
    this.notes,
  });
}

/// Result of equipment assignment
class EquipmentAssignmentResult {
  final Equipment equipment;
  final String roomId;
  final String roomNumber;
  final DateTime assignmentDate;
  final bool success;

  EquipmentAssignmentResult({
    required this.equipment,
    required this.roomId,
    required this.roomNumber,
    required this.assignmentDate,
    required this.success,
  });

  @override
  String toString() {
    return 'Equipment ${equipment.name} assigned to Room $roomNumber';
  }
}

/// Use case for assigning equipment to a specific room
/// Tracks equipment location and availability
class AssignEquipmentToRoom
    extends UseCase<AssignEquipmentToRoomInput, EquipmentAssignmentResult> {
  final RoomRepository roomRepository;

  AssignEquipmentToRoom({required this.roomRepository});

  @override
  Future<bool> validate(AssignEquipmentToRoomInput input) async {
    // Validate assignment date
    if (input.assignmentDate
        .isAfter(DateTime.now().add(const Duration(days: 1)))) {
      throw UseCaseValidationException(
        'Assignment date cannot be more than 1 day in the future',
      );
    }
    return true;
  }

  @override
  Future<EquipmentAssignmentResult> execute(
      AssignEquipmentToRoomInput input) async {
    // Get the target room
    final room = await roomRepository.getRoomById(input.roomId);

    // Check if equipment is already in this room
    final existingEquipment = room.equipment.firstWhere(
      (eq) => eq.equipmentId == input.equipmentId,
      orElse: () => Equipment(
        equipmentId: input.equipmentId,
        name: 'Unknown Equipment',
        type: 'General',
        serialNumber: 'SN-${input.equipmentId}',
        status: EquipmentStatus.OPERATIONAL,
        lastServiceDate: DateTime.now(),
        nextServiceDate: DateTime.now().add(const Duration(days: 90)),
      ),
    );

    // Check if equipment already exists in room
    if (room.equipment.any((eq) => eq.equipmentId == input.equipmentId)) {
      throw EntityConflictException(
        'Equipment ${input.equipmentId} is already assigned to this room',
        details: {
          'equipmentId': input.equipmentId,
          'roomId': input.roomId,
        },
      );
    }

    // TODO: Check if equipment is available (not in another room)
    // In real implementation, would query equipment repository

    // Create equipment to assign to room
    final equipmentToAssign = Equipment(
      equipmentId: existingEquipment.equipmentId,
      name: existingEquipment.name,
      type: existingEquipment.type,
      serialNumber: existingEquipment.serialNumber,
      status: existingEquipment.status,
      lastServiceDate: existingEquipment.lastServiceDate,
      nextServiceDate: existingEquipment.nextServiceDate,
    );

    // Add equipment to room
    room.addEquipment(equipmentToAssign);

    await roomRepository.updateRoom(room);

    return EquipmentAssignmentResult(
      equipment: equipmentToAssign,
      roomId: room.roomId,
      roomNumber: room.number,
      assignmentDate: input.assignmentDate,
      success: true,
    );
  }

  @override
  Future<void> onSuccess(EquipmentAssignmentResult result,
      AssignEquipmentToRoomInput input) async {
    print(
        '✓ Equipment assigned: ${result.equipment.name} → Room ${result.roomNumber}');
  }
}
