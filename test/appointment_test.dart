import 'package:test/test.dart';
import 'package:hospital_management/data/repositories/appointment_repository_impl.dart';
import 'package:hospital_management/data/repositories/patient_repository_impl.dart';
import 'package:hospital_management/data/repositories/doctor_repository_impl.dart';
import 'package:hospital_management/data/datasources/local/appointment_local_data_source.dart';
import 'package:hospital_management/data/datasources/local/patient_local_data_source.dart';
import 'package:hospital_management/data/datasources/local/doctor_local_data_source.dart';
import 'package:hospital_management/domain/entities/appointment.dart';
import 'package:hospital_management/domain/entities/enums/appointment_status.dart';

void main() {
  late AppointmentRepositoryImpl appointmentRepo;
  late PatientRepositoryImpl patientRepo;
  late DoctorRepositoryImpl doctorRepo;
  final testIds = <String>[];

  setUp(() {
    appointmentRepo = AppointmentRepositoryImpl(
      appointmentDataSource: AppointmentLocalDataSource(),
      patientDataSource: PatientLocalDataSource(),
      doctorDataSource: DoctorLocalDataSource(),
    );
    patientRepo = PatientRepositoryImpl(
      patientDataSource: PatientLocalDataSource(),
      doctorDataSource: DoctorLocalDataSource(),
    );
    doctorRepo = DoctorRepositoryImpl(
      doctorDataSource: DoctorLocalDataSource(),
      patientDataSource: PatientLocalDataSource(),
    );
  });

  tearDown(() async {
    for (var id in testIds) {
      try {
        await appointmentRepo.deleteAppointment(id);
      } catch (e) {}
    }
    testIds.clear();
  });

  group('Appointment Operations', () {
    test('can create appointment', () async {
      final patient = await patientRepo.getPatientById('P001');
      final doctor = await doctorRepo.getDoctorById('D001');
      final futureDate = DateTime.now().add(Duration(days: 3));
      final appointmentTime =
          DateTime(futureDate.year, futureDate.month, futureDate.day, 10, 0);

      final appointment = Appointment(
        id: 'AUTO',
        dateTime: appointmentTime,
        duration: 30,
        patient: patient,
        doctor: doctor,
        status: AppointmentStatus.SCHEDULE,
        reason: 'Checkup',
      );

      await appointmentRepo.saveAppointment(appointment);
      final all = await appointmentRepo.getAllAppointments();
      final created = all.firstWhere(
          (a) => a.patient.patientID == 'P001' && a.reason == 'Checkup');
      testIds.add(created.id);

      expect(created.reason, 'Checkup');
    });

    test('can get appointments by patient', () async {
      final appointments =
          await appointmentRepo.getAppointmentsByPatient('P001');
      expect(appointments.isNotEmpty, true);
      for (var a in appointments) {
        expect(a.patient.patientID, 'P001');
      }
    });

    test('can get appointments by doctor', () async {
      final appointments =
          await appointmentRepo.getAppointmentsByDoctor('D001');
      expect(appointments.isNotEmpty, true);
      for (var a in appointments) {
        expect(a.doctor.staffID, 'D001');
      }
    });

    test('can update appointment status', () async {
      final patient = await patientRepo.getPatientById('P001');
      final doctor = await doctorRepo.getDoctorById('D001');
      final futureDate = DateTime.now().add(Duration(days: 5));
      final appointmentTime =
          DateTime(futureDate.year, futureDate.month, futureDate.day, 14, 0);

      final appointment = Appointment(
        id: 'AUTO',
        dateTime: appointmentTime,
        duration: 60,
        patient: patient,
        doctor: doctor,
        status: AppointmentStatus.SCHEDULE,
        reason: 'Status Test',
      );

      await appointmentRepo.saveAppointment(appointment);
      final all = await appointmentRepo.getAllAppointments();
      final created = all.firstWhere((a) => a.reason == 'Status Test');
      testIds.add(created.id);

      final updated = Appointment(
        id: created.id,
        dateTime: created.dateTime,
        duration: created.duration,
        patient: created.patient,
        doctor: created.doctor,
        status: AppointmentStatus.COMPLETED,
        reason: created.reason,
      );

      await appointmentRepo.updateAppointment(updated);
      final retrieved = await appointmentRepo.getAppointmentById(created.id);
      expect(retrieved.status, AppointmentStatus.COMPLETED);
    });
  });
}
