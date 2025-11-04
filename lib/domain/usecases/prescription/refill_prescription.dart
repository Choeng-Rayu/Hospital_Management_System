import '../../entities/prescription.dart';
import '../../repositories/prescription_repository.dart';
import '../../repositories/patient_repository.dart';
import '../../repositories/doctor_repository.dart';
import '../base/use_case.dart';

/// Input for refilling a prescription
class RefillPrescriptionInput {
  final String prescriptionId;
  final int refillQuantity;
  final String requestedBy; // patient ID or staff ID
  final DateTime requestDate;
  final String? notes;

  RefillPrescriptionInput({
    required this.prescriptionId,
    required this.refillQuantity,
    required this.requestedBy,
    DateTime? requestDate,
    this.notes,
  }) : requestDate = requestDate ?? DateTime.now();
}

/// Result of prescription refill
class RefillPrescriptionResult {
  final Prescription originalPrescription;
  final Prescription refilledPrescription;
  final int refillNumber;
  final int remainingRefills;
  final DateTime refillDate;
  final String confirmationNumber;
  final bool requiresDoctorApproval;

  RefillPrescriptionResult({
    required this.originalPrescription,
    required this.refilledPrescription,
    required this.refillNumber,
    required this.remainingRefills,
    required this.refillDate,
    required this.confirmationNumber,
    required this.requiresDoctorApproval,
  });

  @override
  String toString() {
    return '''
💊 PRESCRIPTION REFILLED
━━━━━━━━━━━━━━━━━━━━━━━━
Confirmation: $confirmationNumber
Medications: ${originalPrescription.medicationNames.join(', ')}
Refill #: $refillNumber
Remaining: $remainingRefills refills
Date: ${refillDate.toString().split('.')[0]}
${requiresDoctorApproval ? '⚠️ Requires doctor approval' : '✓ Approved'}
''';
  }
}

/// Use case for refilling existing prescriptions
/// Validates refill eligibility and tracks refill count
class RefillPrescription
    extends UseCase<RefillPrescriptionInput, RefillPrescriptionResult> {
  final PrescriptionRepository prescriptionRepository;
  final PatientRepository patientRepository;
  final DoctorRepository doctorRepository;

  RefillPrescription({
    required this.prescriptionRepository,
    required this.patientRepository,
    required this.doctorRepository,
  });

  @override
  Future<bool> validate(RefillPrescriptionInput input) async {
    if (input.refillQuantity < 1) {
      throw UseCaseValidationException(
        'Refill quantity must be at least 1',
      );
    }

    // Refill quantity should match original or be less
    if (input.refillQuantity > 365) {
      throw UseCaseValidationException(
        'Refill quantity cannot exceed 365 days supply',
      );
    }
    return true;
  }

  @override
  Future<RefillPrescriptionResult> execute(
      RefillPrescriptionInput input) async {
    // Get original prescription
    final prescription =
        await prescriptionRepository.getPrescriptionById(input.prescriptionId);

    // Verify patient exists
    await patientRepository.getPatientById(prescription.prescribedTo.patientID);

    // Verify doctor exists
    await doctorRepository.getDoctorById(prescription.prescribedBy.staffID);

    // Check if prescription is recent (not too old to refill)
    final daysSincePrescribed =
        DateTime.now().difference(prescription.time).inDays;
    if (daysSincePrescribed > 90) {
      throw BusinessRuleViolationException(
        'Prescription is too old to refill. Please contact doctor for new prescription',
        'PRESCRIPTION_EXPIRED',
      );
    }

    // Parse refill information from instructions
    final currentRefills = _extractRefillCount(prescription.instructions);
    final maxRefills = _extractMaxRefills(prescription.instructions);

    // Check if refills are available
    if (currentRefills >= maxRefills) {
      throw BusinessRuleViolationException(
        'No refills remaining. Please contact doctor for new prescription',
        'NO_REFILLS_REMAINING',
      );
    }

    // Check if too soon to refill (80% rule - can refill when 80% consumed)
    const expectedDuration = 30; // Default 30-day supply

    if (daysSincePrescribed < (expectedDuration * 0.8).round()) {
      throw BusinessRuleViolationException(
        'Too soon to refill. Please wait until 80% of prescription is consumed',
        'REFILL_TOO_SOON',
      );
    }

    // Determine if requires doctor approval (controlled substances)
    final requiresApproval = _requiresDoctorApproval(prescription);

    // Create refilled prescription
    final refillNumber = currentRefills + 1;
    final remainingRefills = maxRefills - refillNumber;

    final refilledPrescription = Prescription(
      id: prescription.id,
      time: input.requestDate,
      medications: prescription.medications.toList(),
      instructions:
          '${prescription.instructions}\n[${input.requestDate.toString().split('.')[0]}] Refill #$refillNumber requested by ${input.requestedBy}${input.notes != null ? ': ${input.notes}' : ''}',
      prescribedBy: prescription.prescribedBy,
      prescribedTo: prescription.prescribedTo,
    );

    // Update prescription
    await prescriptionRepository.updatePrescription(refilledPrescription);

    // Generate confirmation number
    final confirmationNumber =
        'RFL-${input.requestDate.millisecondsSinceEpoch % 100000}';

    return RefillPrescriptionResult(
      originalPrescription: prescription,
      refilledPrescription: refilledPrescription,
      refillNumber: refillNumber,
      remainingRefills: remainingRefills,
      refillDate: input.requestDate,
      confirmationNumber: confirmationNumber,
      requiresDoctorApproval: requiresApproval,
    );
  }

  int _extractRefillCount(String instructions) {
    final refillMatches = RegExp(r'Refill #(\d+)').allMatches(instructions);
    return refillMatches.length;
  }

  int _extractMaxRefills(String instructions) {
    // Default to 3 refills if not specified
    final match = RegExp(r'Max refills: (\d+)').firstMatch(instructions);
    return match != null ? int.parse(match.group(1)!) : 3;
  }

  bool _requiresDoctorApproval(Prescription prescription) {
    // Controlled substances require approval
    final controlledKeywords = [
      'opioid',
      'narcotic',
      'morphine',
      'oxycodone',
      'fentanyl',
      'hydrocodone',
      'controlled',
    ];

    // Check medication names and instructions
    final allText =
        '${prescription.medicationNames.join(' ')} ${prescription.instructions}'
            .toLowerCase();
    return controlledKeywords.any((keyword) => allText.contains(keyword));
  }

  @override
  Future<void> onSuccess(
      RefillPrescriptionResult result, RefillPrescriptionInput input) async {
    print('💊 Prescription refilled: ${result.confirmationNumber}');
    print(
        '   Medications: ${result.originalPrescription.medicationNames.join(', ')}');
    print(
        '   Refill #${result.refillNumber} (${result.remainingRefills} remaining)');

    if (result.requiresDoctorApproval) {
      print('   ⚠️ Requires doctor approval');
    }
  }
}
