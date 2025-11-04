import 'package:test/test.dart';
import 'package:hospital_management/domain/entities/patient.dart';
import 'package:hospital_management/domain/entities/doctor.dart';

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

void main() {
  group('Patient Next Meeting Tests', () {
    late Doctor testDoctor;
    late Patient testPatient;

    setUp(() {
      // Create a test doctor with empty schedule
      testDoctor = Doctor(
        name: 'Dr. John Smith',
        dateOfBirth: '1980-01-01',
        address: '123 Medical St',
        tel: '+1234567890',
        staffID: 'DOC001',
        hireDate: DateTime(2010, 1, 1),
        salary: 150000.0,
        schedule: {},
        specialization: 'Cardiology',
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

      // Create a test patient
      testPatient = Patient(
        name: 'John Doe',
        dateOfBirth: '1990-01-01',
        address: '456 Patient Ave',
        tel: '+9876543210',
        patientID: 'P001',
        bloodType: 'A+',
        medicalRecords: [],
        allergies: [],
        emergencyContact: '+1122334455',
      );
    });

    test('Patient initially has no next meeting', () {
      expect(testPatient.hasNextMeeting, isFalse);
      expect(testPatient.nextMeetingDate, isNull);
      expect(testPatient.nextMeetingDoctor, isNull);
    });

    test('Can schedule next meeting with assigned doctor', () {
      // First assign the doctor
      testPatient.assignDoctor(testDoctor);

      // Schedule a meeting during working hours (10 AM)
      final now = DateTime.now();
      final meetingDate = DateTime(now.year, now.month, now.day + 7, 10, 0);
      testPatient.scheduleNextMeeting(
        doctor: testDoctor,
        meetingDate: meetingDate,
      );

      expect(testPatient.hasNextMeeting, isTrue);
      expect(testPatient.nextMeetingDate, equals(meetingDate));
      expect(testPatient.nextMeetingDoctor, equals(testDoctor));
    });

    test('Cannot schedule meeting with unassigned doctor', () {
      final now = DateTime.now();
      final meetingDate = DateTime(now.year, now.month, now.day + 7, 10, 0);

      expect(
        () => testPatient.scheduleNextMeeting(
          doctor: testDoctor,
          meetingDate: meetingDate,
        ),
        throwsArgumentError,
      );
    });

    test('Cannot schedule meeting in the past', () {
      testPatient.assignDoctor(testDoctor);
      final pastDate = DateTime.now().subtract(Duration(days: 1));

      expect(
        () => testPatient.scheduleNextMeeting(
          doctor: testDoctor,
          meetingDate: pastDate,
        ),
        throwsArgumentError,
      );
    });

    test('Can cancel next meeting', () {
      testPatient.assignDoctor(testDoctor);
      final meetingDate = getWorkingHoursDate(7);

      testPatient.scheduleNextMeeting(
        doctor: testDoctor,
        meetingDate: meetingDate,
      );

      expect(testPatient.hasNextMeeting, isTrue);

      testPatient.cancelNextMeeting();

      expect(testPatient.hasNextMeeting, isFalse);
      expect(testPatient.nextMeetingDate, isNull);
      expect(testPatient.nextMeetingDoctor, isNull);
    });

    test('Can reschedule next meeting', () {
      testPatient.assignDoctor(testDoctor);
      final originalDate = getWorkingHoursDate(7);
      final newDate = getWorkingHoursDate(14);

      testPatient.scheduleNextMeeting(
        doctor: testDoctor,
        meetingDate: originalDate,
      );

      testPatient.rescheduleNextMeeting(newDate);

      expect(testPatient.hasNextMeeting, isTrue);
      expect(testPatient.nextMeetingDate, equals(newDate));
      expect(testPatient.nextMeetingDoctor, equals(testDoctor));
    });

    test('isNextMeetingSoon returns true for meeting within 7 days', () {
      testPatient.assignDoctor(testDoctor);
      final soonDate = getWorkingHoursDate(3);

      testPatient.scheduleNextMeeting(
        doctor: testDoctor,
        meetingDate: soonDate,
      );

      expect(testPatient.isNextMeetingSoon, isTrue);
    });

    test('isNextMeetingSoon returns false for meeting beyond 7 days', () {
      testPatient.assignDoctor(testDoctor);
      final farDate = getWorkingHoursDate(10);

      testPatient.scheduleNextMeeting(
        doctor: testDoctor,
        meetingDate: farDate,
      );

      expect(testPatient.isNextMeetingSoon, isFalse);
    });

    test('nextMeetingInfo returns formatted string', () {
      testPatient.assignDoctor(testDoctor);
      final meetingDate = getWorkingHoursDate(7);

      testPatient.scheduleNextMeeting(
        doctor: testDoctor,
        meetingDate: meetingDate,
      );

      final info = testPatient.nextMeetingInfo;
      expect(info, isNotNull);
      expect(info, contains('Dr. John Smith'));
    });

    test('nextMeetingInfo returns null when no meeting scheduled', () {
      expect(testPatient.nextMeetingInfo, isNull);
    });

    test('Patient constructor validates meeting data consistency', () {
      expect(
        () => Patient(
          name: 'John Doe',
          dateOfBirth: '1990-01-01',
          address: '456 Patient Ave',
          tel: '+9876543210',
          patientID: 'P002',
          bloodType: 'B+',
          medicalRecords: [],
          allergies: [],
          emergencyContact: '+1122334455',
          hasNextMeeting: true, // Set true but no date/doctor
        ),
        throwsArgumentError,
      );
    });

    test('Patient can be created with next meeting data', () {
      final meetingDate = getWorkingHoursDate(5);

      final patient = Patient(
        name: 'Jane Doe',
        dateOfBirth: '1992-05-15',
        address: '789 Test St',
        tel: '+5556667777',
        patientID: 'P003',
        bloodType: 'O-',
        medicalRecords: [],
        allergies: [],
        emergencyContact: '+8889990000',
        hasNextMeeting: true,
        nextMeetingDate: meetingDate,
        nextMeetingDoctor: testDoctor,
        assignedDoctors: [testDoctor],
      );

      expect(patient.hasNextMeeting, isTrue);
      expect(patient.nextMeetingDate, equals(meetingDate));
      expect(patient.nextMeetingDoctor, equals(testDoctor));
    });
  });

  group('Doctor Availability Tests', () {
    late Doctor testDoctor;
    late Doctor busyDoctor;
    late Patient testPatient;

    setUp(() {
      // Create a test doctor with empty schedule
      testDoctor = Doctor(
        name: 'Dr. John Smith',
        dateOfBirth: '1980-01-01',
        address: '123 Medical St',
        tel: '+1234567890',
        staffID: 'DOC001',
        hireDate: DateTime(2010, 1, 1),
        salary: 150000.0,
        schedule: {},
        specialization: 'Cardiology',
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

      // Create a busy doctor with existing schedule
      final tomorrow = getWorkingHoursDate(1);
      final tomorrowKey =
          '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';

      busyDoctor = Doctor(
        name: 'Dr. Jane Busy',
        dateOfBirth: '1975-05-15',
        address: '456 Hospital Blvd',
        tel: '+9876543210',
        staffID: 'DOC002',
        hireDate: DateTime(2005, 3, 15),
        salary: 180000.0,
        schedule: {
          tomorrowKey: [
            DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10, 0),
            DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 14, 0),
          ]
        },
        specialization: 'Neurology',
        certifications: ['Board Certified', 'Fellowship'],
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
        name: 'John Doe',
        dateOfBirth: '1990-01-01',
        address: '456 Patient Ave',
        tel: '+9876543210',
        patientID: 'P001',
        bloodType: 'A+',
        medicalRecords: [],
        allergies: [],
        emergencyContact: '+1122334455',
      );
    });

    test('Can check if doctor is available at specific time', () {
      testPatient.assignDoctor(testDoctor);
      final futureDate = getWorkingHoursDate(3);

      final isAvailable = testPatient.isDoctorAvailableAt(
        doctor: testDoctor,
        dateTime: futureDate,
      );

      expect(isAvailable, isTrue);
    });

    test('Doctor is not available during existing appointment', () {
      testPatient.assignDoctor(busyDoctor);
      final tomorrow = getWorkingHoursDate(1);
      final conflictTime = DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        10,
        15,
      ); // Conflicts with 10:00 appointment

      final isAvailable = testPatient.isDoctorAvailableAt(
        doctor: busyDoctor,
        dateTime: conflictTime,
      );

      expect(isAvailable, isFalse);
    });

    test('Cannot schedule meeting when doctor is busy', () {
      testPatient.assignDoctor(busyDoctor);
      final tomorrow = getWorkingHoursDate(1);
      final conflictTime = DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        10,
        15,
      );

      expect(
        () => testPatient.scheduleNextMeeting(
          doctor: busyDoctor,
          meetingDate: conflictTime,
        ),
        throwsArgumentError,
      );
    });

    test('Meeting is added to doctor schedule when scheduled', () {
      testPatient.assignDoctor(testDoctor);
      final meetingDate = getWorkingHoursDate(7);
      final scheduleKey =
          '${meetingDate.year}-${meetingDate.month.toString().padLeft(2, '0')}-${meetingDate.day.toString().padLeft(2, '0')}';

      // Check doctor has no schedule for that day initially
      expect(testDoctor.getScheduleFor(scheduleKey), isEmpty);

      testPatient.scheduleNextMeeting(
        doctor: testDoctor,
        meetingDate: meetingDate,
      );

      // Check meeting was added to doctor's schedule
      final doctorSchedule = testDoctor.getScheduleFor(scheduleKey);
      expect(doctorSchedule, contains(meetingDate));
    });

    test('Meeting is removed from doctor schedule when cancelled', () {
      testPatient.assignDoctor(testDoctor);
      final meetingDate = getWorkingHoursDate(7);
      final scheduleKey =
          '${meetingDate.year}-${meetingDate.month.toString().padLeft(2, '0')}-${meetingDate.day.toString().padLeft(2, '0')}';

      testPatient.scheduleNextMeeting(
        doctor: testDoctor,
        meetingDate: meetingDate,
      );

      // Verify meeting is in schedule
      expect(testDoctor.getScheduleFor(scheduleKey), contains(meetingDate));

      testPatient.cancelNextMeeting();

      // Verify meeting was removed
      expect(testDoctor.getScheduleFor(scheduleKey), isEmpty);
    });

    test('Old meeting is removed and new one added when rescheduling', () {
      testPatient.assignDoctor(testDoctor);
      final originalDate = getWorkingHoursDate(7);
      final newDate = getWorkingHoursDate(10);

      testPatient.scheduleNextMeeting(
        doctor: testDoctor,
        meetingDate: originalDate,
      );

      final originalKey =
          '${originalDate.year}-${originalDate.month.toString().padLeft(2, '0')}-${originalDate.day.toString().padLeft(2, '0')}';
      final newKey =
          '${newDate.year}-${newDate.month.toString().padLeft(2, '0')}-${newDate.day.toString().padLeft(2, '0')}';

      testPatient.rescheduleNextMeeting(newDate);

      // Original date should be empty
      expect(testDoctor.getScheduleFor(originalKey), isEmpty);
      // New date should have the meeting
      expect(testDoctor.getScheduleFor(newKey), contains(newDate));
    });

    test('Can get doctor schedule for specific date', () {
      testPatient.assignDoctor(busyDoctor);
      final tomorrow = getWorkingHoursDate(1);

      final schedule = testPatient.getDoctorScheduleForDate(
        doctor: busyDoctor,
        date: tomorrow,
      );

      expect(
          schedule.length, equals(2)); // busyDoctor has 2 appointments tomorrow
    });

    test('Can get suggested available time slots', () {
      testPatient.assignDoctor(testDoctor);
      final futureDate = getWorkingHoursDate(3);

      final availableSlots = testPatient.getSuggestedAvailableSlots(
        doctor: testDoctor,
        date: futureDate,
        startHour: 9,
        endHour: 12, // 3-hour window
      );

      // Should have multiple slots (every 30 minutes from 9 AM to 12 PM)
      expect(availableSlots.length, greaterThan(0));
      expect(
          availableSlots.every((slot) => slot.isAfter(DateTime.now())), isTrue);
    });

    test('Available slots exclude busy times', () {
      testPatient.assignDoctor(busyDoctor);
      final tomorrow = getWorkingHoursDate(1);

      final availableSlots = testPatient.getSuggestedAvailableSlots(
        doctor: busyDoctor,
        date: tomorrow,
        startHour: 9,
        endHour: 16,
      );

      // Slots should not include 10:00 or 14:00 (busy times)
      final busyTime1 =
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10, 0);
      final busyTime2 =
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 14, 0);

      expect(availableSlots, isNot(contains(busyTime1)));
      expect(availableSlots, isNot(contains(busyTime2)));
    });

    test('Cannot reschedule to busy time', () {
      testPatient.assignDoctor(busyDoctor);
      final tomorrow = getWorkingHoursDate(1);

      // Schedule initial meeting at an available time
      final initialTime = DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        9,
        0,
      );

      testPatient.scheduleNextMeeting(
        doctor: busyDoctor,
        meetingDate: initialTime,
      );

      // Try to reschedule to busy time
      final busyTime = DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        10,
        15,
      );

      expect(
        () => testPatient.rescheduleNextMeeting(busyTime),
        throwsArgumentError,
      );
    });

    test('Scheduling meeting updates both patient and doctor', () {
      testPatient.assignDoctor(testDoctor);
      final meetingDate = getWorkingHoursDate(5);

      testPatient.scheduleNextMeeting(
        doctor: testDoctor,
        meetingDate: meetingDate,
      );

      // Check patient state
      expect(testPatient.hasNextMeeting, isTrue);
      expect(testPatient.nextMeetingDate, equals(meetingDate));
      expect(testPatient.nextMeetingDoctor, equals(testDoctor));

      // Check doctor schedule
      final scheduleKey =
          '${meetingDate.year}-${meetingDate.month.toString().padLeft(2, '0')}-${meetingDate.day.toString().padLeft(2, '0')}';
      expect(testDoctor.getScheduleFor(scheduleKey), contains(meetingDate));
    });
  });
}
