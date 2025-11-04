import '../../entities/appointment.dart';
import '../../entities/enums/appointment_status.dart';
import '../../repositories/appointment_repository.dart';
import '../base/use_case.dart';

/// Input for getting appointment history
class GetAppointmentHistoryInput {
  final String? patientId;
  final String? doctorId;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? statusFilter; // 'COMPLETED', 'CANCELLED', 'RESCHEDULED'
  final int? limit;

  GetAppointmentHistoryInput({
    this.patientId,
    this.doctorId,
    this.startDate,
    this.endDate,
    this.statusFilter,
    this.limit,
  });
}

/// Appointment history entry with metadata
class AppointmentHistoryEntry {
  final Appointment appointment;
  final int daysAgo;
  final String statusDescription;
  final bool wasCompleted;
  final bool wasCancelled;
  final bool wasRescheduled;

  AppointmentHistoryEntry({
    required this.appointment,
    required this.daysAgo,
    required this.statusDescription,
    required this.wasCompleted,
    required this.wasCancelled,
    required this.wasRescheduled,
  });

  @override
  String toString() {
    final statusEmoji = wasCompleted
        ? '✓'
        : wasCancelled
            ? '✗'
            : wasRescheduled
                ? '🔄'
                : '•';
    return '$statusEmoji ${appointment.dateTime.toString().split('.')[0]} - $statusDescription ($daysAgo days ago)';
  }
}

/// Result containing appointment history
class AppointmentHistoryResult {
  final List<AppointmentHistoryEntry> history;
  final int totalAppointments;
  final int completedCount;
  final int cancelledCount;
  final int rescheduledCount;
  final String? patientName;
  final String? doctorName;

  AppointmentHistoryResult({
    required this.history,
    required this.totalAppointments,
    required this.completedCount,
    required this.cancelledCount,
    required this.rescheduledCount,
    this.patientName,
    this.doctorName,
  });

  @override
  String toString() {
    return '''
📋 APPOINTMENT HISTORY
━━━━━━━━━━━━━━━━━━━━━━━━
${patientName != null ? 'Patient: $patientName\n' : ''}${doctorName != null ? 'Doctor: $doctorName\n' : ''}Total: $totalAppointments appointments
Completed: $completedCount
Cancelled: $cancelledCount
Rescheduled: $rescheduledCount

${history.map((e) => e.toString()).join('\n')}
''';
  }
}

/// Use case for retrieving appointment history
/// Provides comprehensive historical view with filtering
class GetAppointmentHistory
    extends UseCase<GetAppointmentHistoryInput, AppointmentHistoryResult> {
  final AppointmentRepository appointmentRepository;

  GetAppointmentHistory({required this.appointmentRepository});

  @override
  Future<bool> validate(GetAppointmentHistoryInput input) async {
    // Must provide either patientId or doctorId
    if (input.patientId == null && input.doctorId == null) {
      throw UseCaseValidationException(
        'Must provide either patientId or doctorId',
      );
    }

    // Validate date range
    if (input.startDate != null && input.endDate != null) {
      if (input.endDate!.isBefore(input.startDate!)) {
        throw UseCaseValidationException(
          'End date must be after start date',
        );
      }
    }

    // Validate limit
    if (input.limit != null && (input.limit! < 1 || input.limit! > 1000)) {
      throw UseCaseValidationException(
        'Limit must be between 1 and 1000',
      );
    }
    return true;
  }

  @override
  Future<AppointmentHistoryResult> execute(
      GetAppointmentHistoryInput input) async {
    // Get all appointments
    final allAppointments = await appointmentRepository.getAllAppointments();

    // Filter by patient or doctor
    List<Appointment> filteredAppointments = allAppointments;

    if (input.patientId != null) {
      filteredAppointments = filteredAppointments
          .where((apt) => apt.patient.patientID == input.patientId)
          .toList();
    }

    if (input.doctorId != null) {
      filteredAppointments = filteredAppointments
          .where((apt) => apt.doctor.staffID == input.doctorId)
          .toList();
    }

    // Filter by date range
    if (input.startDate != null) {
      filteredAppointments = filteredAppointments
          .where((apt) => apt.dateTime.isAfter(input.startDate!))
          .toList();
    }

    if (input.endDate != null) {
      filteredAppointments = filteredAppointments
          .where((apt) => apt.dateTime.isBefore(input.endDate!))
          .toList();
    }

    // Filter by status
    if (input.statusFilter != null && input.statusFilter!.isNotEmpty) {
      filteredAppointments = filteredAppointments
          .where((apt) => input.statusFilter!.any((status) =>
              apt.status.toString().split('.').last.toUpperCase() ==
              status.toUpperCase()))
          .toList();
    }

    // Sort by date (most recent first)
    filteredAppointments.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    // Apply limit
    if (input.limit != null && filteredAppointments.length > input.limit!) {
      filteredAppointments = filteredAppointments.take(input.limit!).toList();
    }

    // Create history entries
    final now = DateTime.now();
    final history = filteredAppointments.map((apt) {
      final daysAgo = now.difference(apt.dateTime).inDays;
      final wasCompleted = apt.status == AppointmentStatus.COMPLETED;
      final wasCancelled = apt.status == AppointmentStatus.CANCELLED;
      final wasRescheduled = false; // No RESCHEDULED status in enum

      String statusDescription;
      if (wasCompleted) {
        statusDescription = 'Completed appointment';
      } else if (wasCancelled) {
        statusDescription = 'Cancelled';
      } else {
        statusDescription = apt.status.toString().split('.').last;
      }

      return AppointmentHistoryEntry(
        appointment: apt,
        daysAgo: daysAgo,
        statusDescription: statusDescription,
        wasCompleted: wasCompleted,
        wasCancelled: wasCancelled,
        wasRescheduled: wasRescheduled,
      );
    }).toList();

    // Calculate statistics
    final completedCount = history.where((e) => e.wasCompleted).length;
    final cancelledCount = history.where((e) => e.wasCancelled).length;
    final rescheduledCount = history.where((e) => e.wasRescheduled).length;

    return AppointmentHistoryResult(
      history: history,
      totalAppointments: history.length,
      completedCount: completedCount,
      cancelledCount: cancelledCount,
      rescheduledCount: rescheduledCount,
      patientName: input.patientId,
      doctorName: input.doctorId,
    );
  }
}
