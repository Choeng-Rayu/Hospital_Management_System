import '../entities/appointment.dart';
import '../entities/enums/appointment_status.dart';

/// Repository interface for Appointment entity
/// Defines all data operations needed for appointment management
abstract class AppointmentRepository {
  Future<Appointment> getAppointmentById(String appointmentId);

  Future<List<Appointment>> getAllAppointments();

  Future<void> saveAppointment(Appointment appointment);

  Future<void> updateAppointment(Appointment appointment);

  Future<void> deleteAppointment(String appointmentId);

  Future<List<Appointment>> getAppointmentsByPatient(String patientId);

  Future<List<Appointment>> getAppointmentsByDoctor(String doctorId);

  Future<List<Appointment>> getAppointmentsByDate(DateTime date);

  Future<List<Appointment>> getAppointmentsByDoctorAndDate(
    String doctorId,
    DateTime date,
  );

  Future<List<Appointment>> getAppointmentsByStatus(AppointmentStatus status);

  Future<List<Appointment>> getUpcomingAppointments();

  Future<bool> appointmentExists(String appointmentId);


  /// Check if a doctor has any appointments that conflict with the given time period
  Future<bool> hasDoctorConflict(
    String doctorId,
    DateTime startTime,
    int durationMinutes,
  );

  /// Get all appointments for a doctor within a specific time range
  Future<List<Appointment>> getDoctorAppointmentsInTimeRange(
    String doctorId,
    DateTime startTime,
    DateTime endTime,
  );

  /// Check if a patient has any appointments that conflict with the given time
  Future<bool> hasPatientConflict(
    String patientId,
    DateTime startTime,
    int durationMinutes,
  );

  /// Get conflicting appointments for a given time slot
  Future<List<Appointment>> getConflictingAppointments(
    String doctorId,
    DateTime startTime,
    int durationMinutes,
  );
}
