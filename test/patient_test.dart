import 'package:test/test.dart';
import 'package:hospital_management/data/repositories/patient_repository_impl.dart';
import 'package:hospital_management/data/repositories/doctor_repository_impl.dart';
import 'package:hospital_management/data/datasources/local/patient_local_data_source.dart';
import 'package:hospital_management/data/datasources/local/doctor_local_data_source.dart';
import 'package:hospital_management/domain/entities/patient.dart';
import 'package:hospital_management/domain/entities/doctor.dart';

void main() {
  late PatientRepositoryImpl patientRepo;
  late DoctorRepositoryImpl doctorRepo;

  setUp(() {
    patientRepo = PatientRepositoryImpl(
      patientDataSource: PatientLocalDataSource(),
      doctorDataSource: DoctorLocalDataSource(),
    );
    doctorRepo = DoctorRepositoryImpl(
      doctorDataSource: DoctorLocalDataSource(),
      patientDataSource: PatientLocalDataSource(),
    );
  });

  group('Patient Basic Operations', () {
    test('can get all patients', () async {
      final patients = await patientRepo.getAllPatients();
      expect(patients.isNotEmpty, true);
    });

    test('can get patient by ID', () async {
      final patient = await patientRepo.getPatientById('P001');
      expect(patient.patientID, 'P001');
    });

    test('can search patients by name', () async {
      final patients = await patientRepo.getAllPatients();
      final name = patients.first.name.split(' ').first;
      final results = await patientRepo.searchPatientsByName(name);
      expect(results.isNotEmpty, true);
    });

    test('can filter by blood type', () async {
      final patients = await patientRepo.getPatientsByBloodType('O+');
      for (var p in patients) {
        expect(p.bloodType, 'O+');
      }
    });
  });

  group('Patient CRUD', () {
    final testIds = <String>[];

    tearDown(() async {
      for (var id in testIds) {
        try {
          await patientRepo.deletePatient(id);
        } catch (e) {}
      }
      testIds.clear();
    });

    test('can create patient', () async {
      final patient = Patient(
        patientID: 'AUTO',
        name: 'Test Patient',
        dateOfBirth: '1990-01-01',
        address: '123 Test St',
        tel: '+855-12-345-678',
        bloodType: 'A+',
        medicalRecords: [],
        allergies: [],
        emergencyContact: '+855-87-654-321',
      );

      await patientRepo.savePatient(patient);
      final all = await patientRepo.getAllPatients();
      final created = all.firstWhere((p) => p.name == 'Test Patient');
      testIds.add(created.patientID);

      expect(created.name, 'Test Patient');
    });

    test('can update patient', () async {
      final patient = Patient(
        patientID: 'AUTO',
        name: 'Update Test',
        dateOfBirth: '1985-05-15',
        address: '456 Old St',
        tel: '+855-11-111-111',
        bloodType: 'B+',
        medicalRecords: [],
        allergies: [],
        emergencyContact: '+855-22-222-222',
      );

      await patientRepo.savePatient(patient);
      final all = await patientRepo.getAllPatients();
      final created = all.firstWhere((p) => p.name == 'Update Test');
      testIds.add(created.patientID);

      final updated = Patient(
        patientID: created.patientID,
        name: created.name,
        dateOfBirth: created.dateOfBirth,
        address: '789 New St',
        tel: created.tel,
        bloodType: created.bloodType,
        medicalRecords: created.medicalRecords,
        allergies: created.allergies,
        emergencyContact: created.emergencyContact,
      );

      await patientRepo.updatePatient(updated);
      final retrieved = await patientRepo.getPatientById(created.patientID);
      expect(retrieved.address, '789 New St');
    });

    test('can delete patient', () async {
      final patient = Patient(
        patientID: 'AUTO',
        name: 'Delete Test',
        dateOfBirth: '1992-03-20',
        address: '999 Delete Rd',
        tel: '+855-33-333-333',
        bloodType: 'O-',
        medicalRecords: [],
        allergies: [],
        emergencyContact: '+855-44-444-444',
      );

      await patientRepo.savePatient(patient);
      final all = await patientRepo.getAllPatients();
      final created = all.firstWhere((p) => p.name == 'Delete Test');

      await patientRepo.deletePatient(created.patientID);

      expect(
        () => patientRepo.getPatientById(created.patientID),
        throwsException,
      );
    });
  });

  group('Patient Meeting', () {
    late Doctor testDoctor;
    late Patient testPatient;

    setUp(() {
      final workingHours = <String, Map<String, String>>{};
      for (int i = 0; i < 30; i++) {
        final date = DateTime.now().add(Duration(days: i));
        if (date.weekday != DateTime.saturday &&
            date.weekday != DateTime.sunday) {
          final key =
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          workingHours[key] = {
            'start': DateTime(date.year, date.month, date.day, 9, 0)
                .toIso8601String(),
            'end': DateTime(date.year, date.month, date.day, 17, 0)
                .toIso8601String(),
          };
        }
      }

      testDoctor = Doctor(
        name: 'Dr. Test',
        dateOfBirth: '1980-01-01',
        address: '123 Medical St',
        tel: '+855-99-999-999',
        staffID: 'TEST_DOC',
        hireDate: DateTime(2010, 1, 1),
        salary: 100000,
        schedule: {},
        specialization: 'General',
        certifications: [],
        currentPatients: [],
        workingHours: workingHours,
      );

      testPatient = Patient(
        name: 'Test Patient',
        dateOfBirth: '1990-01-01',
        address: '456 Patient Ave',
        tel: '+855-88-888-888',
        patientID: 'TEST_P',
        bloodType: 'A+',
        medicalRecords: [],
        allergies: [],
        emergencyContact: '+855-77-777-777',
      );
    });

    test('initially has no meeting', () {
      expect(testPatient.hasNextMeeting, false);
      expect(testPatient.nextMeetingDate, null);
    });

    test('can schedule meeting', () {
      testPatient.assignDoctor(testDoctor);
      final meetingDate = DateTime.now().add(Duration(days: 7));
      final workday = meetingDate.weekday != DateTime.saturday &&
              meetingDate.weekday != DateTime.sunday
          ? meetingDate
          : meetingDate.add(Duration(days: 2));
      final meeting = DateTime(workday.year, workday.month, workday.day, 10, 0);

      testPatient.scheduleNextMeeting(doctor: testDoctor, meetingDate: meeting);

      expect(testPatient.hasNextMeeting, true);
      expect(testPatient.nextMeetingDate, meeting);
    });

    test('cannot schedule with unassigned doctor', () {
      final meeting = DateTime.now().add(Duration(days: 7));

      expect(
        () => testPatient.scheduleNextMeeting(
            doctor: testDoctor, meetingDate: meeting),
        throwsArgumentError,
      );
    });

    test('can cancel meeting', () {
      testPatient.assignDoctor(testDoctor);
      final meetingDate = DateTime.now().add(Duration(days: 7));
      final workday = meetingDate.weekday != DateTime.saturday &&
              meetingDate.weekday != DateTime.sunday
          ? meetingDate
          : meetingDate.add(Duration(days: 2));
      final meeting = DateTime(workday.year, workday.month, workday.day, 10, 0);

      testPatient.scheduleNextMeeting(doctor: testDoctor, meetingDate: meeting);
      testPatient.cancelNextMeeting();

      expect(testPatient.hasNextMeeting, false);
    });
  });
}
