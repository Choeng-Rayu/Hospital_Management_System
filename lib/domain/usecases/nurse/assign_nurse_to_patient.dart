import '../../repositories/nurse_repository.dart';
import '../../repositories/patient_repository.dart';
import '../base/use_case.dart';

/// Input for assigning nurse to patient
class AssignNurseToPatientInput {
  final String nurseId;
  final String patientId;

  AssignNurseToPatientInput({
    required this.nurseId,
    required this.patientId,
  });
}

/// Use case for assigning a nurse to a patient
/// Validates nurse availability and patient capacity
class AssignNurseToPatient extends UseCase<AssignNurseToPatientInput, void> {
  final NurseRepository nurseRepository;
  final PatientRepository patientRepository;

  static const int maxPatientsPerNurse = 5;

  AssignNurseToPatient({
    required this.nurseRepository,
    required this.patientRepository,
  });

  @override
  Future<bool> validate(AssignNurseToPatientInput input) async {
    final nurseExists = await nurseRepository.nurseExists(input.nurseId);
    if (!nurseExists) {
      throw EntityNotFoundException('Nurse', input.nurseId);
    }

    final patientExists =
        await patientRepository.patientExists(input.patientId);
    if (!patientExists) {
      throw EntityNotFoundException('Patient', input.patientId);
    }

    return true;
  }

  @override
  Future<void> execute(AssignNurseToPatientInput input) async {
    final nurse = await nurseRepository.getNurseById(input.nurseId);

    final patient = await patientRepository.getPatientById(input.patientId);

    if (nurse.assignedPatients.any((p) => p.patientID == input.patientId)) {
      throw EntityConflictException(
        'Nurse ${nurse.name} is already assigned to patient ${patient.name}',
        code: 'NURSE_ALREADY_ASSIGNED',
      );
    }

    if (nurse.assignedPatients.length >= maxPatientsPerNurse) {
      throw BusinessRuleViolationException(
        'MAX_PATIENTS_PER_NURSE',
        'Nurse ${nurse.name} has reached maximum patient capacity ($maxPatientsPerNurse)',
      );
    }

    nurse.assignedPatients.add(patient);

    await nurseRepository.updateNurse(nurse);

    // Note: Patient entity doesn't track assigned nurses directly in current implementation
    // If needed, extend Patient entity to include assignedNurses field
  }
}
