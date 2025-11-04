import 'package:hospital_management/domain/entities/appointment.dart';

abstract class AppointmentDataSource {
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

/// Local implementation of AppointmentDataSource that stores data in memory
class LocalAppointmentDataSource implements AppointmentDataSource {
  final Map<String, Appointment> _appointments = {};

  @override
  Future<Appointment> getAppointmentById(String id) async {
    final appointment = _appointments[id];
    if (appointment == null) {
      throw Exception('Appointment not found');
    }
    return appointment;
  }

  @override
  Future<List<Appointment>> getAllAppointments() async {
    return _appointments.values.toList();
  }

  @override
  Future<void> saveAppointment(Appointment appointment) async {
    if (_appointments.containsKey(appointment.id)) {
      throw Exception('Appointment already exists');
    }
    _appointments[appointment.id] = appointment;
  }

  @override
  Future<void> updateAppointment(Appointment appointment) async {
    if (!_appointments.containsKey(appointment.id)) {
      throw Exception('Appointment not found');
    }
    _appointments[appointment.id] = appointment;
  }

  @override
  Future<void> deleteAppointment(String id) async {
    if (!_appointments.containsKey(id)) {
      throw Exception('Appointment not found');
    }
    _appointments.remove(id);
  }

  @override
  Future<bool> appointmentExists(String id) async {
    return _appointments.containsKey(id);
  }

  @override
  Future<List<Appointment>> getAppointmentsByPatientId(String patientId) async {
    return _appointments.values
        .where((appointment) => appointment.patient.patientID == patientId)
        .toList();
  }

  @override
  Future<List<Appointment>> getAppointmentsByDoctorId(String doctorId) async {
    return _appointments.values
        .where((appointment) => appointment.doctor.staffID == doctorId)
        .toList();
  }

  @override
  Future<List<Appointment>> getAppointmentsByDate(DateTime date) async {
    return _appointments.values
        .where((appointment) =>
            appointment.dateTime.year == date.year &&
            appointment.dateTime.month == date.month &&
            appointment.dateTime.day == date.day)
        .toList();
  }
}
