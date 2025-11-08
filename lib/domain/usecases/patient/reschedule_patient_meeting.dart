import '../../repositories/patient_repository.dart';
import '../../repositories/doctor_repository.dart';

/// Exception thrown when rescheduling a patient meeting fails
class ReschedulePatientMeetingException implements Exception {
  final String message;
  ReschedulePatientMeetingException(this.message);

  @override
  String toString() => 'ReschedulePatientMeetingException: $message';
}

/// Use case for rescheduling a patient's next meeting to a new date/time
/// Validates new time availability and updates both entities
class ReschedulePatientMeeting {
  final PatientRepository patientRepository;
  final DoctorRepository doctorRepository;

  ReschedulePatientMeeting({
    required this.patientRepository,
    required this.doctorRepository,
  });

  /// Reschedule a patient's next meeting to a new date/time
  ///
  /// Throws [ReschedulePatientMeetingException] if:
  /// - Patient doesn't exist
  /// - Patient has no scheduled meeting
  /// - New date is in the past
  /// - Doctor is not available at new time
  Future<void> execute({
    required String patientId,
    required DateTime newMeetingDate,
    int durationMinutes = 30,
  }) async {
    try {
      final patient = await patientRepository.getPatientById(patientId);

      if (!patient.hasNextMeeting) {
        throw ReschedulePatientMeetingException(
          'Patient ${patient.name} has no scheduled meeting to reschedule',
        );
      }

      if (newMeetingDate.isBefore(DateTime.now())) {
        throw ReschedulePatientMeetingException(
          'Cannot reschedule meeting to the past. Requested: $newMeetingDate',
        );
      }

      final doctorId = patient.nextMeetingDoctor?.staffID;
      if (doctorId == null) {
        throw ReschedulePatientMeetingException(
          'Invalid meeting data: Doctor information is missing',
        );
      }

      final isAvailable = await doctorRepository.isDoctorAvailableAt(
        doctorId,
        newMeetingDate,
        durationMinutes,
      );

      if (!isAvailable) {
        throw ReschedulePatientMeetingException(
          'Doctor is not available at $newMeetingDate. '
          'Please choose a different time.',
        );
      }

      final doctor = await doctorRepository.getDoctorById(doctorId);

      patient.rescheduleNextMeeting(
        newMeetingDate,
        durationMinutes: durationMinutes,
      );

      await patientRepository.updatePatient(patient);
      await doctorRepository.updateDoctor(doctor);
    } on ReschedulePatientMeetingException {
      rethrow;
    } catch (e) {
      throw ReschedulePatientMeetingException(
        'Failed to reschedule meeting: ${e.toString()}',
      );
    }
  }

  /// Get available time slots for rescheduling
  Future<List<DateTime>> getAvailableSlots({
    required String patientId,
    required DateTime date,
    int durationMinutes = 30,
    int startHour = 8,
    int endHour = 17,
  }) async {
    try {
      final patient = await patientRepository.getPatientById(patientId);

      if (!patient.hasNextMeeting) {
        throw ReschedulePatientMeetingException(
          'Patient has no scheduled meeting',
        );
      }

      final doctorId = patient.nextMeetingDoctor?.staffID;
      if (doctorId == null) {
        throw ReschedulePatientMeetingException(
          'Invalid meeting data: Doctor information is missing',
        );
      }

      return await doctorRepository.getAvailableTimeSlots(
        doctorId,
        date,
        durationMinutes: durationMinutes,
        startHour: startHour,
        endHour: endHour,
      );
    } catch (e) {
      throw ReschedulePatientMeetingException(
        'Failed to get available slots: ${e.toString()}',
      );
    }
  }
}
