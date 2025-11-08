import '../../repositories/nurse_repository.dart';
import '../../repositories/room_repository.dart';
import '../base/use_case.dart';

/// Input for assigning nurse to room
class AssignNurseToRoomInput {
  final String nurseId;
  final String roomId;

  AssignNurseToRoomInput({
    required this.nurseId,
    required this.roomId,
  });
}

/// Use case for assigning a nurse to a room
/// Validates nurse availability and manages room assignments
class AssignNurseToRoom extends UseCase<AssignNurseToRoomInput, void> {
  final NurseRepository nurseRepository;
  final RoomRepository roomRepository;

  static const int maxRoomsPerNurse = 4;

  AssignNurseToRoom({
    required this.nurseRepository,
    required this.roomRepository,
  });

  @override
  Future<bool> validate(AssignNurseToRoomInput input) async {
    final nurseExists = await nurseRepository.nurseExists(input.nurseId);
    if (!nurseExists) {
      throw EntityNotFoundException('Nurse', input.nurseId);
    }

    final roomExists = await roomRepository.roomExists(input.roomId);
    if (!roomExists) {
      throw EntityNotFoundException('Room', input.roomId);
    }

    return true;
  }

  @override
  Future<void> execute(AssignNurseToRoomInput input) async {
    final nurse = await nurseRepository.getNurseById(input.nurseId);

    final room = await roomRepository.getRoomById(input.roomId);

    if (nurse.assignedRooms.any((r) => r.roomId == input.roomId)) {
      throw EntityConflictException(
        'Nurse ${nurse.name} is already assigned to room ${room.number}',
        code: 'NURSE_ALREADY_ASSIGNED_TO_ROOM',
      );
    }

    if (nurse.assignedRooms.length >= maxRoomsPerNurse) {
      throw BusinessRuleViolationException(
        'MAX_ROOMS_PER_NURSE',
        'Nurse ${nurse.name} has reached maximum room capacity ($maxRoomsPerNurse)',
      );
    }

    nurse.assignedRooms.add(room);

    await nurseRepository.updateNurse(nurse);
  }
}
