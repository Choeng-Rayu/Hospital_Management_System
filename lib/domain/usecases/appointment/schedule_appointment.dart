import '../../entities/appointment.dart';
import '../../entities/enums/appointment_status.dart';
import '../../repositories/appointment_repository.dart';
import '../../repositories/patient_repository.dart';
import '../../repositories/doctor_repository.dart';
import '../../repositories/room_repository.dart';

/// Use case for scheduling a new appointment
/// Handles validation and conflict checking
class ScheduleAppointment {
  final AppointmentRepository appointmentRepository;
  final PatientRepository patientRepository;
  final DoctorRepository doctorRepository;
  final RoomRepository roomRepository;

  ScheduleAppointment({
    required this.appointmentRepository,
    required this.patientRepository,
    required this.doctorRepository,
    required this.roomRepository,
  });

  /// Execute appointment scheduling
  ///
  /// Steps:
  /// 1. Validate patient exists
  /// 2. Validate doctor exists
  /// 3. Check doctor availability
  /// 4. Check for scheduling conflicts
  /// 5. Optionally assign room
  /// 6. Create and save appointment
  Future<Appointment> execute({
    required String appointmentId,
    required String patientId,
    required String doctorId,
    required DateTime dateTime,
    required int duration,
    required String reason,
    String? roomId,
    String? notes,
  }) async {
    // 1. Validate patient exists
    final patient = await patientRepository.getPatientById(patientId);

    // 2. Validate doctor exists
    final doctor = await doctorRepository.getDoctorById(doctorId);

    // 3. Check if appointment time is in the future
    if (dateTime.isBefore(DateTime.now())) {
      throw InvalidAppointmentTimeException(
        'Appointment time must be in the future',
      );
    }

    // 4. Check for doctor schedule conflicts
    final existingAppointments = await appointmentRepository
        .getAppointmentsByDoctorAndDate(doctorId, dateTime);

    if (_hasTimeConflict(existingAppointments, dateTime, duration)) {
      throw AppointmentConflictException(
        'Doctor has a conflicting appointment at this time',
      );
    }

    // 5. Get room if specified
    final room =
        roomId != null ? await roomRepository.getRoomById(roomId) : null;

    // 6. Create appointment
    final appointment = Appointment(
      id: appointmentId,
      dateTime: dateTime,
      duration: duration,
      patient: patient,
      doctor: doctor,
      room: room,
      status: AppointmentStatus.SCHEDULE,
      reason: reason,
      notes: notes,
    );

    // 7. Save appointment
    await appointmentRepository.saveAppointment(appointment);

    return appointment;
  }

  /// Check if there's a time conflict with existing appointments
  bool _hasTimeConflict(
    List<Appointment> existingAppointments,
    DateTime newStart,
    int newDuration,
  ) {
    final newEnd = newStart.add(Duration(minutes: newDuration));

    for (final appointment in existingAppointments) {
      final existingStart = appointment.dateTime;
      final existingEnd = existingStart.add(
        Duration(minutes: appointment.duration),
      );

      // Check if times overlap
      if ((newStart.isBefore(existingEnd) && newEnd.isAfter(existingStart)) ||
          newStart.isAtSameMomentAs(existingStart)) {
        return true;
      }
    }

    return false;
  }
}

// Custom exceptions
class InvalidAppointmentTimeException implements Exception {
  final String message;
  InvalidAppointmentTimeException(this.message);
  @override
  String toString() => message;
}

class AppointmentConflictException implements Exception {
  final String message;
  AppointmentConflictException(this.message);
  @override
  String toString() => message;
}
