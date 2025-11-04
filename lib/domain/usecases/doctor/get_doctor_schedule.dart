import '../../repositories/doctor_repository.dart';
import '../../repositories/patient_repository.dart';

/// Exception thrown when getting doctor schedule fails
class GetDoctorScheduleException implements Exception {
  final String message;
  GetDoctorScheduleException(this.message);

  @override
  String toString() => 'GetDoctorScheduleException: $message';
}

/// Data class to hold schedule entry information
class ScheduleEntry {
  final DateTime time;
  final String? patientName;
  final String? patientId;
  final bool isAvailable;

  ScheduleEntry({
    required this.time,
    this.patientName,
    this.patientId,
    required this.isAvailable,
  });

  String get formattedTime =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  @override
  String toString() {
    if (isAvailable) {
      return '$formattedTime - Available';
    } else {
      return '$formattedTime - Meeting with ${patientName ?? 'Patient'}';
    }
  }
}

/// Use case for getting a doctor's schedule
/// Shows both occupied and available time slots
class GetDoctorSchedule {
  final DoctorRepository doctorRepository;
  final PatientRepository patientRepository;

  GetDoctorSchedule({
    required this.doctorRepository,
    required this.patientRepository,
  });

  /// Get doctor's schedule for a specific date with patient information
  Future<List<ScheduleEntry>> getScheduleForDate({
    required String doctorId,
    required DateTime date,
  }) async {
    try {
      // 1. Get doctor's occupied times
      final occupiedTimes = await doctorRepository.getDoctorScheduleForDate(
        doctorId,
        date,
      );

      // 2. Get patients with meetings with this doctor on this date
      final patients =
          await patientRepository.getPatientsByDoctorMeetings(doctorId);

      // Filter patients who have meetings on the specified date
      final patientsOnDate = patients.where((patient) {
        if (!patient.hasNextMeeting || patient.nextMeetingDate == null) {
          return false;
        }
        final meetingDate = patient.nextMeetingDate!;
        return meetingDate.year == date.year &&
            meetingDate.month == date.month &&
            meetingDate.day == date.day;
      }).toList();

      // 3. Build schedule entries with patient information
      final scheduleEntries = <ScheduleEntry>[];

      for (final time in occupiedTimes) {
        // Find patient with meeting at this time
        final patient = patientsOnDate.firstWhere(
          (p) => p.nextMeetingDate == time,
          orElse: () => patientsOnDate.first, // Fallback if not found
        );

        scheduleEntries.add(ScheduleEntry(
          time: time,
          patientName: patient.name,
          patientId: patient.patientID,
          isAvailable: false,
        ));
      }

      // Sort by time
      scheduleEntries.sort((a, b) => a.time.compareTo(b.time));

      return scheduleEntries;
    } catch (e) {
      throw GetDoctorScheduleException(
        'Failed to get doctor schedule: ${e.toString()}',
      );
    }
  }

  /// Get available time slots for a doctor on a specific date
  Future<List<ScheduleEntry>> getAvailableSlots({
    required String doctorId,
    required DateTime date,
    int durationMinutes = 30,
    int startHour = 8,
    int endHour = 17,
  }) async {
    try {
      final availableTimes = await doctorRepository.getAvailableTimeSlots(
        doctorId,
        date,
        durationMinutes: durationMinutes,
        startHour: startHour,
        endHour: endHour,
      );

      return availableTimes
          .map((time) => ScheduleEntry(
                time: time,
                isAvailable: true,
              ))
          .toList();
    } catch (e) {
      throw GetDoctorScheduleException(
        'Failed to get available slots: ${e.toString()}',
      );
    }
  }

  /// Get complete daily schedule (occupied + available slots)
  Future<Map<String, List<ScheduleEntry>>> getCompleteSchedule({
    required String doctorId,
    required DateTime date,
    int startHour = 8,
    int endHour = 17,
  }) async {
    try {
      final occupied = await getScheduleForDate(
        doctorId: doctorId,
        date: date,
      );

      final available = await getAvailableSlots(
        doctorId: doctorId,
        date: date,
        startHour: startHour,
        endHour: endHour,
      );

      return {
        'occupied': occupied,
        'available': available,
      };
    } catch (e) {
      throw GetDoctorScheduleException(
        'Failed to get complete schedule: ${e.toString()}',
      );
    }
  }

  /// Check if a doctor is available at a specific time
  Future<bool> isAvailableAt({
    required String doctorId,
    required DateTime dateTime,
    int durationMinutes = 30,
  }) async {
    try {
      return await doctorRepository.isDoctorAvailableAt(
        doctorId,
        dateTime,
        durationMinutes,
      );
    } catch (e) {
      throw GetDoctorScheduleException(
        'Failed to check availability: ${e.toString()}',
      );
    }
  }
}
