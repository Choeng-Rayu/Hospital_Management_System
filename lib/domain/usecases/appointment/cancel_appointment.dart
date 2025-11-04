import '../../entities/enums/appointment_status.dart';
import '../../repositories/appointment_repository.dart';

/// Use case for canceling an appointment
class CancelAppointment {
  final AppointmentRepository appointmentRepository;

  CancelAppointment({required this.appointmentRepository});

  /// Execute appointment cancellation
  ///
  /// Steps:
  /// 1. Validate appointment exists
  /// 2. Check if appointment can be cancelled
  /// 3. Update appointment status
  Future<void> execute({required String appointmentId}) async {
    // 1. Get the appointment
    final appointment =
        await appointmentRepository.getAppointmentById(appointmentId);

    // 2. Check if appointment is already completed or cancelled
    if (appointment.status == AppointmentStatus.COMPLETED) {
      throw CannotCancelCompletedAppointmentException(
        'Cannot cancel a completed appointment',
      );
    }

    if (appointment.status == AppointmentStatus.CANCELLED) {
      throw AppointmentAlreadyCancelledException(
        'Appointment is already cancelled',
      );
    }

    // 3. Update status to cancelled
    appointment.updateStatus(AppointmentStatus.CANCELLED);

    // 4. Save changes
    await appointmentRepository.updateAppointment(appointment);
  }
}

// Custom exceptions
class CannotCancelCompletedAppointmentException implements Exception {
  final String message;
  CannotCancelCompletedAppointmentException(this.message);
  @override
  String toString() => message;
}

class AppointmentAlreadyCancelledException implements Exception {
  final String message;
  AppointmentAlreadyCancelledException(this.message);
  @override
  String toString() => message;
}
