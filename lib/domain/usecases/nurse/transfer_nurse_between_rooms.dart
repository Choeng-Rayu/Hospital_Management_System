import '../../repositories/nurse_repository.dart';
import '../../repositories/room_repository.dart';
import '../base/use_case.dart';

/// Input for transferring nurse between rooms
class TransferNurseBetweenRoomsInput {
  final String nurseId;
  final String fromRoomId;
  final String toRoomId;

  TransferNurseBetweenRoomsInput({
    required this.nurseId,
    required this.fromRoomId,
    required this.toRoomId,
  });
}

/// Use case for transferring a nurse from one room to another
/// Manages room reassignments for nurses
class TransferNurseBetweenRooms
    extends UseCase<TransferNurseBetweenRoomsInput, void> {
  final NurseRepository nurseRepository;
  final RoomRepository roomRepository;

  static const int maxRoomsPerNurse = 4;

  TransferNurseBetweenRooms({
    required this.nurseRepository,
    required this.roomRepository,
  });

  @override
  Future<bool> validate(TransferNurseBetweenRoomsInput input) async {
    // Validate nurse exists
    final nurseExists = await nurseRepository.nurseExists(input.nurseId);
    if (!nurseExists) {
      throw EntityNotFoundException('Nurse', input.nurseId);
    }

    // Validate source room exists
    final fromRoomExists = await roomRepository.roomExists(input.fromRoomId);
    if (!fromRoomExists) {
      throw EntityNotFoundException('Source Room', input.fromRoomId);
    }

    // Validate target room exists
    final toRoomExists = await roomRepository.roomExists(input.toRoomId);
    if (!toRoomExists) {
      throw EntityNotFoundException('Target Room', input.toRoomId);
    }

    // Cannot transfer to same room
    if (input.fromRoomId == input.toRoomId) {
      throw UseCaseValidationException(
        'Cannot transfer nurse to the same room',
        code: 'SAME_ROOM_TRANSFER',
      );
    }

    return true;
  }

  @override
  Future<void> execute(TransferNurseBetweenRoomsInput input) async {
    // Get nurse
    final nurse = await nurseRepository.getNurseById(input.nurseId);

    // Get rooms
    final fromRoom = await roomRepository.getRoomById(input.fromRoomId);
    final toRoom = await roomRepository.getRoomById(input.toRoomId);

    // Check if nurse is assigned to source room
    final fromRoomIndex =
        nurse.assignedRooms.indexWhere((r) => r.roomId == input.fromRoomId);

    if (fromRoomIndex < 0) {
      throw EntityNotFoundException(
        'Nurse ${nurse.name} is not assigned to room',
        fromRoom.number,
      );
    }

    // Check if nurse is already assigned to target room
    final isAlreadyAssignedToTarget =
        nurse.assignedRooms.any((r) => r.roomId == input.toRoomId);

    if (isAlreadyAssignedToTarget) {
      throw EntityConflictException(
        'Nurse ${nurse.name} is already assigned to room ${toRoom.number}',
        code: 'ALREADY_ASSIGNED_TO_TARGET',
      );
    }

    // Remove from source room
    nurse.assignedRooms.removeAt(fromRoomIndex);

    // Add to target room
    nurse.assignedRooms.add(toRoom);

    // Update nurse record
    await nurseRepository.updateNurse(nurse);
  }
}
