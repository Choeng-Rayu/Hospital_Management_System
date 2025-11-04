import '../../repositories/patient_repository.dart';
import '../../entities/patient.dart';
import '../base/use_case.dart';

/// Input for advanced patient search
class SearchPatientsInput {
  final String? name;
  final String? patientId;
  final String? bloodType;
  final bool? hasNextMeeting;
  final int? limit;

  SearchPatientsInput({
    this.name,
    this.patientId,
    this.bloodType,
    this.hasNextMeeting,
    this.limit = 100,
  });

  bool get hasAnyFilter =>
      name != null ||
      patientId != null ||
      bloodType != null ||
      hasNextMeeting != null;
}

/// Patient search result with metadata
class PatientSearchResult {
  final List<Patient> patients;
  final int totalFound;
  final Map<String, int> filterStats;
  final String query;

  PatientSearchResult({
    required this.patients,
    required this.totalFound,
    required this.filterStats,
    required this.query,
  });

  @override
  String toString() {
    return '''
🔍 PATIENT SEARCH RESULTS
━━━━━━━━━━━━━━━━━━━━━━━━
Query: $query
Total Found: $totalFound

${patients.isEmpty ? '⚠️ No patients found matching criteria' : patients.map((p) => '${p.name} (${p.patientID}) - ${p.bloodType}').join('\n')}

📊 Filter Statistics:
${filterStats.entries.map((e) => '   ${e.key}: ${e.value}').join('\n')}
''';
  }
}

/// Use case for advanced patient search with multiple criteria
/// Supports filtering by demographics, health status, and relationships
class SearchPatients extends UseCase<SearchPatientsInput, PatientSearchResult> {
  final PatientRepository patientRepository;

  SearchPatients({required this.patientRepository});

  @override
  Future<bool> validate(SearchPatientsInput input) async {
    if (!input.hasAnyFilter) {
      throw UseCaseValidationException(
          'At least one search criterion is required');
    }

    if (input.limit != null && (input.limit! < 1 || input.limit! > 1000)) {
      throw UseCaseValidationException('Limit must be between 1 and 1000');
    }
    return true;
  }

  @override
  Future<PatientSearchResult> execute(SearchPatientsInput input) async {
    // Start with all patients
    List<Patient> results = await patientRepository.getAllPatients();

    // Apply filters sequentially
    if (input.patientId != null) {
      results = results
          .where((p) => p.patientID
              .toLowerCase()
              .contains(input.patientId!.toLowerCase()))
          .toList();
    }

    if (input.name != null) {
      results = results
          .where(
              (p) => p.name.toLowerCase().contains(input.name!.toLowerCase()))
          .toList();
    }

    if (input.bloodType != null) {
      results = results
          .where((p) =>
              p.bloodType.toLowerCase() == input.bloodType!.toLowerCase())
          .toList();
    }

    if (input.hasNextMeeting != null) {
      if (input.hasNextMeeting!) {
        results = results.where((p) => p.hasNextMeeting).toList();
      } else {
        results = results.where((p) => !p.hasNextMeeting).toList();
      }
    }

    // Apply limit
    final totalFound = results.length;
    if (input.limit != null && results.length > input.limit!) {
      results = results.take(input.limit!).toList();
    }

    // Generate filter stats
    final stats = <String, int>{
      'Total Results': totalFound,
      'Displayed': results.length,
      'With Next Meeting': results.where((p) => p.hasNextMeeting).length,
      'Blood Type O': results
          .where((p) => p.bloodType.toUpperCase().startsWith('O'))
          .length,
      'Blood Type A': results
          .where((p) => p.bloodType.toUpperCase().startsWith('A'))
          .length,
      'Blood Type B': results
          .where((p) => p.bloodType.toUpperCase().startsWith('B'))
          .length,
      'Blood Type AB': results
          .where((p) => p.bloodType.toUpperCase().startsWith('AB'))
          .length,
    };

    // Build query description
    final queryParts = <String>[];
    if (input.name != null) queryParts.add('name:"${input.name}"');
    if (input.patientId != null) queryParts.add('id:"${input.patientId}"');
    if (input.bloodType != null) queryParts.add('blood:"${input.bloodType}"');
    if (input.hasNextMeeting != null)
      queryParts.add('meeting:${input.hasNextMeeting}');

    return PatientSearchResult(
      patients: results,
      totalFound: totalFound,
      filterStats: stats,
      query: queryParts.isEmpty ? 'all' : queryParts.join(' AND '),
    );
  }

  @override
  Future<void> onSuccess(
      PatientSearchResult result, SearchPatientsInput input) async {
    print('✅ Patient search completed');
    print('   Found ${result.totalFound} patients matching criteria');
    if (result.totalFound > (input.limit ?? 100)) {
      print('   ⚠️ Results limited to ${input.limit ?? 100}');
    }
  }

  @override
  Future<void> onError(Exception error, SearchPatientsInput input) async {
    print('❌ Patient search failed: ${error.toString()}');
  }
}
