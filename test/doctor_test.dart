import 'package:test/test.dart';
import 'package:hospital_management/data/repositories/doctor_repository_impl.dart';
import 'package:hospital_management/data/datasources/local/doctor_local_data_source.dart';
import 'package:hospital_management/data/datasources/local/patient_local_data_source.dart';
import 'package:hospital_management/domain/entities/doctor.dart';

void main() {
  late DoctorRepositoryImpl doctorRepo;
  final testIds = <String>[];

  setUp(() {
    doctorRepo = DoctorRepositoryImpl(
      doctorDataSource: DoctorLocalDataSource(),
      patientDataSource: PatientLocalDataSource(),
    );
  });

  tearDown(() async {
    for (var id in testIds) {
      try {
        await doctorRepo.deleteDoctor(id);
      } catch (e) {}
    }
    testIds.clear();
  });

  group('Doctor Operations', () {
    test('can get all doctors', () async {
      final doctors = await doctorRepo.getAllDoctors();
      expect(doctors.isNotEmpty, true);
    });

    test('can get doctor by ID', () async {
      final doctor = await doctorRepo.getDoctorById('D001');
      expect(doctor.staffID, 'D001');
    });

    test('can search by specialization', () async {
      final doctors = await doctorRepo.getDoctorsBySpecialization('Cardiology');
      for (var d in doctors) {
        expect(d.specialization, 'Cardiology');
      }
    });

    test('can create doctor', () async {
      final doctor = Doctor(
        name: 'Dr. Test',
        dateOfBirth: '1975-03-15',
        address: '123 Hospital Rd',
        tel: '+855-12-345-678',
        staffID: 'AUTO',
        hireDate: DateTime.now(),
        salary: 80000,
        schedule: {},
        specialization: 'Pediatrics',
        certifications: [],
        currentPatients: [],
        workingHours: {},
      );

      await doctorRepo.saveDoctor(doctor);
      final all = await doctorRepo.getAllDoctors();
      final created = all.firstWhere((d) => d.name == 'Dr. Test');
      testIds.add(created.staffID);

      expect(created.specialization, 'Pediatrics');
    });

    test('can update doctor', () async {
      final doctor = Doctor(
        name: 'Dr. Update Test',
        dateOfBirth: '1980-05-20',
        address: '456 Old Address',
        tel: '+855-87-654-321',
        staffID: 'AUTO',
        hireDate: DateTime.now(),
        salary: 75000,
        schedule: {},
        specialization: 'Surgery',
        certifications: [],
        currentPatients: [],
        workingHours: {},
      );

      await doctorRepo.saveDoctor(doctor);
      final all = await doctorRepo.getAllDoctors();
      final created = all.firstWhere((d) => d.name == 'Dr. Update Test');
      testIds.add(created.staffID);

      final updated = Doctor(
        name: created.name,
        dateOfBirth: created.dateOfBirth,
        address: '999 New Address',
        tel: created.tel,
        staffID: created.staffID,
        hireDate: created.hireDate,
        salary: created.salary,
        schedule: created.schedule,
        specialization: created.specialization,
        certifications: created.certifications,
        currentPatients: created.currentPatients,
        workingHours: created.workingHours,
      );

      await doctorRepo.updateDoctor(updated);
      final retrieved = await doctorRepo.getDoctorById(created.staffID);
      expect(retrieved.address, '999 New Address');
    });
  });
}
