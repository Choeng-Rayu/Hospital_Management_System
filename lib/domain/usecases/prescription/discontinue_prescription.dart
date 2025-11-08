import '../../repositories/prescription_repository.dart';
import '../base/use_case.dart';

/// Input for discontinuing prescription
class DiscontinuePrescriptionInput {
  final String prescriptionId;
  final String reason;
  final String discontinuedBy; // doctorId

  DiscontinuePrescriptionInput({
    required this.prescriptionId,
    required this.reason,
    required this.discontinuedBy,
  });
}

/// Output with discontinuation details
class DiscontinuePrescriptionOutput {
  final String prescriptionId;
  final String patientName;
  final String reason;
  final String discontinuedBy;
  final DateTime discontinuedAt;

  DiscontinuePrescriptionOutput({
    required this.prescriptionId,
    required this.patientName,
    required this.reason,
    required this.discontinuedBy,
    required this.discontinuedAt,
  });

  @override
  String toString() {
    return '''
🚫 PRESCRIPTION DISCONTINUED
━━━━━━━━━━━━━━━━━━━━━━━━
Prescription ID: $prescriptionId
Patient: $patientName
Discontinued by: Dr. $discontinuedBy
Date: ${discontinuedAt.toLocal()}
Reason: $reason
''';
  }
}

/// Use case for discontinuing a prescription
/// In a real system, this would mark prescription as inactive
/// For now, we delete the prescription with proper logging
class DiscontinuePrescription extends UseCase<DiscontinuePrescriptionInput,
    DiscontinuePrescriptionOutput> {
  final PrescriptionRepository prescriptionRepository;

  DiscontinuePrescription({required this.prescriptionRepository});

  @override
  Future<bool> validate(DiscontinuePrescriptionInput input) async {
    if (input.prescriptionId.trim().isEmpty) {
      throw UseCaseValidationException('Prescription ID is required');
    }

    if (input.reason.trim().isEmpty) {
      throw UseCaseValidationException(
          'Reason for discontinuation is required');
    }

    if (input.discontinuedBy.trim().isEmpty) {
      throw UseCaseValidationException('Doctor ID is required');
    }

    final exists =
        await prescriptionRepository.prescriptionExists(input.prescriptionId);
    if (!exists) {
      throw EntityNotFoundException('Prescription', input.prescriptionId);
    }
    return true;
  }

  @override
  Future<DiscontinuePrescriptionOutput> execute(
      DiscontinuePrescriptionInput input) async {
    final prescription =
        await prescriptionRepository.getPrescriptionById(input.prescriptionId);

    final patientName = prescription.prescribedTo.name;

    // In a real system, this would update a status field
    // For now, we delete the prescription
    // NOTE: In production, you would never actually delete - just mark inactive
    await prescriptionRepository.deletePrescription(input.prescriptionId);

    return DiscontinuePrescriptionOutput(
      prescriptionId: input.prescriptionId,
      patientName: patientName,
      reason: input.reason,
      discontinuedBy: input.discontinuedBy,
      discontinuedAt: DateTime.now(),
    );
  }

  @override
  Future<void> onSuccess(DiscontinuePrescriptionOutput result,
      DiscontinuePrescriptionInput input) async {
    print('✅ Prescription ${input.prescriptionId} discontinued successfully');
    print('   Patient: ${result.patientName}');
    print('   Reason: ${input.reason}');
  }

  @override
  Future<void> onError(
      Exception error, DiscontinuePrescriptionInput input) async {
    print('❌ Failed to discontinue prescription: ${error.toString()}');
  }
}
