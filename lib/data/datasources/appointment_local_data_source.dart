import 'local/json_data_source.dart';
import '../models/appointment_model.dart';

/// Local data source for Appointment entity
/// Provides specialized queries for appointment data
class AppointmentLocalDataSource extends JsonDataSource<AppointmentModel> {
  AppointmentLocalDataSource()
      : super(
          fileName: 'appointments.json',
          fromJson: AppointmentModel.fromJson,
        );

  /// Find an appointment by ID
  Future<AppointmentModel?> findByAppointmentId(String appointmentId) {
    return findById(appointmentId, (appointment) => appointment.id,
        (appointment) => appointment.toJson());
  }

  /// Check if an appointment exists
  Future<bool> appointmentExists(String appointmentId) {
    return exists(appointmentId, (appointment) => appointment.id);
  }

  /// Find appointments by patient ID
  Future<List<AppointmentModel>> findAppointmentsByPatientId(String patientId) {
    return findWhere((appointment) => appointment.patientId == patientId);
  }

  /// Find appointments by doctor ID
  Future<List<AppointmentModel>> findAppointmentsByDoctorId(String doctorId) {
    return findWhere((appointment) => appointment.doctorId == doctorId);
  }

  /// Find appointments by date (specific day)
  Future<List<AppointmentModel>> findAppointmentsByDate(DateTime date) async {
    final targetDate = DateTime(date.year, date.month, date.day);

    return findWhere((appointment) {
      final appointmentDate = DateTime.parse(appointment.dateTime);
      final appointmentDay = DateTime(
          appointmentDate.year, appointmentDate.month, appointmentDate.day);
      return appointmentDay.isAtSameMomentAs(targetDate);
    });
  }

  /// Find appointments by doctor and specific date
  Future<List<AppointmentModel>> findAppointmentsByDoctorAndDate(
    String doctorId,
    DateTime date,
  ) async {
    final targetDate = DateTime(date.year, date.month, date.day);

    return findWhere((appointment) {
      if (appointment.doctorId != doctorId) return false;

      final appointmentDate = DateTime.parse(appointment.dateTime);
      final appointmentDay = DateTime(
          appointmentDate.year, appointmentDate.month, appointmentDate.day);
      return appointmentDay.isAtSameMomentAs(targetDate);
    });
  }

  /// Find appointments by status
  Future<List<AppointmentModel>> findAppointmentsByStatus(String status) {
    return findWhere((appointment) => appointment.status.contains(status));
  }

  /// Find upcoming appointments (future appointments)
  Future<List<AppointmentModel>> findUpcomingAppointments() {
    final now = DateTime.now();

    return findWhere((appointment) {
      final appointmentDate = DateTime.parse(appointment.dateTime);
      return appointmentDate.isAfter(now);
    });
  }

  /// Find appointments within a specific time range for conflict detection
  Future<List<AppointmentModel>> findAppointmentsInTimeRange(
    DateTime startTime,
    DateTime endTime,
  ) {
    return findWhere((appointment) {
      final appointmentStart = DateTime.parse(appointment.dateTime);
      final appointmentEnd =
          appointmentStart.add(Duration(minutes: appointment.duration));

      // Check if there's any overlap between the ranges
      return (appointmentStart.isBefore(endTime) &&
          appointmentEnd.isAfter(startTime));
    });
  }

  /// Find doctor appointments that conflict with a specific time period
  Future<List<AppointmentModel>> findDoctorConflictingAppointments(
    String doctorId,
    DateTime startTime,
    int durationMinutes,
  ) {
    final endTime = startTime.add(Duration(minutes: durationMinutes));

    return findWhere((appointment) {
      if (appointment.doctorId != doctorId) return false;

      final appointmentStart = DateTime.parse(appointment.dateTime);
      final appointmentEnd =
          appointmentStart.add(Duration(minutes: appointment.duration));

      // Check for time overlap
      return (startTime.isBefore(appointmentEnd) &&
          endTime.isAfter(appointmentStart));
    });
  }

  /// Find patient appointments that conflict with a specific time period
  Future<List<AppointmentModel>> findPatientConflictingAppointments(
    String patientId,
    DateTime startTime,
    int durationMinutes,
  ) {
    final endTime = startTime.add(Duration(minutes: durationMinutes));

    return findWhere((appointment) {
      if (appointment.patientId != patientId) return false;

      final appointmentStart = DateTime.parse(appointment.dateTime);
      final appointmentEnd =
          appointmentStart.add(Duration(minutes: appointment.duration));

      // Check for time overlap
      return (startTime.isBefore(appointmentEnd) &&
          endTime.isAfter(appointmentStart));
    });
  }

  /// Find appointments by multiple appointment IDs
  Future<List<AppointmentModel>> findAppointmentsByIds(
      List<String> appointmentIds) async {
    if (appointmentIds.isEmpty) return [];

    final allAppointments = await readAll();
    return allAppointments
        .where((appointment) => appointmentIds.contains(appointment.id))
        .toList();
  }
}
