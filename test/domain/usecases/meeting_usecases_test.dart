import 'package:test/test.dart';
import 'package:hospital_management/domain/entities/patient.dart';
import 'package:hospital_management/domain/entities/doctor.dart';
import 'package:hospital_management/domain/repositories/patient_repository.dart';
import 'package:hospital_management/domain/repositories/doctor_repository.dart';
import 'package:hospital_management/domain/usecases/patient/schedule_patient_meeting.dart';
import 'package:hospital_management/domain/usecases/patient/cancel_patient_meeting.dart';
import 'package:hospital_management/domain/usecases/patient/reschedule_patient_meeting.dart';

// Helper function to create a DateTime during working hours (10 AM) on a weekday
DateTime getWorkingHoursDate(int daysFromNow) {
  final now = DateTime.now();
  var targetDate = DateTime(now.year, now.month, now.day + daysFromNow, 10, 0);

  // Adjust to next Monday if it falls on a weekend
  while (targetDate.weekday == DateTime.saturday ||
      targetDate.weekday == DateTime.sunday) {
    targetDate = targetDate.add(Duration(days: 1));
  }

  return targetDate;
}

// Mock repositories for testing
class MockPatientRepository implements PatientRepository {
  final Map<String, Patient> _patients = {};

  @override
  Future<Patient> getPatientById(String patientId) async {
    final patient = _patients[patientId];
    if (patient == null) {
      throw Exception('Patient not found: $patientId');
    }
    return patient;
  }

  @override
  Future<List<Patient>> getAllPatients() async => _patients.values.toList();

  @override
  Future<void> savePatient(Patient patient) async {
    _patients[patient.patientID] = patient;
  }

  @override
  Future<void> updatePatient(Patient patient) async {
    _patients[patient.patientID] = patient;
  }

  @override
  Future<void> deletePatient(String patientId) async {
    _patients.remove(patientId);
  }

  @override
  Future<List<Patient>> searchPatientsByName(String name) async {
    return _patients.values
        .where((p) => p.name.toLowerCase().contains(name.toLowerCase()))
        .toList();
  }

  @override
  Future<List<Patient>> getPatientsByBloodType(String bloodType) async {
    return _patients.values.where((p) => p.bloodType == bloodType).toList();
  }

  @override
  Future<List<Patient>> getPatientsByDoctorId(String doctorId) async {
    return _patients.values
        .where((p) => p.assignedDoctors.any((d) => d.staffID == doctorId))
        .toList();
  }

  @override
  Future<bool> patientExists(String patientId) async {
    return _patients.containsKey(patientId);
  }

  @override
  Future<List<Patient>> getPatientsWithUpcomingMeetings() async {
    return _patients.values.where((p) => p.isNextMeetingSoon).toList();
  }

  @override
  Future<List<Patient>> getPatientsWithOverdueMeetings() async {
    return _patients.values.where((p) => p.isNextMeetingOverdue).toList();
  }

  @override
  Future<List<Patient>> getPatientsByDoctorMeetings(String doctorId) async {
    return _patients.values
        .where(
            (p) => p.hasNextMeeting && p.nextMeetingDoctor?.staffID == doctorId)
        .toList();
  }

  @override
  Future<List<Patient>> getPatientsWithMeetingsOnDate(DateTime date) async {
    return _patients.values.where((p) {
      if (!p.hasNextMeeting || p.nextMeetingDate == null) return false;
      final meetingDate = p.nextMeetingDate!;
      return meetingDate.year == date.year &&
          meetingDate.month == date.month &&
          meetingDate.day == date.day;
    }).toList();
  }
}

class MockDoctorRepository implements DoctorRepository {
  @override
  Future<bool> isDoctorFullyAvailable(
      String doctorId, DateTime dateTime, int durationMinutes) async {
    return true; // Mock implementation always returns available for testing
  }

  final Map<String, Doctor> _doctors = {};

  @override
  Future<Doctor> getDoctorById(String staffId) async {
    final doctor = _doctors[staffId];
    if (doctor == null) {
      throw Exception('Doctor not found: $staffId');
    }
    return doctor;
  }

  @override
  Future<List<Doctor>> getAllDoctors() async => _doctors.values.toList();

  @override
  Future<void> saveDoctor(Doctor doctor) async {
    _doctors[doctor.staffID] = doctor;
  }

  @override
  Future<void> updateDoctor(Doctor doctor) async {
    _doctors[doctor.staffID] = doctor;
  }

  @override
  Future<void> deleteDoctor(String staffId) async {
    _doctors.remove(staffId);
  }

  @override
  Future<List<Doctor>> searchDoctorsByName(String name) async {
    return _doctors.values
        .where((d) => d.name.toLowerCase().contains(name.toLowerCase()))
        .toList();
  }

  @override
  Future<List<Doctor>> getDoctorsBySpecialization(String specialization) async {
    return _doctors.values
        .where((d) => d.specialization == specialization)
        .toList();
  }

  @override
  Future<List<Doctor>> getAvailableDoctors(DateTime date) async {
    return _doctors.values.toList();
  }

  @override
  Future<List<Patient>> getDoctorPatients(String doctorId) async {
    final doctor = await getDoctorById(doctorId);
    return doctor.currentPatients.toList();
  }

  @override
  Future<bool> doctorExists(String staffId) async {
    return _doctors.containsKey(staffId);
  }

  @override
  Future<List<DateTime>> getDoctorScheduleForDate(
      String doctorId, DateTime date) async {
    final doctor = await getDoctorById(doctorId);
    final dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return doctor.getScheduleFor(dateKey);
  }

  @override
  Future<bool> isDoctorAvailableAt(
    String doctorId,
    DateTime dateTime,
    int durationMinutes,
  ) async {
    final doctor = await getDoctorById(doctorId);
    final dateKey =
        '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    final schedule = doctor.getScheduleFor(dateKey);

    if (schedule.isEmpty) return true;

    final requestedEnd = dateTime.add(Duration(minutes: durationMinutes));

    for (final scheduledTime in schedule) {
      final scheduledEnd = scheduledTime.add(Duration(minutes: 30));
      if (dateTime.isBefore(scheduledEnd) &&
          requestedEnd.isAfter(scheduledTime)) {
        return false;
      }
    }

    return true;
  }

  @override
  Future<List<DateTime>> getAvailableTimeSlots(
    String doctorId,
    DateTime date, {
    int durationMinutes = 30,
    int startHour = 8,
    int endHour = 17,
  }) async {
    final availableSlots = <DateTime>[];
    final startOfDay = DateTime(date.year, date.month, date.day, startHour);
    DateTime currentSlot = startOfDay;
    final endOfDay = DateTime(date.year, date.month, date.day, endHour);

    while (currentSlot.isBefore(endOfDay)) {
      final isAvailable = await isDoctorAvailableAt(
        doctorId,
        currentSlot,
        durationMinutes,
      );
      if (isAvailable && currentSlot.isAfter(DateTime.now())) {
        availableSlots.add(currentSlot);
      }
      currentSlot = currentSlot.add(Duration(minutes: 30));
    }

    return availableSlots;
  }

  @override
  Future<List<Doctor>> getDoctorsAvailableAt(
    DateTime dateTime,
    int durationMinutes,
  ) async {
    final available = <Doctor>[];
    for (final doctor in _doctors.values) {
      final isAvailable = await isDoctorAvailableAt(
        doctor.staffID,
        dateTime,
        durationMinutes,
      );
      if (isAvailable) {
        available.add(doctor);
      }
    }
    return available;
  }
}

void main() {
  group('Meeting Use Cases Tests', () {
    late MockPatientRepository patientRepo;
    late MockDoctorRepository doctorRepo;
    late SchedulePatientMeeting scheduleUseCase;
    late CancelPatientMeeting cancelUseCase;
    late ReschedulePatientMeeting rescheduleUseCase;
    late Doctor testDoctor;
    late Patient testPatient;

    setUp(() {
      patientRepo = MockPatientRepository();
      doctorRepo = MockDoctorRepository();
      scheduleUseCase = SchedulePatientMeeting(
        patientRepository: patientRepo,
        doctorRepository: doctorRepo,
      );
      cancelUseCase = CancelPatientMeeting(
        patientRepository: patientRepo,
        doctorRepository: doctorRepo,
      );
      rescheduleUseCase = ReschedulePatientMeeting(
        patientRepository: patientRepo,
        doctorRepository: doctorRepo,
      );

      // Create test entities
      testDoctor = Doctor(
        name: 'Dr. Test',
        dateOfBirth: '1980-01-01',
        address: '123 Test St',
        tel: '+1234567890',
        staffID: 'DOC001',
        hireDate: DateTime(2010, 1, 1),
        salary: 150000.0,
        schedule: {},
        specialization: 'General',
        certifications: ['Board Certified'],
        currentPatients: [],
        workingHours: {
          'Monday': {
            'start': '2025-11-02T09:00:00Z',
            'end': '2025-11-02T17:00:00Z'
          },
          'Tuesday': {
            'start': '2025-11-02T09:00:00Z',
            'end': '2025-11-02T17:00:00Z'
          },
          'Wednesday': {
            'start': '2025-11-02T09:00:00Z',
            'end': '2025-11-02T17:00:00Z'
          },
          'Thursday': {
            'start': '2025-11-02T09:00:00Z',
            'end': '2025-11-02T17:00:00Z'
          },
          'Friday': {
            'start': '2025-11-02T09:00:00Z',
            'end': '2025-11-02T17:00:00Z'
          },
        },
      );

      testPatient = Patient(
        name: 'Test Patient',
        dateOfBirth: '1990-01-01',
        address: '456 Test Ave',
        tel: '+9876543210',
        patientID: 'P001',
        bloodType: 'A+',
        medicalRecords: [],
        allergies: [],
        emergencyContact: '+1122334455',
      );

      testPatient.assignDoctor(testDoctor);

      // Save to repositories
      doctorRepo.saveDoctor(testDoctor);
      patientRepo.savePatient(testPatient);
    });

    test('Can schedule a meeting successfully', () async {
      final meetingDate = getWorkingHoursDate(3);

      await scheduleUseCase.execute(
        patientId: 'P001',
        doctorId: 'DOC001',
        meetingDate: meetingDate,
      );

      final updatedPatient = await patientRepo.getPatientById('P001');
      expect(updatedPatient.hasNextMeeting, isTrue);
      expect(updatedPatient.nextMeetingDate, equals(meetingDate));
    });

    test('Cannot schedule meeting in the past', () async {
      final pastDate = DateTime.now().subtract(Duration(days: 1));

      expect(
        () => scheduleUseCase.execute(
          patientId: 'P001',
          doctorId: 'DOC001',
          meetingDate: pastDate,
        ),
        throwsA(isA<SchedulePatientMeetingException>()),
      );
    });

    test('Can get available time slots', () async {
      final tomorrow = getWorkingHoursDate(1);

      final slots = await scheduleUseCase.getAvailableSlots(
        patientId: 'P001',
        doctorId: 'DOC001',
        date: tomorrow,
        startHour: 9,
        endHour: 12,
      );

      expect(slots.length, greaterThan(0));
      expect(slots.every((slot) => slot.isAfter(DateTime.now())), isTrue);
    });

    test('Can cancel a scheduled meeting', () async {
      // First schedule a meeting
      final meetingDate = getWorkingHoursDate(3);
      await scheduleUseCase.execute(
        patientId: 'P001',
        doctorId: 'DOC001',
        meetingDate: meetingDate,
      );

      // Then cancel it
      await cancelUseCase.execute(patientId: 'P001');

      final updatedPatient = await patientRepo.getPatientById('P001');
      expect(updatedPatient.hasNextMeeting, isFalse);
    });

    test('Cannot cancel non-existent meeting', () async {
      expect(
        () => cancelUseCase.execute(patientId: 'P001'),
        throwsA(isA<CancelPatientMeetingException>()),
      );
    });

    test('Can reschedule a meeting', () async {
      // Schedule initial meeting
      final initialDate = getWorkingHoursDate(3);
      await scheduleUseCase.execute(
        patientId: 'P001',
        doctorId: 'DOC001',
        meetingDate: initialDate,
      );

      // Reschedule to new date
      final newDate = getWorkingHoursDate(5);
      await rescheduleUseCase.execute(
        patientId: 'P001',
        newMeetingDate: newDate,
      );

      final updatedPatient = await patientRepo.getPatientById('P001');
      expect(updatedPatient.hasNextMeeting, isTrue);
      expect(updatedPatient.nextMeetingDate, equals(newDate));
    });

    test('Cannot reschedule non-existent meeting', () async {
      final newDate = getWorkingHoursDate(5);

      expect(
        () => rescheduleUseCase.execute(
          patientId: 'P001',
          newMeetingDate: newDate,
        ),
        throwsA(isA<ReschedulePatientMeetingException>()),
      );
    });

    test('Repository queries work correctly', () async {
      // Schedule a meeting soon
      final soonDate = getWorkingHoursDate(3);
      await scheduleUseCase.execute(
        patientId: 'P001',
        doctorId: 'DOC001',
        meetingDate: soonDate,
      );

      // Test getPatientsWithUpcomingMeetings
      final upcomingPatients =
          await patientRepo.getPatientsWithUpcomingMeetings();
      expect(upcomingPatients.length, equals(1));
      expect(upcomingPatients.first.patientID, equals('P001'));

      // Test getPatientsByDoctorMeetings
      final doctorPatients =
          await patientRepo.getPatientsByDoctorMeetings('DOC001');
      expect(doctorPatients.length, equals(1));
      expect(doctorPatients.first.patientID, equals('P001'));
    });
  });
}
