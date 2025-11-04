import '../../repositories/appointment_repository.dart';
import '../../entities/appointment.dart';
import '../base/use_case.dart';

/// Input for appointment search
class SearchAppointmentsInput {
  final String? patientId;
  final String? doctorId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;
  final int? limit;

  SearchAppointmentsInput({
    this.patientId,
    this.doctorId,
    this.startDate,
    this.endDate,
    this.status,
    this.limit = 100,
  });

  bool get hasAnyFilter =>
      patientId != null ||
      doctorId != null ||
      startDate != null ||
      endDate != null ||
      status != null;
}

/// Appointment search result
class AppointmentSearchResult {
  final List<Appointment> appointments;
  final int totalFound;
  final String query;

  AppointmentSearchResult({
    required this.appointments,
    required this.totalFound,
    required this.query,
  });

  @override
  String toString() =>
      '🔍 Found $totalFound appointments | Query: $query\n${appointments.take(5).map((a) => '${a.dateTime}: ${a.reason}').join('\n')}';
}

class SearchAppointments
    extends UseCase<SearchAppointmentsInput, AppointmentSearchResult> {
  final AppointmentRepository appointmentRepository;

  SearchAppointments({required this.appointmentRepository});

  @override
  Future<bool> validate(SearchAppointmentsInput input) async {
    if (!input.hasAnyFilter) {
      throw UseCaseValidationException(
          'At least one search criterion required');
    }

    if (input.startDate != null &&
        input.endDate != null &&
        input.startDate!.isAfter(input.endDate!)) {
      throw UseCaseValidationException('Start date must be before end date');
    }
    return true;
  }

  @override
  Future<AppointmentSearchResult> execute(SearchAppointmentsInput input) async {
    List<Appointment> results =
        await appointmentRepository.getAllAppointments();

    if (input.patientId != null) {
      results =
          results.where((a) => a.patient.patientID == input.patientId).toList();
    }

    if (input.doctorId != null) {
      results =
          results.where((a) => a.doctor.staffID == input.doctorId).toList();
    }

    if (input.startDate != null) {
      results =
          results.where((a) => !a.dateTime.isBefore(input.startDate!)).toList();
    }

    if (input.endDate != null) {
      results =
          results.where((a) => !a.dateTime.isAfter(input.endDate!)).toList();
    }

    if (input.status != null) {
      results = results
          .where((a) => a.status.toString().split('.').last == input.status!)
          .toList();
    }

    final totalFound = results.length;
    if (input.limit != null) {
      results = results.take(input.limit!).toList();
    }

    final queryParts = <String>[];
    if (input.patientId != null) queryParts.add('patient:"${input.patientId}"');
    if (input.doctorId != null) queryParts.add('doctor:"${input.doctorId}"');
    if (input.startDate != null) queryParts.add('from:${input.startDate}');
    if (input.endDate != null) queryParts.add('to:${input.endDate}');
    if (input.status != null) queryParts.add('status:"${input.status}"');

    return AppointmentSearchResult(
      appointments: results,
      totalFound: totalFound,
      query: queryParts.join(' AND '),
    );
  }

  @override
  Future<void> onSuccess(
      AppointmentSearchResult result, SearchAppointmentsInput input) async {
    print('✅ Found ${result.totalFound} appointments');
  }

  @override
  Future<void> onError(Exception error, SearchAppointmentsInput input) async {
    print('❌ Appointment search failed: $error');
  }
}
