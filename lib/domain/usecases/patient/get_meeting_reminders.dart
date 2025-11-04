import '../../repositories/patient_repository.dart';

/// Exception thrown when getting meeting reminders fails
class GetMeetingRemindersException implements Exception {
  final String message;
  GetMeetingRemindersException(this.message);

  @override
  String toString() => 'GetMeetingRemindersException: $message';
}

/// Data class to hold meeting reminder information
class MeetingReminder {
  final String patientId;
  final String patientName;
  final String doctorName;
  final DateTime meetingDate;
  final bool isOverdue;
  final bool isSoon;
  final int daysUntilMeeting;

  MeetingReminder({
    required this.patientId,
    required this.patientName,
    required this.doctorName,
    required this.meetingDate,
    required this.isOverdue,
    required this.isSoon,
    required this.daysUntilMeeting,
  });

  @override
  String toString() {
    if (isOverdue) {
      return '⚠️  OVERDUE: ${patientName} missed meeting with Dr. $doctorName on $meetingDate';
    } else if (isSoon) {
      return '🔔 SOON: ${patientName} has meeting with Dr. $doctorName in $daysUntilMeeting days';
    } else {
      return '📅 ${patientName} has meeting with Dr. $doctorName on $meetingDate';
    }
  }
}

/// Use case for getting meeting reminders for patients
/// Helps identify upcoming and overdue meetings
class GetMeetingReminders {
  final PatientRepository patientRepository;

  GetMeetingReminders({required this.patientRepository});

  /// Get all upcoming meeting reminders (within next 7 days)
  Future<List<MeetingReminder>> getUpcomingReminders() async {
    try {
      final patients =
          await patientRepository.getPatientsWithUpcomingMeetings();
      return _buildReminders(patients);
    } catch (e) {
      throw GetMeetingRemindersException(
        'Failed to get upcoming reminders: ${e.toString()}',
      );
    }
  }

  /// Get all overdue meeting reminders
  Future<List<MeetingReminder>> getOverdueReminders() async {
    try {
      final patients = await patientRepository.getPatientsWithOverdueMeetings();
      return _buildReminders(patients);
    } catch (e) {
      throw GetMeetingRemindersException(
        'Failed to get overdue reminders: ${e.toString()}',
      );
    }
  }

  /// Get all meeting reminders for a specific date
  Future<List<MeetingReminder>> getRemindersForDate(DateTime date) async {
    try {
      final patients =
          await patientRepository.getPatientsWithMeetingsOnDate(date);
      return _buildReminders(patients);
    } catch (e) {
      throw GetMeetingRemindersException(
        'Failed to get reminders for date: ${e.toString()}',
      );
    }
  }

  /// Get meeting reminders for a specific doctor's patients
  Future<List<MeetingReminder>> getRemindersForDoctor(String doctorId) async {
    try {
      final patients =
          await patientRepository.getPatientsByDoctorMeetings(doctorId);
      return _buildReminders(patients);
    } catch (e) {
      throw GetMeetingRemindersException(
        'Failed to get reminders for doctor: ${e.toString()}',
      );
    }
  }

  /// Get all meeting reminders (upcoming + overdue + future)
  Future<List<MeetingReminder>> getAllReminders() async {
    try {
      final allPatients = await patientRepository.getAllPatients();
      final patientsWithMeetings =
          allPatients.where((p) => p.hasNextMeeting).toList();
      return _buildReminders(patientsWithMeetings);
    } catch (e) {
      throw GetMeetingRemindersException(
        'Failed to get all reminders: ${e.toString()}',
      );
    }
  }

  /// Helper method to build reminder objects from patients
  List<MeetingReminder> _buildReminders(List<dynamic> patients) {
    final reminders = <MeetingReminder>[];

    for (final patient in patients) {
      if (patient.hasNextMeeting &&
          patient.nextMeetingDate != null &&
          patient.nextMeetingDoctor != null) {
        final now = DateTime.now();
        final daysUntil = patient.nextMeetingDate!.difference(now).inDays;

        reminders.add(MeetingReminder(
          patientId: patient.patientID,
          patientName: patient.name,
          doctorName: patient.nextMeetingDoctor!.name,
          meetingDate: patient.nextMeetingDate!,
          isOverdue: patient.isNextMeetingOverdue,
          isSoon: patient.isNextMeetingSoon,
          daysUntilMeeting: daysUntil,
        ));
      }
    }

    // Sort by date (earliest first)
    reminders.sort((a, b) => a.meetingDate.compareTo(b.meetingDate));

    return reminders;
  }
}
