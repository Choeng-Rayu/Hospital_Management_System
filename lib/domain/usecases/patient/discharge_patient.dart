import '../../repositories/patient_repository.dart';
import '../../repositories/room_repository.dart';

/// Use case for discharging a patient from the hospital
/// Handles the complete discharge process including room cleanup
class DischargePatient {
  final PatientRepository patientRepository;
  final RoomRepository roomRepository;

  DischargePatient({
    required this.patientRepository,
    required this.roomRepository,
  });

  /// Execute the patient discharge process
  ///
  /// Steps:
  /// 1. Validate patient exists
  /// 2. Check if patient is admitted
  /// 3. Discharge patient from bed
  /// 4. Update patient information
  /// 5. Update room information
  Future<void> execute({required String patientId}) async {
    final patient = await patientRepository.getPatientById(patientId);

    if (patient.currentRoom == null || patient.currentBed == null) {
      throw PatientNotAdmittedException(
        'Patient $patientId is not currently admitted',
      );
    }

    final room = patient.currentRoom!;

    patient.discharge();

    await patientRepository.updatePatient(patient);

    await roomRepository.updateRoom(room);
  }
}

// Custom exception
class PatientNotAdmittedException implements Exception {
  final String message;
  PatientNotAdmittedException(this.message);
  @override
  String toString() => message;
}
