import '../../entities/prescription.dart';
import '../../repositories/prescription_repository.dart';
import '../base/use_case.dart';

/// Input for getting prescription history
class GetPrescriptionHistoryInput {
  final String patientId;
  final int? limit;

  GetPrescriptionHistoryInput({
    required this.patientId,
    this.limit = 50,
  });
}

/// Prescription history entry
class PrescriptionHistoryEntry {
  final Prescription prescription;
  final int daysAgo;
  final bool isRecent;

  PrescriptionHistoryEntry({
    required this.prescription,
    required this.daysAgo,
    required this.isRecent,
  });

  @override
  String toString() {
    return '${prescription.formattedDate} - ${prescription.medicationNames.join(', ')} (${daysAgo} days ago)';
  }
}

/// Result containing prescription history
class PrescriptionHistoryResult {
  final String patientId;
  final List<PrescriptionHistoryEntry> history;
  final int totalCount;
  final int recentCount;

  PrescriptionHistoryResult({
    required this.patientId,
    required this.history,
    required this.totalCount,
    required this.recentCount,
  });

  @override
  String toString() {
    return '''
📋 PRESCRIPTION HISTORY
━━━━━━━━━━━━━━━━━━━━━━━━
Patient ID: $patientId
Total: $totalCount prescriptions
Recent (30 days): $recentCount

${history.take(10).map((e) => e.toString()).join('\n')}
''';
  }
}

/// Use case for getting patient prescription history
/// Provides chronological prescription records
class GetPrescriptionHistory
    extends UseCase<GetPrescriptionHistoryInput, PrescriptionHistoryResult> {
  final PrescriptionRepository prescriptionRepository;

  GetPrescriptionHistory({required this.prescriptionRepository});

  @override
  Future<bool> validate(GetPrescriptionHistoryInput input) async {
    if (input.patientId.trim().isEmpty) {
      throw UseCaseValidationException('Patient ID is required');
    }

    if (input.limit != null && (input.limit! < 1 || input.limit! > 1000)) {
      throw UseCaseValidationException('Limit must be between 1 and 1000');
    }
    return true;
  }

  @override
  Future<PrescriptionHistoryResult> execute(
      GetPrescriptionHistoryInput input) async {
    // Get all prescriptions for patient
    final prescriptions =
        await prescriptionRepository.getPrescriptionsByPatient(input.patientId);

    // Sort by date (most recent first)
    prescriptions.sort((a, b) => b.time.compareTo(a.time));

    // Apply limit if provided
    final limitedPrescriptions = input.limit != null
        ? prescriptions.take(input.limit!).toList()
        : prescriptions;

    // Create history entries
    final now = DateTime.now();
    final history = limitedPrescriptions.map((prescription) {
      final daysAgo = now.difference(prescription.time).inDays;
      return PrescriptionHistoryEntry(
        prescription: prescription,
        daysAgo: daysAgo,
        isRecent: prescription.isRecent,
      );
    }).toList();

    final recentCount = prescriptions.where((p) => p.isRecent).length;

    return PrescriptionHistoryResult(
      patientId: input.patientId,
      history: history,
      totalCount: prescriptions.length,
      recentCount: recentCount,
    );
  }
}
