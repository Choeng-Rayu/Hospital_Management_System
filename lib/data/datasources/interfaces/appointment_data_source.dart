import '../../models/appointment_model.dart';

/// Abstract interface for Appointment data source operations
abstract class AppointmentDataSource {
  /// Read all appointments
  Future<List<AppointmentModel>> readAll();

  /// Add a new appointment
  Future<void> add(
    AppointmentModel appointment,
    String Function(AppointmentModel) getId,
    Map<String, dynamic> Function(AppointmentModel) toJson,
  );

  /// Update an existing appointment
  Future<void> update(
    String id,
    AppointmentModel appointment,
    String Function(AppointmentModel) getId,
    Map<String, dynamic> Function(AppointmentModel) toJson,
  );

  /// Delete an appointment
  Future<void> delete(
    String id,
    String Function(AppointmentModel) getId,
    Map<String, dynamic> Function(AppointmentModel) toJson,
  );

  /// Find an appointment by ID
  Future<AppointmentModel?> findByAppointmentId(String appointmentId);

  /// Check if an appointment exists
  Future<bool> appointmentExists(String appointmentId);

  /// Find appointments by patient ID
  Future<List<AppointmentModel>> findAppointmentsByPatientId(String patientId);

  /// Find appointments by doctor ID
  Future<List<AppointmentModel>> findAppointmentsByDoctorId(String doctorId);

  /// Find appointments by date (specific day)
  Future<List<AppointmentModel>> findAppointmentsByDate(DateTime date);

  /// Find appointments by doctor and specific date
  Future<List<AppointmentModel>> findAppointmentsByDoctorAndDate(
    String doctorId,
    DateTime date,
  );

  /// Find appointments by status
  Future<List<AppointmentModel>> findAppointmentsByStatus(String status);

  /// Find upcoming appointments (future appointments)
  Future<List<AppointmentModel>> findUpcomingAppointments();

  /// Find appointments within a specific time range for conflict detection
  Future<List<AppointmentModel>> findAppointmentsInTimeRange(
    DateTime startTime,
    DateTime endTime,
  );

  /// Find doctor appointments that conflict with a specific time period
  Future<List<AppointmentModel>> findDoctorConflictingAppointments(
    String doctorId,
    DateTime startTime,
    int durationMinutes,
  );

  /// Find patient appointments that conflict with a specific time period
  Future<List<AppointmentModel>> findPatientConflictingAppointments(
    String patientId,
    DateTime startTime,
    int durationMinutes,
  );

  /// Find appointments by multiple appointment IDs
  Future<List<AppointmentModel>> findAppointmentsByIds(
      List<String> appointmentIds);
}
