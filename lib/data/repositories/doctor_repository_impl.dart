import '../../domain/repositories/doctor_repository.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/entities/patient.dart';
import 'package:hospital_management/data/datasources/local/doctor_local_data_source.dart';
import 'package:hospital_management/data/datasources/local/patient_local_data_source.dart';
import '../models/doctor_model.dart';

/// Implementation of DoctorRepository using local JSON data sources
class DoctorRepositoryImpl implements DoctorRepository {
  final DoctorLocalDataSource _doctorDataSource;
  final PatientLocalDataSource _patientDataSource;
  final AppointmentRepository? _appointmentRepository;

  DoctorRepositoryImpl({
    required DoctorLocalDataSource doctorDataSource,
    required PatientLocalDataSource patientDataSource,
    AppointmentRepository? appointmentRepository,
  })  : _doctorDataSource = doctorDataSource,
        _patientDataSource = patientDataSource,
        _appointmentRepository = appointmentRepository;

  @override
  Future<Doctor> getDoctorById(String staffId) async {
    final model = await _doctorDataSource.findByStaffID(staffId);
    if (model == null) {
      throw Exception('Doctor with ID $staffId not found');
    }

    // Convert model to entity (without patients for now to avoid circular references)
    return model.toEntity();
  }

  @override
  Future<List<Doctor>> getAllDoctors() async {
    final models = await _doctorDataSource.readAll();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> saveDoctor(Doctor doctor) async {
    final model = DoctorModel.fromEntity(doctor);

    // Check if doctor exists
    final exists = await _doctorDataSource.doctorExists(doctor.staffID);

    if (exists) {
      await _doctorDataSource.update(
        doctor.staffID,
        model,
        (d) => d.staffID,
        (d) => d.toJson(),
      );
    } else {
      await _doctorDataSource.add(
        model,
        (d) => d.staffID,
        (d) => d.toJson(),
      );
    }
  }

  @override
  Future<void> updateDoctor(Doctor doctor) async {
    final model = DoctorModel.fromEntity(doctor);

    // Check if doctor exists
    final exists = await _doctorDataSource.doctorExists(doctor.staffID);

    if (!exists) {
      throw Exception('Doctor with ID ${doctor.staffID} not found for update');
    }

    await _doctorDataSource.update(
      doctor.staffID,
      model,
      (d) => d.staffID,
      (d) => d.toJson(),
    );
  }

  @override
  Future<void> deleteDoctor(String staffId) async {
    await _doctorDataSource.delete(
      staffId,
      (d) => d.staffID,
      (d) => d.toJson(),
    );
  }

  @override
  Future<List<Doctor>> searchDoctorsByName(String name) async {
    final models = await _doctorDataSource.findWhere(
      (doctor) => doctor.name.toLowerCase().contains(name.toLowerCase()),
    );
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Doctor>> getDoctorsBySpecialization(String specialization) async {
    final models =
        await _doctorDataSource.findDoctorsBySpecialization(specialization);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Doctor>> getAvailableDoctors(DateTime date) async {
    final models = await _doctorDataSource.findAvailableDoctors(date);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Patient>> getDoctorPatients(String doctorId) async {
    final patientModels =
        await _patientDataSource.findPatientsByDoctorId(doctorId);
    final List<Patient> patients = [];

    for (final patientModel in patientModels) {
      // Get assigned doctors for each patient to maintain relationships
      final assignedDoctorModels = await _doctorDataSource
          .findDoctorsByIds(patientModel.assignedDoctorIds);
      final assignedDoctors =
          assignedDoctorModels.map((dm) => dm.toEntity()).toList();

      patients.add(patientModel.toEntity(assignedDoctors: assignedDoctors));
    }

    return patients;
  }

  @override
  Future<bool> doctorExists(String staffId) async {
    return await _doctorDataSource.doctorExists(staffId);
  }

  @override
  Future<List<DateTime>> getDoctorScheduleForDate(
      String doctorId, DateTime date) async {
    final doctor = await getDoctorById(doctorId);
    final dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return doctor.getScheduleFor(dateKey);
  }

  @override
  Future<bool> isDoctorAvailableAt(
    String doctorId,
    DateTime dateTime,
    int durationMinutes,
  ) async {
    // Get doctor and their data
    final doctorModel = await _doctorDataSource.findByStaffID(doctorId);
    if (doctorModel == null) {
      throw Exception('Doctor with ID $doctorId not found');
    }

    // Step 1: Check if the requested time falls within working hours
    if (!_isWithinWorkingHours(doctorModel, dateTime, durationMinutes)) {
      return false;
    }

    // Step 2: Check for conflicts with existing meetings in domain schedule
    final doctor = doctorModel.toEntity();
    final dateKey =
        '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    final existingMeetings = doctor.getScheduleFor(dateKey);

    final requestedEnd = dateTime.add(Duration(minutes: durationMinutes));

    for (final existingMeeting in existingMeetings) {
      // Default to 30 minutes for existing meetings if no duration specified
      final existingEnd = existingMeeting.add(Duration(minutes: 30));

      // Check for overlap
      if (dateTime.isBefore(existingEnd) &&
          requestedEnd.isAfter(existingMeeting)) {
        return false; // Conflict found
      }
    }

    // Step 3: Check for conflicts with Appointment entities (if any exist)
    // TODO: Implement appointment conflict checking when appointment repository exists

    return true; // Available
  }

  @override
  Future<List<DateTime>> getAvailableTimeSlots(
    String doctorId,
    DateTime date, {
    int durationMinutes = 30,
    int startHour = 8,
    int endHour = 17,
  }) async {
    final doctorModel = await _doctorDataSource.findByStaffID(doctorId);
    if (doctorModel == null) {
      throw Exception('Doctor with ID $doctorId not found');
    }

    final List<DateTime> availableSlots = [];

    // Get working hours for this specific date
    final workingHours = _getWorkingHoursForDate(doctorModel, date);
    if (workingHours == null) {
      return []; // Doctor not working on this date
    }

    // Use actual working hours instead of default start/end hours
    final workStart = DateTime.parse(workingHours['start']!);
    final workEnd = DateTime.parse(workingHours['end']!);

    // Generate slots within working hours
    DateTime currentSlot = DateTime(
      date.year,
      date.month,
      date.day,
      workStart.hour,
      workStart.minute,
    );

    final endOfWork = DateTime(
      date.year,
      date.month,
      date.day,
      workEnd.hour,
      workEnd.minute,
    );

    while (currentSlot
            .add(Duration(minutes: durationMinutes))
            .isBefore(endOfWork) ||
        currentSlot
            .add(Duration(minutes: durationMinutes))
            .isAtSameMomentAs(endOfWork)) {
      // Only include future time slots
      if (currentSlot.isAfter(DateTime.now())) {
        // Check if this slot is available
        final isAvailable =
            await isDoctorAvailableAt(doctorId, currentSlot, durationMinutes);
        if (isAvailable) {
          availableSlots.add(currentSlot);
        }
      }

      // Move to next slot (every 30 minutes)
      currentSlot = currentSlot.add(Duration(minutes: 30));
    }

    return availableSlots;
  }

  @override
  Future<List<Doctor>> getDoctorsAvailableAt(
    DateTime dateTime,
    int durationMinutes,
  ) async {
    final allDoctors = await getAllDoctors();
    final availableDoctors = <Doctor>[];

    for (final doctor in allDoctors) {
      final isAvailable = await isDoctorAvailableAt(
        doctor.staffID,
        dateTime,
        durationMinutes,
      );
      if (isAvailable) {
        availableDoctors.add(doctor);
      }
    }

    return availableDoctors;
  }

  /// Check if the requested time falls within doctor's working hours
  bool _isWithinWorkingHours(
    DoctorModel doctorModel,
    DateTime dateTime,
    int durationMinutes,
  ) {
    final workingHours = _getWorkingHoursForDate(doctorModel, dateTime);
    if (workingHours == null) {
      return false; // Doctor not working on this date
    }

    final workStartUtc = DateTime.parse(workingHours['start']!);
    final workEndUtc = DateTime.parse(workingHours['end']!);

    // Convert working hours to the same date as the requested time
    final workStart = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      workStartUtc.hour,
      workStartUtc.minute,
    );
    final workEnd = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      workEndUtc.hour,
      workEndUtc.minute,
    );

    final requestedEnd = dateTime.add(Duration(minutes: durationMinutes));

    // Check if both start and end times fall within working hours
    return (dateTime.isAfter(workStart) ||
            dateTime.isAtSameMomentAs(workStart)) &&
        (requestedEnd.isBefore(workEnd) ||
            requestedEnd.isAtSameMomentAs(workEnd));
  }

  /// Get working hours for a specific date
  Map<String, String>? _getWorkingHoursForDate(
      DoctorModel doctorModel, DateTime date) {
    // Try different date key formats
    final possibleKeys = [
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      _getDayName(date.weekday),
    ];

    for (final key in possibleKeys) {
      final workingHours = doctorModel.schedule[key];
      if (workingHours != null) {
        return workingHours;
      }
    }

    return null; // No working hours found for this date
  }

  /// Convert weekday number to day name
  String _getDayName(int weekday) {
    const dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return dayNames[weekday - 1];
  }

  @override
  Future<bool> isDoctorFullyAvailable(
    String doctorId,
    DateTime dateTime,
    int durationMinutes,
  ) async {
    // Step 1: Check basic availability (working hours + meeting conflicts)
    final isBasicallyAvailable =
        await isDoctorAvailableAt(doctorId, dateTime, durationMinutes);
    if (!isBasicallyAvailable) {
      return false;
    }

    // Step 2: Check appointment conflicts if appointment repository is available
    if (_appointmentRepository != null) {
      final hasAppointmentConflict =
          await _appointmentRepository!.hasDoctorConflict(
        doctorId,
        dateTime,
        durationMinutes,
      );
      if (hasAppointmentConflict) {
        return false; // Appointment conflict found
      }
    }

    return true; // Fully available
  }
}
