import '../../repositories/doctor_repository.dart';
import '../../entities/doctor.dart';
import '../base/use_case.dart';

/// Input for doctor search
class SearchDoctorsInput {
  final String? name;
  final String? specialty;
  final bool? isAvailable;
  final int? limit;

  SearchDoctorsInput({
    this.name,
    this.specialty,
    this.isAvailable,
    this.limit = 100,
  });

  bool get hasAnyFilter =>
      name != null || specialty != null || isAvailable != null;
}

/// Doctor search result
class DoctorSearchResult {
  final List<Doctor> doctors;
  final int totalFound;
  final String query;

  DoctorSearchResult({
    required this.doctors,
    required this.totalFound,
    required this.query,
  });

  @override
  String toString() =>
      '🔍 Found $totalFound doctors | Query: $query\n${doctors.map((d) => '${d.name} - ${d.specialization}').join('\n')}';
}

class SearchDoctors extends UseCase<SearchDoctorsInput, DoctorSearchResult> {
  final DoctorRepository doctorRepository;

  SearchDoctors({required this.doctorRepository});

  @override
  Future<bool> validate(SearchDoctorsInput input) async {
    if (!input.hasAnyFilter) {
      throw UseCaseValidationException(
          'At least one search criterion required');
    }
    return true;
  }

  @override
  Future<DoctorSearchResult> execute(SearchDoctorsInput input) async {
    List<Doctor> results = await doctorRepository.getAllDoctors();

    if (input.name != null) {
      results = results
          .where(
              (d) => d.name.toLowerCase().contains(input.name!.toLowerCase()))
          .toList();
    }

    if (input.specialty != null) {
      results = results
          .where((d) => d.specialization
              .toLowerCase()
              .contains(input.specialty!.toLowerCase()))
          .toList();
    }

    if (input.isAvailable != null && input.isAvailable!) {
      results = results.where((d) => d.patientCount < 10).toList();
    }

    final totalFound = results.length;
    if (input.limit != null) {
      results = results.take(input.limit!).toList();
    }

    final queryParts = <String>[];
    if (input.name != null) queryParts.add('name:"${input.name}"');
    if (input.specialty != null)
      queryParts.add('specialty:"${input.specialty}"');
    if (input.isAvailable != null)
      queryParts.add('available:${input.isAvailable}');

    return DoctorSearchResult(
      doctors: results,
      totalFound: totalFound,
      query: queryParts.join(' AND '),
    );
  }

  @override
  Future<void> onSuccess(
      DoctorSearchResult result, SearchDoctorsInput input) async {
    print('✅ Found ${result.totalFound} doctors');
  }

  @override
  Future<void> onError(Exception error, SearchDoctorsInput input) async {
    print('❌ Doctor search failed: $error');
  }
}
