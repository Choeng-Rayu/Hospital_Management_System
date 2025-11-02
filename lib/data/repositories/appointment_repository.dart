import 'package:hospital_management/domain/entities/appointment.dart';
import '../datasources/local/appointment_data_source.dart';

abstract class AppointmentRepository {
  Future<Appointment> getAppointmentById(String id);
  Future<List<Appointment>> getAllAppointments();
  Future<void> saveAppointment(Appointment appointment);
  Future<void> updateAppointment(Appointment appointment);
  Future<void> deleteAppointment(String id);
  Future<bool> appointmentExists(String id);
  Future<List<Appointment>> getAppointmentsByPatientId(String patientId);
  Future<List<Appointment>> getAppointmentsByDoctorId(String doctorId);
  Future<List<Appointment>> getAppointmentsByDate(DateTime date);
}

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentDataSource _dataSource;

  AppointmentRepositoryImpl(this._dataSource);

  @override
  Future<Appointment> getAppointmentById(String id) {
    return _dataSource.getAppointmentById(id);
  }

  @override
  Future<List<Appointment>> getAllAppointments() {
    return _dataSource.getAllAppointments();
  }

  @override
  Future<void> saveAppointment(Appointment appointment) {
    return _dataSource.saveAppointment(appointment);
  }

  @override
  Future<void> updateAppointment(Appointment appointment) {
    return _dataSource.updateAppointment(appointment);
  }

  @override
  Future<void> deleteAppointment(String id) {
    return _dataSource.deleteAppointment(id);
  }

  @override
  Future<bool> appointmentExists(String id) {
    return _dataSource.appointmentExists(id);
  }

  @override
  Future<List<Appointment>> getAppointmentsByPatientId(String patientId) {
    return _dataSource.getAppointmentsByPatientId(patientId);
  }

  @override
  Future<List<Appointment>> getAppointmentsByDoctorId(String doctorId) {
    return _dataSource.getAppointmentsByDoctorId(doctorId);
  }

  @override
  Future<List<Appointment>> getAppointmentsByDate(DateTime date) {
    return _dataSource.getAppointmentsByDate(date);
  }
}
