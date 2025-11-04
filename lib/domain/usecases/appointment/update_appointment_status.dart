import '../../entities/appointment.dart';
import '../../entities/enums/appointment_status.dart';
import '../../repositories/appointment_repository.dart';
import '../base/use_case.dart';

/// Input for updating appointment status
class UpdateAppointmentStatusInput {
  final String appointmentId;
  final String newStatus;
  final String? notes;
  final String? updatedBy;

  UpdateAppointmentStatusInput({
    required this.appointmentId,
    required this.newStatus,
    this.notes,
    this.updatedBy,
  });
}

/// Result of status update
class UpdateAppointmentStatusResult {
  final Appointment appointment;
  final String previousStatus;
  final String newStatus;
  final DateTime updatedAt;
  final bool statusTransitionValid;

  UpdateAppointmentStatusResult({
    required this.appointment,
    required this.previousStatus,
    required this.newStatus,
    required this.updatedAt,
    required this.statusTransitionValid,
  });

  @override
  String toString() {
    return '''
📊 Status Updated
Appointment: ${appointment.id}
Status: ${appointment.status}
Updated: ${updatedAt.toString().split('.')[0]}
''';
  }
}

/// Use case for updating appointment status through lifecycle
/// Tracks appointment progression: SCHEDULED → CONFIRMED → IN_PROGRESS → COMPLETED
class UpdateAppointmentStatus extends UseCase<UpdateAppointmentStatusInput,
    UpdateAppointmentStatusResult> {
  final AppointmentRepository appointmentRepository;

  UpdateAppointmentStatus({required this.appointmentRepository});

  @override
  Future<bool> validate(UpdateAppointmentStatusInput input) async {
    // Validate status value
    final validStatuses = [
      'SCHEDULED',
      'CONFIRMED',
      'IN_PROGRESS',
      'COMPLETED',
      'CANCELLED',
      'NO_SHOW',
      'RESCHEDULED',
    ];

    if (!validStatuses.contains(input.newStatus.toUpperCase())) {
      throw UseCaseValidationException(
        'Invalid status. Must be one of: ${validStatuses.join(", ")}',
      );
    }
    return true;
  }

  @override
  Future<UpdateAppointmentStatusResult> execute(
      UpdateAppointmentStatusInput input) async {
    // Get appointment
    final appointment =
        await appointmentRepository.getAppointmentById(input.appointmentId);

    final previousStatus = appointment.status;

    // Parse new status
    AppointmentStatus newStatusEnum;
    try {
      newStatusEnum = AppointmentStatus.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toUpperCase() ==
            input.newStatus.toUpperCase(),
      );
    } catch (e) {
      throw UseCaseValidationException(
        'Invalid appointment status: ${input.newStatus}',
      );
    }

    // Create timestamp note
    final updatedAt = DateTime.now();

    // Update appointment status
    appointment.updateStatus(newStatusEnum);

    await appointmentRepository.updateAppointment(appointment);

    return UpdateAppointmentStatusResult(
      appointment: appointment,
      previousStatus: previousStatus.toString().split('.').last,
      newStatus: newStatusEnum.toString().split('.').last,
      updatedAt: updatedAt,
      statusTransitionValid: true,
    );
  }

  @override
  Future<void> onSuccess(UpdateAppointmentStatusResult result,
      UpdateAppointmentStatusInput input) async {
    print(
        '✓ Appointment status updated: ${result.previousStatus} → ${result.newStatus}');

    // Special handling for completed appointments
    if (result.newStatus == 'COMPLETED') {
      print('   ✅ Appointment completed successfully');
    }

    // Alert for no-shows
    if (result.newStatus == 'NO_SHOW') {
      print('   ⚠️ Patient did not show up for appointment');
    }
  }
}
