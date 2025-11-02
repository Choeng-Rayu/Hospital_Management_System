import '../../repositories/room_repository.dart';
import '../base/use_case.dart';

/// Input for transferring equipment between rooms
class TransferEquipmentBetweenRoomsInput {
  final String equipmentId;
  final String sourceRoomId;
  final String targetRoomId;
  final DateTime transferDate;
  final String? transferredBy;
  final String? reason;

  TransferEquipmentBetweenRoomsInput({
    required this.equipmentId,
    required this.sourceRoomId,
    required this.targetRoomId,
    DateTime? transferDate,
    this.transferredBy,
    this.reason,
  }) : transferDate = transferDate ?? DateTime.now();
}

/// Result of equipment transfer
class EquipmentTransferResult {
  final String equipmentId;
  final String equipmentName;
  final String sourceRoom;
  final String targetRoom;
  final DateTime transferDate;
  final String transferId;

  EquipmentTransferResult({
    required this.equipmentId,
    required this.equipmentName,
    required this.sourceRoom,
    required this.targetRoom,
    required this.transferDate,
    required this.transferId,
  });

  @override
  String toString() {
    return '''
🔄 Equipment Transfer: $transferId
Equipment: $equipmentName
From: Room $sourceRoom
To: Room $targetRoom
Date: ${transferDate.toString().split('.')[0]}
''';
  }
}

/// Use case for transferring equipment between rooms
/// Maintains accurate equipment inventory and location tracking
class TransferEquipmentBetweenRooms extends UseCase<
    TransferEquipmentBetweenRoomsInput, EquipmentTransferResult> {
  final RoomRepository roomRepository;

  TransferEquipmentBetweenRooms({required this.roomRepository});

  @override
  Future<bool> validate(TransferEquipmentBetweenRoomsInput input) async {
    // Validate source and target are different
    if (input.sourceRoomId == input.targetRoomId) {
      throw UseCaseValidationException(
        'Source and target rooms must be different',
      );
    }

    // Validate transfer date is not in future (allow same day)
    if (input.transferDate
        .isAfter(DateTime.now().add(const Duration(hours: 1)))) {
      throw UseCaseValidationException(
        'Transfer date cannot be in the future',
      );
    }
    return true;
  }

  @override
  Future<EquipmentTransferResult> execute(
      TransferEquipmentBetweenRoomsInput input) async {
    // Get source and target rooms
    final sourceRoom = await roomRepository.getRoomById(input.sourceRoomId);
    final targetRoom = await roomRepository.getRoomById(input.targetRoomId);

    // Find equipment in source room
    final equipment = sourceRoom.equipment.firstWhere(
      (eq) => eq.equipmentId == input.equipmentId,
      orElse: () => throw EntityNotFoundException(
        'Equipment',
        input.equipmentId,
      ),
    );

    // Check if equipment is already in target room
    if (targetRoom.equipment.any((eq) => eq.equipmentId == input.equipmentId)) {
      throw EntityConflictException(
        'Equipment already exists in target room',
        details: {'equipmentId': input.equipmentId},
      );
    }

    // Equipment transfer will be logged through the repository

    // Remove equipment from source room
    sourceRoom.removeEquipment(input.equipmentId);
    await roomRepository.updateRoom(sourceRoom);

    // Add equipment to target room
    targetRoom.addEquipment(equipment);
    await roomRepository.updateRoom(targetRoom);

    // Generate transfer ID
    final transferId = 'TRF-${DateTime.now().millisecondsSinceEpoch % 100000}';

    return EquipmentTransferResult(
      equipmentId: equipment.equipmentId,
      equipmentName: equipment.name,
      sourceRoom: sourceRoom.number,
      targetRoom: targetRoom.number,
      transferDate: input.transferDate,
      transferId: transferId,
    );
  }

  @override
  Future<void> onSuccess(EquipmentTransferResult result,
      TransferEquipmentBetweenRoomsInput input) async {
    print('🔄 Equipment transferred: ${result.equipmentName}');
    print('   From: Room ${result.sourceRoom} → To: Room ${result.targetRoom}');
  }
}
