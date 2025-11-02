import '../../repositories/patient_repository.dart';
import '../../repositories/doctor_repository.dart';

/// Exception thrown when canceling a patient meeting fails
class CancelPatientMeetingException implements Exception {
  final String message;
  CancelPatientMeetingException(this.message);

  @override
  String toString() => 'CancelPatientMeetingException: $message';
}

/// Use case for canceling a patient's next scheduled meeting
/// Updates both patient and doctor entities
class CancelPatientMeeting {
  final PatientRepository patientRepository;
  final DoctorRepository doctorRepository;

  CancelPatientMeeting({
    required this.patientRepository,
    required this.doctorRepository,
  });

  /// Cancel a patient's next scheduled meeting
  ///
  /// Throws [CancelPatientMeetingException] if:
  /// - Patient doesn't exist
  /// - Patient has no scheduled meeting
  /// - Doctor information is invalid
  Future<void> execute({required String patientId}) async {
    try {
      // 1. Get patient
      final patient = await patientRepository.getPatientById(patientId);

      // 2. Validate patient has a meeting scheduled
      if (!patient.hasNextMeeting) {
        throw CancelPatientMeetingException(
          'Patient ${patient.name} has no scheduled meeting to cancel',
        );
      }

      // 3. Get doctor information before canceling
      final doctorId = patient.nextMeetingDoctor?.staffID;
      if (doctorId == null) {
        throw CancelPatientMeetingException(
          'Invalid meeting data: Doctor information is missing',
        );
      }

      // 4. Get doctor to update their schedule
      final doctor = await doctorRepository.getDoctorById(doctorId);

      // 5. Cancel the meeting (this will update both patient and doctor schedule)
      patient.cancelNextMeeting();

      // 6. Update both entities in repositories
      await patientRepository.updatePatient(patient);
      await doctorRepository.updateDoctor(doctor);
    } on CancelPatientMeetingException {
      rethrow;
    } catch (e) {
      throw CancelPatientMeetingException(
        'Failed to cancel meeting: ${e.toString()}',
      );
    }
  }
}
