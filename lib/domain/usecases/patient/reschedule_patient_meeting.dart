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
      // 1. Get patient
      final patient = await patientRepository.getPatientById(patientId);

      // 2. Validate patient has a meeting scheduled
      if (!patient.hasNextMeeting) {
        throw ReschedulePatientMeetingException(
          'Patient ${patient.name} has no scheduled meeting to reschedule',
        );
      }

      // 3. Validate new meeting date is in the future
      if (newMeetingDate.isBefore(DateTime.now())) {
        throw ReschedulePatientMeetingException(
          'Cannot reschedule meeting to the past. Requested: $newMeetingDate',
        );
      }

      // 4. Get doctor information
      final doctorId = patient.nextMeetingDoctor?.staffID;
      if (doctorId == null) {
        throw ReschedulePatientMeetingException(
          'Invalid meeting data: Doctor information is missing',
        );
      }

      // 5. Check doctor availability at new time
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

      // 6. Get doctor to update their schedule
      final doctor = await doctorRepository.getDoctorById(doctorId);

      // 7. Reschedule the meeting (updates both schedules)
      patient.rescheduleNextMeeting(
        newMeetingDate,
        durationMinutes: durationMinutes,
      );

      // 8. Update both entities in repositories
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
      // Get patient
      final patient = await patientRepository.getPatientById(patientId);

      // Validate patient has a meeting
      if (!patient.hasNextMeeting) {
        throw ReschedulePatientMeetingException(
          'Patient has no scheduled meeting',
        );
      }

      // Get doctor ID
      final doctorId = patient.nextMeetingDoctor?.staffID;
      if (doctorId == null) {
        throw ReschedulePatientMeetingException(
          'Invalid meeting data: Doctor information is missing',
        );
      }

      // Get available slots from doctor repository
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
