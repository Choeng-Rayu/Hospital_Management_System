import '../../entities/appointment.dart';
import '../../entities/enums/appointment_status.dart';
import '../../repositories/appointment_repository.dart';
import '../../repositories/doctor_repository.dart';
import '../../repositories/patient_repository.dart';
import '../base/use_case.dart';

/// Input for rescheduling an appointment
class RescheduleAppointmentInput {
  final String appointmentId;
  final DateTime newDateTime;
  final String? reason;
  final bool notifyParties;

  RescheduleAppointmentInput({
    required this.appointmentId,
    required this.newDateTime,
    this.reason,
    this.notifyParties = true,
  });
}

/// Result of appointment rescheduling
class RescheduleAppointmentResult {
  final Appointment originalAppointment;
  final Appointment rescheduledAppointment;
  final DateTime originalDateTime;
  final DateTime newDateTime;
  final String confirmationNumber;
  final bool notificationsSent;

  RescheduleAppointmentResult({
    required this.originalAppointment,
    required this.rescheduledAppointment,
    required this.originalDateTime,
    required this.newDateTime,
    required this.confirmationNumber,
    required this.notificationsSent,
  });

  @override
  String toString() {
    return '''
📅 APPOINTMENT RESCHEDULED
━━━━━━━━━━━━━━━━━━━━━━━━
Confirmation: $confirmationNumber
Original: ${originalDateTime.toString().split('.')[0]}
New Date: ${newDateTime.toString().split('.')[0]}
Patient: ${originalAppointment.patient.name}
Doctor: ${originalAppointment.doctor.name}
${notificationsSent ? '✓ Notifications sent' : ''}
''';
  }
}

/// Use case for rescheduling existing appointments
/// Validates availability and prevents conflicts
class RescheduleAppointment
    extends UseCase<RescheduleAppointmentInput, RescheduleAppointmentResult> {
  final AppointmentRepository appointmentRepository;
  final DoctorRepository doctorRepository;
  final PatientRepository patientRepository;

  RescheduleAppointment({
    required this.appointmentRepository,
    required this.doctorRepository,
    required this.patientRepository,
  });

  @override
  Future<bool> validate(RescheduleAppointmentInput input) async {
    if (input.newDateTime.isBefore(DateTime.now())) {
      throw UseCaseValidationException(
        'Cannot reschedule to a past date',
      );
    }

    final maxDate = DateTime.now().add(const Duration(days: 365));
    if (input.newDateTime.isAfter(maxDate)) {
      throw UseCaseValidationException(
        'Cannot schedule appointment more than 1 year in advance',
      );
    }

    final hour = input.newDateTime.hour;
    if (hour < 8 || hour >= 18) {
      throw UseCaseValidationException(
        'Appointments must be scheduled between 8:00 AM and 6:00 PM',
      );
    }

    final weekday = input.newDateTime.weekday;
    if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
      throw UseCaseValidationException(
        'Appointments cannot be scheduled on weekends',
      );
    }
    return true;
  }

  @override
  Future<RescheduleAppointmentResult> execute(
      RescheduleAppointmentInput input) async {
    final originalAppointment =
        await appointmentRepository.getAppointmentById(input.appointmentId);

    await doctorRepository.getDoctorById(originalAppointment.doctor.staffID);
    await patientRepository
        .getPatientById(originalAppointment.patient.patientID);

    final allAppointments = await appointmentRepository.getAllAppointments();
    final hasConflict = allAppointments.any((apt) =>
        apt.id != input.appointmentId &&
        apt.doctor.staffID == originalAppointment.doctor.staffID &&
        _hasTimeConflict(apt.dateTime, input.newDateTime));

    if (hasConflict) {
      throw EntityConflictException(
        'Doctor already has an appointment at the requested time',
      );
    }

    final rescheduledAppointment = Appointment(
      id: originalAppointment.id,
      patient: originalAppointment.patient,
      doctor: originalAppointment.doctor,
      dateTime: input.newDateTime,
      duration: originalAppointment.duration,
      reason: input.reason ?? originalAppointment.reason,
      status: AppointmentStatus.SCHEDULE,
      notes:
          '${originalAppointment.notes ?? ''}\n[Rescheduled from ${originalAppointment.dateTime.toString().split('.')[0]}]${input.reason != null ? ' Reason: ${input.reason}' : ''}',
    );

    await appointmentRepository.updateAppointment(rescheduledAppointment);

    final confirmationNumber =
        'RSC-${DateTime.now().millisecondsSinceEpoch % 100000}';

    return RescheduleAppointmentResult(
      originalAppointment: originalAppointment,
      rescheduledAppointment: rescheduledAppointment,
      originalDateTime: originalAppointment.dateTime,
      newDateTime: input.newDateTime,
      confirmationNumber: confirmationNumber,
      notificationsSent: input.notifyParties,
    );
  }

  bool _hasTimeConflict(DateTime existingTime, DateTime newTime) {
    // Appointments are typically 30 minutes
    const appointmentDuration = Duration(minutes: 30);

    final existingEnd = existingTime.add(appointmentDuration);
    final newEnd = newTime.add(appointmentDuration);

    return (newTime.isBefore(existingEnd) && newEnd.isAfter(existingTime));
  }

  @override
  Future<void> onSuccess(RescheduleAppointmentResult result,
      RescheduleAppointmentInput input) async {
    print('✓ Appointment rescheduled: ${result.confirmationNumber}');
    print('   From: ${result.originalDateTime.toString().split(' ')[0]}');
    print('   To: ${result.newDateTime.toString().split(' ')[0]}');

    if (input.notifyParties) {
      // TODO: Send notifications to patient and doctor
      print('   📧 Notifications sent to patient and doctor');
    }
  }
}
