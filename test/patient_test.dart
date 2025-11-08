/// Comprehensive Patient Tests
/// Combines: Data Loading, CRUD Operations, and Meeting Scheduling
import 'package:test/test.dart';
import 'package:hospital_management/data/repositories/patient_repository_impl.dart';
import 'package:hospital_management/data/repositories/doctor_repository_impl.dart';
import 'package:hospital_management/data/datasources/local/patient_local_data_source.dart';
import 'package:hospital_management/data/datasources/local/doctor_local_data_source.dart';
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
  // ==========================================================================
  // PART 1: DATA LOADING TESTS
  // ==========================================================================
  group('Patient - Data Loading', () {
    late PatientRepositoryImpl repository;

    setUp(() {
      final patientDataSource = PatientLocalDataSource();
      final doctorDataSource = DoctorLocalDataSource();
      repository = PatientRepositoryImpl(
        patientDataSource: patientDataSource,
        doctorDataSource: doctorDataSource,
      );
    });

    test('getAllPatients returns non-empty list', () async {
      final patients = await repository.getAllPatients();
      expect(patients, isNotEmpty);
      expect(patients.length, greaterThan(0));
    });

    test('getAllPatients returns valid patient data', () async {
      final patients = await repository.getAllPatients();
      for (final patient in patients) {
        expect(patient.patientID, isNotEmpty);
        expect(patient.name, isNotEmpty);
        expect(patient.bloodType, isNotEmpty);
        expect(patient.emergencyContact, isNotEmpty);
      }
    });

    test('getPatientById returns correct patient', () async {
      final patient = await repository.getPatientById('P001');
      expect(patient.patientID, equals('P001'));
      expect(patient.name, isNotEmpty);
      expect(patient.bloodType, isNotEmpty);
    });

    test('getPatientById throws when patient not found', () async {
      expect(
        () => repository.getPatientById('INVALID_ID'),
        throwsException,
      );
    });

    test('getPatientsByBloodType returns correct patients', () async {
      final oPositivePatients = await repository.getPatientsByBloodType('O+');
      expect(oPositivePatients, isNotEmpty);
      for (final patient in oPositivePatients) {
        expect(patient.bloodType, equals('O+'));
      }
    });

    test('patients have correct relationship data', () async {
      final patients = await repository.getAllPatients();
      for (final patient in patients) {
        expect(patient.assignedDoctors, isA<List>());
        expect(patient.assignedNurses, isA<List>());
        expect(patient.prescriptions, isA<List>());
        expect(patient.medicalRecords, isA<List>());
        expect(patient.allergies, isA<List>());
      }
    });
  });

  // ==========================================================================
  // PART 2: CRUD OPERATIONS TESTS
  // ==========================================================================
  group('Patient - CRUD Operations', () {
    late PatientRepositoryImpl patientRepository;
    late DoctorRepositoryImpl doctorRepository;
    late List<String> testPatientIds;

    setUpAll(() {
      final patientDataSource = PatientLocalDataSource();
      final doctorDataSource = DoctorLocalDataSource();
      patientRepository = PatientRepositoryImpl(
        patientDataSource: patientDataSource,
        doctorDataSource: doctorDataSource,
      );
      doctorRepository = DoctorRepositoryImpl(
        doctorDataSource: doctorDataSource,
        patientDataSource: patientDataSource,
      );
      testPatientIds = [];
    });

    tearDownAll(() async {
      for (final patientId in testPatientIds) {
        try {
          await patientRepository.deletePatient(patientId);
        } catch (e) {
          // Ignore cleanup errors
        }
      }
    });

    test('Should create new patient', () async {
      final patient = Patient(
        patientID: 'AUTO',
        name: 'Test Patient Create',
        dateOfBirth: '1990-01-01',
        address: '123 Test Street',
        tel: '012-345-6789',
        bloodType: 'O+',
        medicalRecords: ['Initial checkup'],
        allergies: ['None'],
        emergencyContact: '012-999-8888',
      );

      await patientRepository.savePatient(patient);
      final saved = await patientRepository.getAllPatients();
      final created = saved.firstWhere(
        (p) => p.name == 'Test Patient Create',
      );

      testPatientIds.add(created.patientID);
      expect(created.name, equals('Test Patient Create'));
      expect(created.bloodType, equals('O+'));
    });

    test('Should update existing patient', () async {
      final patient = Patient(
        patientID: 'AUTO',
        name: 'Test Patient Update',
        dateOfBirth: '1985-05-15',
        address: '456 Update Ave',
        tel: '012-111-2222',
        bloodType: 'A+',
        medicalRecords: ['Initial'],
        allergies: [],
        emergencyContact: '012-888-7777',
      );

      await patientRepository.savePatient(patient);
      final saved = await patientRepository.getAllPatients();
      final created = saved.firstWhere(
        (p) => p.name == 'Test Patient Update',
      );
      testPatientIds.add(created.patientID);

      final updated = Patient(
        patientID: created.patientID,
        name: created.name,
        dateOfBirth: created.dateOfBirth,
        address: '999 New Address',
        tel: created.tel,
        bloodType: created.bloodType,
        medicalRecords: created.medicalRecords.toList(),
        allergies: created.allergies.toList(),
        emergencyContact: created.emergencyContact,
      );

      await patientRepository.updatePatient(updated);
      final retrieved =
          await patientRepository.getPatientById(created.patientID);
      expect(retrieved.address, equals('999 New Address'));
    });

    test('Should delete patient', () async {
      final patient = Patient(
        patientID: 'AUTO',
        name: 'Test Patient Delete',
        dateOfBirth: '1992-03-20',
        address: '789 Delete Rd',
        tel: '012-333-4444',
        bloodType: 'B+',
        medicalRecords: [],
        allergies: [],
        emergencyContact: '012-555-6666',
      );

      await patientRepository.savePatient(patient);
      final saved = await patientRepository.getAllPatients();
      final created = saved.firstWhere(
        (p) => p.name == 'Test Patient Delete',
      );

      await patientRepository.deletePatient(created.patientID);

      expect(
        () => patientRepository.getPatientById(created.patientID),
        throwsException,
      );
    });

    test('Should search patients by name', () async {
      final patients =
          await patientRepository.searchPatientsByName('Test Patient');
      expect(patients, isNotEmpty);
      for (final patient in patients) {
        expect(patient.name.toLowerCase().contains('test patient'), isTrue);
      }
    });
  });

  // ==========================================================================
  // PART 3: MEETING SCHEDULING TESTS
  // ==========================================================================
  group('Patient - Meeting Scheduling', () {
    late Doctor testDoctor;
    late Patient testPatient;

    setUp(() {
      // Generate working hours for the next 30 days with exact date keys
      final now = DateTime.now();
      final workingHours = <String, Map<String, String>>{};

      for (int i = 0; i < 30; i++) {
        final date = now.add(Duration(days: i));
        if (date.weekday != DateTime.saturday &&
            date.weekday != DateTime.sunday) {
          final dateKey =
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          workingHours[dateKey] = {
            'start': DateTime(date.year, date.month, date.day, 9, 0)
                .toIso8601String(),
            'end': DateTime(date.year, date.month, date.day, 17, 0)
                .toIso8601String(),
          };
        }
      }

      testDoctor = Doctor(
        name: 'Dr. Test Scheduler',
        dateOfBirth: '1980-01-01',
        address: '123 Medical St',
        tel: '+1234567890',
        staffID: 'DOC_TEST',
        hireDate: DateTime(2010, 1, 1),
        salary: 150000.0,
        schedule: {},
        specialization: 'Cardiology',
        certifications: ['Board Certified'],
        currentPatients: [],
        workingHours: workingHours,
      );

      testPatient = Patient(
        name: 'Test Patient Meeting',
        dateOfBirth: '1990-01-01',
        address: '456 Patient Ave',
        tel: '+9876543210',
        patientID: 'P_TEST',
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
      testPatient.assignDoctor(testDoctor);
      final meetingDate = getWorkingHoursDate(7);

      testPatient.scheduleNextMeeting(
        doctor: testDoctor,
        meetingDate: meetingDate,
      );

      expect(testPatient.hasNextMeeting, isTrue);
      expect(testPatient.nextMeetingDate, equals(meetingDate));
      expect(testPatient.nextMeetingDoctor, equals(testDoctor));
    });

    test('Cannot schedule meeting with unassigned doctor', () {
      final meetingDate = getWorkingHoursDate(7);
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
    });

    test('Can reschedule next meeting', () {
      testPatient.assignDoctor(testDoctor);
      final firstDate = getWorkingHoursDate(7);
      final secondDate = getWorkingHoursDate(10);

      testPatient.scheduleNextMeeting(
        doctor: testDoctor,
        meetingDate: firstDate,
      );
      expect(testPatient.nextMeetingDate, equals(firstDate));

      testPatient.rescheduleNextMeeting(secondDate);
      expect(testPatient.nextMeetingDate, equals(secondDate));
      expect(testPatient.hasNextMeeting, isTrue);
    });
  });
}
