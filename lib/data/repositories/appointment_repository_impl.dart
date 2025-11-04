import '../../domain/repositories/appointment_repository.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/enums/appointment_status.dart';
import '../../domain/entities/room.dart';
import '../datasources/appointment_local_data_source.dart';
import '../datasources/patient_local_data_source.dart';
import '../datasources/doctor_local_data_source.dart';
import '../datasources/id_generator.dart';
import '../models/appointment_model.dart';

/// Implementation of AppointmentRepository using local JSON data sources
class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentLocalDataSource _appointmentDataSource;
  final PatientLocalDataSource _patientDataSource;
  final DoctorLocalDataSource _doctorDataSource;

  AppointmentRepositoryImpl({
    required AppointmentLocalDataSource appointmentDataSource,
    required PatientLocalDataSource patientDataSource,
    required DoctorLocalDataSource doctorDataSource,
  })  : _appointmentDataSource = appointmentDataSource,
        _patientDataSource = patientDataSource,
        _doctorDataSource = doctorDataSource;

  @override
  Future<Appointment> getAppointmentById(String appointmentId) async {
    final model =
        await _appointmentDataSource.findByAppointmentId(appointmentId);
    if (model == null) {
      throw Exception('Appointment with ID $appointmentId not found');
    }

    return await _convertModelToEntity(model);
  }

  @override
  Future<List<Appointment>> getAllAppointments() async {
    final models = await _appointmentDataSource.readAll();
    final List<Appointment> appointments = [];

    for (final model in models) {
      appointments.add(await _convertModelToEntity(model));
    }

    return appointments;
  }

  @override
  Future<void> saveAppointment(Appointment appointment) async {
    String appointmentId = appointment.id;

    // Auto-generate ID if it's a placeholder or empty
    if (appointmentId.isEmpty ||
        appointmentId == 'AUTO' ||
        appointmentId == 'A000' ||
        appointmentId == 'A001') {
      // Read all existing appointments to generate next ID
      final allAppointments = await _appointmentDataSource.readAll();
      final allAppointmentsJson =
          allAppointments.map((a) => a.toJson()).toList();

      // Generate next available ID
      appointmentId = IdGenerator.generateAppointmentId(allAppointmentsJson);

      // Create new appointment instance with generated ID
      appointment = Appointment(
        id: appointmentId,
        dateTime: appointment.dateTime,
        duration: appointment.duration,
        patient: appointment.patient,
        doctor: appointment.doctor,
        room: appointment.room,
        status: appointment.status,
        reason: appointment.reason,
        notes: appointment.notes,
      );
    }

    final model = AppointmentModel.fromEntity(appointment);

    // Check if appointment exists
    final exists =
        await _appointmentDataSource.appointmentExists(appointmentId);

    if (exists) {
      throw Exception(
          'Appointment with ID $appointmentId already exists. Use updateAppointment() to modify existing appointments.');
    } else {
      await _appointmentDataSource.add(
        model,
        (a) => a.id,
        (a) => a.toJson(),
      );
    }
  }

  @override
  Future<void> updateAppointment(Appointment appointment) async {
    final model = AppointmentModel.fromEntity(appointment);

    // Check if appointment exists
    final exists =
        await _appointmentDataSource.appointmentExists(appointment.id);

    if (!exists) {
      throw Exception(
          'Appointment with ID ${appointment.id} not found for update');
    }

    await _appointmentDataSource.update(
      appointment.id,
      model,
      (a) => a.id,
      (a) => a.toJson(),
    );
  }

  @override
  Future<void> deleteAppointment(String appointmentId) async {
    await _appointmentDataSource.delete(
      appointmentId,
      (a) => a.id,
      (a) => a.toJson(),
    );
  }

  @override
  Future<List<Appointment>> getAppointmentsByPatient(String patientId) async {
    final models =
        await _appointmentDataSource.findAppointmentsByPatientId(patientId);
    final List<Appointment> appointments = [];

    for (final model in models) {
      appointments.add(await _convertModelToEntity(model));
    }

    return appointments;
  }

  @override
  Future<List<Appointment>> getAppointmentsByDoctor(String doctorId) async {
    final models =
        await _appointmentDataSource.findAppointmentsByDoctorId(doctorId);
    final List<Appointment> appointments = [];

    for (final model in models) {
      appointments.add(await _convertModelToEntity(model));
    }

    return appointments;
  }

  @override
  Future<List<Appointment>> getAppointmentsByDate(DateTime date) async {
    final models = await _appointmentDataSource.findAppointmentsByDate(date);
    final List<Appointment> appointments = [];

    for (final model in models) {
      appointments.add(await _convertModelToEntity(model));
    }

    return appointments;
  }

  @override
  Future<List<Appointment>> getAppointmentsByDoctorAndDate(
    String doctorId,
    DateTime date,
  ) async {
    final models = await _appointmentDataSource.findAppointmentsByDoctorAndDate(
        doctorId, date);
    final List<Appointment> appointments = [];

    for (final model in models) {
      appointments.add(await _convertModelToEntity(model));
    }

    return appointments;
  }

  @override
  Future<List<Appointment>> getAppointmentsByStatus(
      AppointmentStatus status) async {
    final statusString = status.toString();
    final models =
        await _appointmentDataSource.findAppointmentsByStatus(statusString);
    final List<Appointment> appointments = [];

    for (final model in models) {
      appointments.add(await _convertModelToEntity(model));
    }

    return appointments;
  }

  @override
  Future<List<Appointment>> getUpcomingAppointments() async {
    final models = await _appointmentDataSource.findUpcomingAppointments();
    final List<Appointment> appointments = [];

    for (final model in models) {
      appointments.add(await _convertModelToEntity(model));
    }

    return appointments;
  }

  @override
  Future<bool> appointmentExists(String appointmentId) async {
    return await _appointmentDataSource.appointmentExists(appointmentId);
  }

  // Conflict detection methods

  @override
  Future<bool> hasDoctorConflict(
    String doctorId,
    DateTime startTime,
    int durationMinutes,
  ) async {
    final conflictingModels =
        await _appointmentDataSource.findDoctorConflictingAppointments(
      doctorId,
      startTime,
      durationMinutes,
    );

    return conflictingModels.isNotEmpty;
  }

  @override
  Future<List<Appointment>> getDoctorAppointmentsInTimeRange(
    String doctorId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    final models = await _appointmentDataSource.findAppointmentsInTimeRange(
        startTime, endTime);
    final doctorModels =
        models.where((model) => model.doctorId == doctorId).toList();

    final List<Appointment> appointments = [];
    for (final model in doctorModels) {
      appointments.add(await _convertModelToEntity(model));
    }

    return appointments;
  }

  @override
  Future<bool> hasPatientConflict(
    String patientId,
    DateTime startTime,
    int durationMinutes,
  ) async {
    final conflictingModels =
        await _appointmentDataSource.findPatientConflictingAppointments(
      patientId,
      startTime,
      durationMinutes,
    );

    return conflictingModels.isNotEmpty;
  }

  @override
  Future<List<Appointment>> getConflictingAppointments(
    String doctorId,
    DateTime startTime,
    int durationMinutes,
  ) async {
    final conflictingModels =
        await _appointmentDataSource.findDoctorConflictingAppointments(
      doctorId,
      startTime,
      durationMinutes,
    );

    final List<Appointment> appointments = [];
    for (final model in conflictingModels) {
      appointments.add(await _convertModelToEntity(model));
    }

    return appointments;
  }

  /// Helper method to convert AppointmentModel to Appointment entity
  Future<Appointment> _convertModelToEntity(AppointmentModel model) async {
    // Fetch patient
    final patientModel =
        await _patientDataSource.findByPatientID(model.patientId);
    if (patientModel == null) {
      throw Exception('Patient with ID ${model.patientId} not found');
    }

    // Fetch assigned doctors for patient
    final assignedDoctorModels = await _doctorDataSource
        .findDoctorsByIds(patientModel.assignedDoctorIds);
    final assignedDoctors =
        assignedDoctorModels.map((dm) => dm.toEntity()).toList();
    final patient = patientModel.toEntity(assignedDoctors: assignedDoctors);

    // Fetch doctor
    final doctorModel = await _doctorDataSource.findByStaffID(model.doctorId);
    if (doctorModel == null) {
      throw Exception('Doctor with ID ${model.doctorId} not found');
    }
    final doctor = doctorModel.toEntity();

    // Room is optional - we'll skip it for now since we don't have room data source
    Room? room;

    return model.toEntity(
      patient: patient,
      doctor: doctor,
      room: room,
    );
  }
}
