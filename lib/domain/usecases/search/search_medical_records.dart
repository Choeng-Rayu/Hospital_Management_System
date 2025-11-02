import '../../repositories/patient_repository.dart';
import '../../entities/patient.dart';
import '../base/use_case.dart';

/// Input for medical records search
class SearchMedicalRecordsInput {
  final String? patientId;
  final String? keyword; // Search in medical records
  final String? allergy; // Search for specific allergy
  final int? limit;

  SearchMedicalRecordsInput({
    this.patientId,
    this.keyword,
    this.allergy,
    this.limit = 100,
  });

  bool get hasAnyFilter =>
      patientId != null || keyword != null || allergy != null;
}

/// Medical record search entry
class MedicalRecordEntry {
  final String patientId;
  final String patientName;
  final List<String> matchingRecords;
  final List<String> allergies;
  final int totalRecords;

  MedicalRecordEntry({
    required this.patientId,
    required this.patientName,
    required this.matchingRecords,
    required this.allergies,
    required this.totalRecords,
  });

  @override
  String toString() {
    return '''
👤 $patientName ($patientId)
   Records: $totalRecords | Allergies: ${allergies.length}
   ${matchingRecords.take(3).map((r) => '   • $r').join('\n')}
''';
  }
}

/// Medical records search result
class MedicalRecordsSearchResult {
  final List<MedicalRecordEntry> entries;
  final int totalPatients;
  final String query;

  MedicalRecordsSearchResult({
    required this.entries,
    required this.totalPatients,
    required this.query,
  });

  @override
  String toString() {
    return '''
🔍 MEDICAL RECORDS SEARCH
━━━━━━━━━━━━━━━━━━━━━━━━
Query: $query
Patients Found: $totalPatients

${entries.isEmpty ? '⚠️ No matching records' : entries.map((e) => e.toString()).join('\n')}
''';
  }
}

class SearchMedicalRecords
    extends UseCase<SearchMedicalRecordsInput, MedicalRecordsSearchResult> {
  final PatientRepository patientRepository;

  SearchMedicalRecords({required this.patientRepository});

  @override
  Future<bool> validate(SearchMedicalRecordsInput input) async {
    if (!input.hasAnyFilter) {
      throw UseCaseValidationException(
          'At least one search criterion required');
    }
    return true;
  }

  @override
  Future<MedicalRecordsSearchResult> execute(
      SearchMedicalRecordsInput input) async {
    List<Patient> patients;

    if (input.patientId != null) {
      final patient = await patientRepository.getPatientById(input.patientId!);
      patients = patient != null ? [patient] : <Patient>[];
    } else {
      patients = await patientRepository.getAllPatients();
    }

    // Filter and build entries
    final entries = <MedicalRecordEntry>[];

    for (final patient in patients) {
      List<String> matchingRecords = patient.medicalRecords.toList();

      // Filter by keyword
      if (input.keyword != null) {
        matchingRecords = matchingRecords
            .where((record) =>
                record.toLowerCase().contains(input.keyword!.toLowerCase()))
            .toList();
      }

      // Filter by allergy
      bool matchesAllergy = true;
      if (input.allergy != null) {
        matchesAllergy = patient.allergies.any((allergy) =>
            allergy.toLowerCase().contains(input.allergy!.toLowerCase()));
      }

      // Add entry if matches criteria
      if ((matchingRecords.isNotEmpty || input.keyword == null) &&
          matchesAllergy) {
        entries.add(MedicalRecordEntry(
          patientId: patient.patientID,
          patientName: patient.name,
          matchingRecords: matchingRecords,
          allergies: patient.allergies.toList(),
          totalRecords: patient.medicalRecords.length,
        ));
      }
    }

    // Apply limit
    if (input.limit != null && entries.length > input.limit!) {
      entries.removeRange(input.limit!, entries.length);
    }

    // Build query description
    final queryParts = <String>[];
    if (input.patientId != null) queryParts.add('patient:"${input.patientId}"');
    if (input.keyword != null) queryParts.add('keyword:"${input.keyword}"');
    if (input.allergy != null) queryParts.add('allergy:"${input.allergy}"');

    return MedicalRecordsSearchResult(
      entries: entries,
      totalPatients: entries.length,
      query: queryParts.join(' AND '),
    );
  }

  @override
  Future<void> onSuccess(MedicalRecordsSearchResult result,
      SearchMedicalRecordsInput input) async {
    print('✅ Found records for ${result.totalPatients} patients');
  }

  @override
  Future<void> onError(Exception error, SearchMedicalRecordsInput input) async {
    print('❌ Medical records search failed: $error');
  }
}
