import '../../repositories/prescription_repository.dart';
import '../../entities/prescription.dart';
import '../base/use_case.dart';

/// Input for prescription search
class SearchPrescriptionsInput {
  final String? patientId;
  final String? doctorId;
  final String? medicationName;
  final bool? activeOnly;
  final int? limit;

  SearchPrescriptionsInput({
    this.patientId,
    this.doctorId,
    this.medicationName,
    this.activeOnly,
    this.limit = 100,
  });

  bool get hasAnyFilter =>
      patientId != null ||
      doctorId != null ||
      medicationName != null ||
      activeOnly != null;
}

/// Prescription search result
class PrescriptionSearchResult {
  final List<Prescription> prescriptions;
  final int totalFound;
  final String query;

  PrescriptionSearchResult({
    required this.prescriptions,
    required this.totalFound,
    required this.query,
  });

  @override
  String toString() =>
      '🔍 Found $totalFound prescriptions | Query: $query\n${prescriptions.take(5).map((p) => '${p.id}: ${p.medicationNames.join(", ")}').join('\n')}';
}

class SearchPrescriptions
    extends UseCase<SearchPrescriptionsInput, PrescriptionSearchResult> {
  final PrescriptionRepository prescriptionRepository;

  SearchPrescriptions({required this.prescriptionRepository});

  @override
  Future<bool> validate(SearchPrescriptionsInput input) async {
    if (!input.hasAnyFilter) {
      throw UseCaseValidationException(
          'At least one search criterion required');
    }
    return true;
  }

  @override
  Future<PrescriptionSearchResult> execute(
      SearchPrescriptionsInput input) async {
    List<Prescription> results;

    if (input.patientId != null && input.activeOnly == true) {
      results = await prescriptionRepository
          .getActivePrescriptionsByPatient(input.patientId!);
    } else if (input.patientId != null) {
      results = await prescriptionRepository
          .getPrescriptionsByPatient(input.patientId!);
    } else if (input.doctorId != null) {
      results = await prescriptionRepository
          .getPrescriptionsByDoctor(input.doctorId!);
    } else {
      results = await prescriptionRepository.getAllPrescriptions();
    }

    if (input.medicationName != null) {
      results = results.where((p) {
        return p.medicationNames.any((med) =>
            med.toLowerCase().contains(input.medicationName!.toLowerCase()));
      }).toList();
    }

    final totalFound = results.length;
    if (input.limit != null) {
      results = results.take(input.limit!).toList();
    }

    final queryParts = <String>[];
    if (input.patientId != null) queryParts.add('patient:"${input.patientId}"');
    if (input.doctorId != null) queryParts.add('doctor:"${input.doctorId}"');
    if (input.medicationName != null)
      queryParts.add('medication:"${input.medicationName}"');
    if (input.activeOnly != null) queryParts.add('active:${input.activeOnly}');

    return PrescriptionSearchResult(
      prescriptions: results,
      totalFound: totalFound,
      query: queryParts.join(' AND '),
    );
  }

  @override
  Future<void> onSuccess(
      PrescriptionSearchResult result, SearchPrescriptionsInput input) async {
    print('✅ Found ${result.totalFound} prescriptions');
  }

  @override
  Future<void> onError(Exception error, SearchPrescriptionsInput input) async {
    print('❌ Prescription search failed: $error');
  }
}
