import '../../repositories/prescription_repository.dart';
import '../base/use_case.dart';

/// Input for getting active prescriptions
class GetActivePrescriptionsInput {
  final String patientId;

  GetActivePrescriptionsInput({required this.patientId});
}

/// Active prescription summary
class ActivePrescriptionSummary {
  final String prescriptionId;
  final List<String> medicationNames;
  final String instructions;
  final String doctorName;
  final DateTime prescribedDate;
  final int daysActive;

  ActivePrescriptionSummary({
    required this.prescriptionId,
    required this.medicationNames,
    required this.instructions,
    required this.doctorName,
    required this.prescribedDate,
    required this.daysActive,
  });

  @override
  String toString() {
    return '''
📋 Prescription #$prescriptionId
   Medications: ${medicationNames.join(', ')}
   Doctor: Dr. $doctorName
   Prescribed: ${prescribedDate.toLocal()} ($daysActive days ago)
   Instructions: $instructions
''';
  }
}

/// Result with all active prescriptions
class ActivePrescriptionsResult {
  final String patientId;
  final List<ActivePrescriptionSummary> prescriptions;
  final int totalPrescriptions;
  final int totalMedications;

  ActivePrescriptionsResult({
    required this.patientId,
    required this.prescriptions,
    required this.totalPrescriptions,
    required this.totalMedications,
  });

  @override
  String toString() {
    return '''
💊 ACTIVE PRESCRIPTIONS
━━━━━━━━━━━━━━━━━━━━━━━━
Patient ID: $patientId
Total Prescriptions: $totalPrescriptions
Total Medications: $totalMedications

${prescriptions.isEmpty ? '✓ No active prescriptions' : prescriptions.map((p) => p.toString()).join('\n')}
''';
  }
}

/// Use case for getting all active prescriptions for a patient
/// Returns comprehensive list of current medications
class GetActivePrescriptions
    extends UseCase<GetActivePrescriptionsInput, ActivePrescriptionsResult> {
  final PrescriptionRepository prescriptionRepository;

  GetActivePrescriptions({required this.prescriptionRepository});

  @override
  Future<bool> validate(GetActivePrescriptionsInput input) async {
    if (input.patientId.trim().isEmpty) {
      throw UseCaseValidationException('Patient ID is required');
    }
    return true;
  }

  @override
  Future<ActivePrescriptionsResult> execute(
      GetActivePrescriptionsInput input) async {
    // Get active prescriptions from repository
    final prescriptions = await prescriptionRepository
        .getActivePrescriptionsByPatient(input.patientId);

    // Transform to summaries
    final summaries = prescriptions.map((prescription) {
      final daysActive = DateTime.now().difference(prescription.time).inDays;

      return ActivePrescriptionSummary(
        prescriptionId: prescription.id,
        medicationNames: prescription.medicationNames.toList(),
        instructions: prescription.instructions,
        doctorName: prescription.prescribedBy.name,
        prescribedDate: prescription.time,
        daysActive: daysActive,
      );
    }).toList();

    // Sort by most recent first
    summaries.sort((a, b) => b.prescribedDate.compareTo(a.prescribedDate));

    // Count total medications
    final allMedications = <String>{};
    for (final summary in summaries) {
      allMedications.addAll(summary.medicationNames);
    }

    return ActivePrescriptionsResult(
      patientId: input.patientId,
      prescriptions: summaries,
      totalPrescriptions: summaries.length,
      totalMedications: allMedications.length,
    );
  }

  @override
  Future<void> onSuccess(ActivePrescriptionsResult result,
      GetActivePrescriptionsInput input) async {
    if (result.totalPrescriptions == 0) {
      print('ℹ️ No active prescriptions found for patient ${input.patientId}');
    } else {
      print(
          '✅ Found ${result.totalPrescriptions} active prescriptions (${result.totalMedications} unique medications)');
    }
  }

  @override
  Future<void> onError(
      Exception error, GetActivePrescriptionsInput input) async {
    print(
        '❌ Failed to get active prescriptions for patient ${input.patientId}: ${error.toString()}');
  }
}
