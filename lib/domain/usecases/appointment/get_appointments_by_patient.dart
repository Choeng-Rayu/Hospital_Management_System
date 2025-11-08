import '../../entities/appointment.dart';
import '../../entities/enums/appointment_status.dart';
import '../../repositories/appointment_repository.dart';
import '../../repositories/patient_repository.dart';
import '../base/use_case.dart';

/// Input for getting patient appointments
class GetAppointmentsByPatientInput {
  final String patientId;
  final bool includeHistory;
  final bool includeUpcoming;
  final String? statusFilter;

  GetAppointmentsByPatientInput({
    required this.patientId,
    this.includeHistory = true,
    this.includeUpcoming = true,
    this.statusFilter,
  });
}

/// Patient appointments summary
class PatientAppointmentsSummary {
  final String patientId;
  final String patientName;
  final List<Appointment> upcomingAppointments;
  final List<Appointment> pastAppointments;
  final int totalAppointments;
  final int completedCount;
  final int cancelledCount;
  final int noShowCount;
  final Appointment? nextAppointment;
  final Appointment? lastAppointment;

  PatientAppointmentsSummary({
    required this.patientId,
    required this.patientName,
    required this.upcomingAppointments,
    required this.pastAppointments,
    required this.totalAppointments,
    required this.completedCount,
    required this.cancelledCount,
    required this.noShowCount,
    this.nextAppointment,
    this.lastAppointment,
  });

  @override
  String toString() {
    return '''
👤 PATIENT APPOINTMENTS
━━━━━━━━━━━━━━━━━━━━━━━━
Patient: $patientName (ID: $patientId)
Total Appointments: $totalAppointments
Completed: $completedCount
Cancelled: $cancelledCount
No-Shows: $noShowCount

${nextAppointment != null ? '⏰ Next: ${nextAppointment!.dateTime.toString().split('.')[0]}\n' : ''}${upcomingAppointments.isNotEmpty ? '📅 Upcoming (${upcomingAppointments.length}):\n${upcomingAppointments.take(5).map((a) => '   • ${a.dateTime.toString().split('.')[0]} - ${a.status}').join('\n')}' : ''}

${lastAppointment != null ? '📋 Last Visit: ${lastAppointment!.dateTime.toString().split('.')[0]}' : ''}
''';
  }
}

/// Use case for getting all appointments for a specific patient
/// Provides comprehensive patient appointment view
class GetAppointmentsByPatient
    extends UseCase<GetAppointmentsByPatientInput, PatientAppointmentsSummary> {
  final AppointmentRepository appointmentRepository;
  final PatientRepository patientRepository;

  GetAppointmentsByPatient({
    required this.appointmentRepository,
    required this.patientRepository,
  });

  @override
  Future<bool> validate(GetAppointmentsByPatientInput input) async {
    if (input.patientId.trim().isEmpty) {
      throw UseCaseValidationException('Patient ID is required');
    }

    // Must include at least one time range
    if (!input.includeHistory && !input.includeUpcoming) {
      throw UseCaseValidationException(
        'Must include either history or upcoming appointments',
      );
    }
    return true;
  }

  @override
  Future<PatientAppointmentsSummary> execute(
      GetAppointmentsByPatientInput input) async {
    final patient = await patientRepository.getPatientById(input.patientId);
    final patientName = patient.name;

    final allAppointments = await appointmentRepository.getAllAppointments();
    final patientAppointments = allAppointments
        .where((apt) => apt.patient.patientID == input.patientId)
        .toList();

    final now = DateTime.now();

    // Separate into past and upcoming
    List<Appointment> pastAppointments = [];
    List<Appointment> upcomingAppointments = [];

    for (final apt in patientAppointments) {
      if (apt.dateTime.isBefore(now)) {
        if (input.includeHistory) {
          pastAppointments.add(apt);
        }
      } else {
        if (input.includeUpcoming) {
          upcomingAppointments.add(apt);
        }
      }
    }

    if (input.statusFilter != null) {
      final filterStatus = input.statusFilter!.toUpperCase();
      pastAppointments = pastAppointments
          .where((apt) => apt.status.toString().split('.').last == filterStatus)
          .toList();
      upcomingAppointments = upcomingAppointments
          .where((apt) => apt.status.toString().split('.').last == filterStatus)
          .toList();
    }

    pastAppointments.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    upcomingAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    final completedCount = patientAppointments
        .where((apt) => apt.status == AppointmentStatus.COMPLETED)
        .length;
    final cancelledCount = patientAppointments
        .where((apt) => apt.status == AppointmentStatus.CANCELLED)
        .length;
    final noShowCount = patientAppointments
        .where((apt) => apt.status == AppointmentStatus.NO_SHOW)
        .length;

    final nextAppointment =
        upcomingAppointments.isNotEmpty ? upcomingAppointments.first : null;
    final lastAppointment =
        pastAppointments.isNotEmpty ? pastAppointments.first : null;

    return PatientAppointmentsSummary(
      patientId: input.patientId,
      patientName: patientName,
      upcomingAppointments: upcomingAppointments,
      pastAppointments: pastAppointments,
      totalAppointments: patientAppointments.length,
      completedCount: completedCount,
      cancelledCount: cancelledCount,
      noShowCount: noShowCount,
      nextAppointment: nextAppointment,
      lastAppointment: lastAppointment,
    );
  }
}
