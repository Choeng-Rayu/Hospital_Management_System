import '../../repositories/patient_repository.dart';
import '../../repositories/doctor_repository.dart';

/// Use case for assigning a doctor to a patient
/// Manages the doctor-patient relationship
class AssignDoctorToPatient {
  final PatientRepository patientRepository;
  final DoctorRepository doctorRepository;

  AssignDoctorToPatient({
    required this.patientRepository,
    required this.doctorRepository,
  });

  /// Execute the doctor assignment
  ///
  /// Steps:
  /// 1. Validate patient exists
  /// 2. Validate doctor exists
  /// 3. Check doctor's patient load
  /// 4. Assign doctor to patient (bidirectional)
  /// 5. Update both records
  Future<void> execute({
    required String patientId,
    required String doctorId,
  }) async {
    // 1. Get the patient
    final patient = await patientRepository.getPatientById(patientId);

    // 2. Get the doctor
    final doctor = await doctorRepository.getDoctorById(doctorId);

    // 3. Check if doctor already assigned to patient
    if (patient.assignedDoctors.any((d) => d.staffID == doctorId)) {
      throw DoctorAlreadyAssignedException(
        'Doctor $doctorId is already assigned to patient $patientId',
      );
    }

    // 4. Optional: Check doctor's patient load (business rule)
    const maxPatientsPerDoctor = 50; // Example business rule
    if (doctor.patientCount >= maxPatientsPerDoctor) {
      throw DoctorOverloadedException(
        'Doctor $doctorId has reached maximum patient capacity',
      );
    }

    // 5. Assign doctor to patient (bidirectional update)
    patient.assignDoctor(doctor);

    // 6. Update both records
    await patientRepository.updatePatient(patient);
    await doctorRepository.updateDoctor(doctor);
  }
}

// Custom exceptions
class DoctorAlreadyAssignedException implements Exception {
  final String message;
  DoctorAlreadyAssignedException(this.message);
  @override
  String toString() => message;
}

class DoctorOverloadedException implements Exception {
  final String message;
  DoctorOverloadedException(this.message);
  @override
  String toString() => message;
}
