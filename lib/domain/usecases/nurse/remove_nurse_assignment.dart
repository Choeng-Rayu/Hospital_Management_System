import '../../repositories/nurse_repository.dart';
import '../base/use_case.dart';

/// Input for removing nurse assignment
class RemoveNurseAssignmentInput {
  final String nurseId;
  final String? patientId;
  final String? roomId;

  RemoveNurseAssignmentInput({
    required this.nurseId,
    this.patientId,
    this.roomId,
  });

  bool get hasPatientId => patientId != null;
  bool get hasRoomId => roomId != null;
}

/// Use case for removing nurse assignments
/// Can remove patient or room assignments or both
class RemoveNurseAssignment extends UseCase<RemoveNurseAssignmentInput, void> {
  final NurseRepository nurseRepository;

  RemoveNurseAssignment({required this.nurseRepository});

  @override
  Future<bool> validate(RemoveNurseAssignmentInput input) async {
    // Must specify at least one type of assignment to remove
    if (!input.hasPatientId && !input.hasRoomId) {
      throw UseCaseValidationException(
        'Must specify either patientId or roomId to remove',
        code: 'MISSING_ASSIGNMENT_TYPE',
      );
    }

    // Validate nurse exists
    final nurseExists = await nurseRepository.nurseExists(input.nurseId);
    if (!nurseExists) {
      throw EntityNotFoundException('Nurse', input.nurseId);
    }

    return true;
  }

  @override
  Future<void> execute(RemoveNurseAssignmentInput input) async {
    // Get nurse
    final nurse = await nurseRepository.getNurseById(input.nurseId);

    bool assignmentRemoved = false;

    // Remove patient assignment
    if (input.hasPatientId) {
      final patientId = input.patientId!;
      final patientIndex =
          nurse.assignedPatients.indexWhere((p) => p.patientID == patientId);

      if (patientIndex >= 0) {
        nurse.assignedPatients.removeAt(patientIndex);
        assignmentRemoved = true;
      } else {
        throw EntityNotFoundException(
          'Patient assignment for nurse ${nurse.name}',
          patientId,
        );
      }
    }

    // Remove room assignment
    if (input.hasRoomId) {
      final roomId = input.roomId!;
      final roomIndex =
          nurse.assignedRooms.indexWhere((r) => r.roomId == roomId);

      if (roomIndex >= 0) {
        nurse.assignedRooms.removeAt(roomIndex);
        assignmentRemoved = true;
      } else {
        throw EntityNotFoundException(
          'Room assignment for nurse ${nurse.name}',
          roomId,
        );
      }
    }

    // Update nurse record
    if (assignmentRemoved) {
      await nurseRepository.updateNurse(nurse);
    }
  }
}
