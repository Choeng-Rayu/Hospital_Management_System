import 'package:test/test.dart';
import 'package:hospital_management/data/repositories/patient_repository_impl.dart';
import 'package:hospital_management/data/repositories/doctor_repository_impl.dart';
import 'package:hospital_management/data/repositories/appointment_repository_impl.dart';
import 'package:hospital_management/data/datasources/local/patient_local_data_source.dart';
import 'package:hospital_management/data/datasources/local/doctor_local_data_source.dart';
import 'package:hospital_management/data/datasources/local/appointment_local_data_source.dart';

void main() {
  late PatientRepositoryImpl patientRepo;
  late DoctorRepositoryImpl doctorRepo;
  late AppointmentRepositoryImpl appointmentRepo;

  setUp(() {
    patientRepo = PatientRepositoryImpl(
      patientDataSource: PatientLocalDataSource(),
      doctorDataSource: DoctorLocalDataSource(),
    );
    doctorRepo = DoctorRepositoryImpl(
      doctorDataSource: DoctorLocalDataSource(),
      patientDataSource: PatientLocalDataSource(),
    );
    appointmentRepo = AppointmentRepositoryImpl(
      appointmentDataSource: AppointmentLocalDataSource(),
      doctorDataSource: DoctorLocalDataSource(),
      patientDataSource: PatientLocalDataSource(),
    );
  });

  group('Search Operations', () {
    test('can search patients by name', () async {
      final all = await patientRepo.getAllPatients();
      if (all.isNotEmpty) {
        final firstName = all.first.name.split(' ').first;
        final results = await patientRepo.searchPatientsByName(firstName);
        expect(results.isNotEmpty, true);
      }
    });

    test('can search doctors by specialization', () async {
      final all = await doctorRepo.getAllDoctors();
      if (all.isNotEmpty) {
        final spec = all.first.specialization;
        final results = await doctorRepo.getDoctorsBySpecialization(spec);
        expect(results.isNotEmpty, true);
      }
    });

    test('can get patient appointments', () async {
      final appointments =
          await appointmentRepo.getAppointmentsByPatient('P001');
      for (var a in appointments) {
        expect(a.patient.patientID, 'P001');
      }
    });

    test('can get doctor appointments', () async {
      final appointments =
          await appointmentRepo.getAppointmentsByDoctor('D001');
      for (var a in appointments) {
        expect(a.doctor.staffID, 'D001');
      }
    });

    test('can filter patients by blood type', () async {
      final patients = await patientRepo.getPatientsByBloodType('O+');
      for (var p in patients) {
        expect(p.bloodType, 'O+');
      }
    });
  });
}
