import '../../repositories/patient_repository.dart';
import '../../repositories/doctor_repository.dart';

/// Exception thrown when scheduling a patient meeting fails
class SchedulePatientMeetingException implements Exception {
  final String message;
  SchedulePatientMeetingException(this.message);

  @override
  String toString() => 'SchedulePatientMeetingException: $message';
}

/// Use case for scheduling a next meeting between a patient and doctor
/// Validates availability and updates both entities
class SchedulePatientMeeting {
  final PatientRepository patientRepository;
  final DoctorRepository doctorRepository;

  SchedulePatientMeeting({
    required this.patientRepository,
    required this.doctorRepository,
  });

  /// Schedule a meeting for a patient with their assigned doctor
  ///
  /// Throws [SchedulePatientMeetingException] if:
  /// - Patient doesn't exist
  /// - Doctor doesn't exist
  /// - Doctor is not assigned to patient
  /// - Doctor is not available at requested time
  /// - Meeting date is in the past
  Future<void> execute({
    required String patientId,
    required String doctorId,
    required DateTime meetingDate,
    int durationMinutes = 30,
  }) async {
    try {
      // 1. Validate patient exists and get patient
      final patient = await patientRepository.getPatientById(patientId);

      // 2. Validate doctor exists and get doctor
      final doctor = await doctorRepository.getDoctorById(doctorId);

      // 3. Validate meeting date is in the future
      if (meetingDate.isBefore(DateTime.now())) {
        throw SchedulePatientMeetingException(
          'Cannot schedule meeting in the past. Requested: $meetingDate',
        );
      }

      // 4. Validate doctor is assigned to patient
      if (!patient.assignedDoctors.contains(doctor)) {
        throw SchedulePatientMeetingException(
          'Doctor ${doctor.name} is not assigned to patient ${patient.name}. '
          'Please assign doctor to patient first.',
        );
      }

      // 5. Check doctor availability
      final isAvailable = await doctorRepository.isDoctorAvailableAt(
        doctorId,
        meetingDate,
        durationMinutes,
      );

      if (!isAvailable) {
        throw SchedulePatientMeetingException(
          'Doctor ${doctor.name} is not available at $meetingDate. '
          'Please choose a different time or use getAvailableTimeSlots() to find available times.',
        );
      }

      // 6. Schedule the meeting on the patient entity
      patient.scheduleNextMeeting(
        doctor: doctor,
        meetingDate: meetingDate,
        durationMinutes: durationMinutes,
      );

      // 7. Update patient and doctor in repositories
      await patientRepository.updatePatient(patient);
      await doctorRepository.updateDoctor(doctor);
    } on SchedulePatientMeetingException {
      rethrow;
    } catch (e) {
      throw SchedulePatientMeetingException(
        'Failed to schedule meeting: ${e.toString()}',
      );
    }
  }

  /// Get available time slots for scheduling
  Future<List<DateTime>> getAvailableSlots({
    required String patientId,
    required String doctorId,
    required DateTime date,
    int durationMinutes = 30,
    int startHour = 8,
    int endHour = 17,
  }) async {
    // Validate patient and doctor exist
    final patientExists = await patientRepository.patientExists(patientId);
    if (!patientExists) {
      throw SchedulePatientMeetingException(
        'Patient with ID $patientId not found',
      );
    }

    final doctorExists = await doctorRepository.doctorExists(doctorId);
    if (!doctorExists) {
      throw SchedulePatientMeetingException(
        'Doctor with ID $doctorId not found',
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
  }

  /// Check if a specific time is available
  Future<bool> isTimeAvailable({
    required String doctorId,
    required DateTime dateTime,
    int durationMinutes = 30,
  }) async {
    final doctorExists = await doctorRepository.doctorExists(doctorId);
    if (!doctorExists) {
      throw SchedulePatientMeetingException(
        'Doctor with ID $doctorId not found',
      );
    }

    return await doctorRepository.isDoctorAvailableAt(
      doctorId,
      dateTime,
      durationMinutes,
    );
  }
}
