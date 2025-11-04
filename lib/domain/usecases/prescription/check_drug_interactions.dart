import '../../repositories/prescription_repository.dart';
import '../base/use_case.dart';

/// Input for checking drug interactions
class CheckDrugInteractionsInput {
  final String patientId;
  final List<String> newMedicationNames;

  CheckDrugInteractionsInput({
    required this.patientId,
    required this.newMedicationNames,
  });
}

/// Drug interaction warning
class DrugInteractionWarning {
  final String medication1;
  final String medication2;
  final String severity; // 'CRITICAL', 'HIGH', 'MEDIUM', 'LOW'
  final String description;
  final String recommendation;

  DrugInteractionWarning({
    required this.medication1,
    required this.medication2,
    required this.severity,
    required this.description,
    required this.recommendation,
  });

  @override
  String toString() {
    final emoji = severity == 'CRITICAL'
        ? '🔴'
        : severity == 'HIGH'
            ? '🟠'
            : severity == 'MEDIUM'
                ? '🟡'
                : '🟢';
    return '$emoji $severity: $medication1 + $medication2\n   $description\n   → $recommendation';
  }
}

/// Result of drug interaction check
class DrugInteractionResult {
  final List<DrugInteractionWarning> interactions;
  final bool hasCriticalInteractions;
  final bool hasWarnings;
  final bool isSafe;
  final String recommendation;

  DrugInteractionResult({
    required this.interactions,
    required this.hasCriticalInteractions,
    required this.hasWarnings,
    required this.isSafe,
    required this.recommendation,
  });

  @override
  String toString() {
    return '''
💊 DRUG INTERACTION CHECK
━━━━━━━━━━━━━━━━━━━━━━━━
Status: ${isSafe ? '✅ Safe' : '⚠️ Warnings Found'}
Critical: ${hasCriticalInteractions ? 'YES' : 'No'}
Warnings: ${interactions.length}

${interactions.isNotEmpty ? interactions.map((i) => i.toString()).join('\n\n') : '✓ No interactions detected'}

📋 Recommendation: $recommendation
''';
  }
}

/// Use case for checking potential drug interactions
/// Validates new medications against current prescriptions
class CheckDrugInteractions
    extends UseCase<CheckDrugInteractionsInput, DrugInteractionResult> {
  final PrescriptionRepository prescriptionRepository;

  CheckDrugInteractions({required this.prescriptionRepository});

  @override
  Future<bool> validate(CheckDrugInteractionsInput input) async {
    if (input.patientId.trim().isEmpty) {
      throw UseCaseValidationException('Patient ID is required');
    }

    if (input.newMedicationNames.isEmpty) {
      throw UseCaseValidationException(
          'At least one new medication name is required');
    }
    return true;
  }

  @override
  Future<DrugInteractionResult> execute(
      CheckDrugInteractionsInput input) async {
    // Get active prescriptions
    final activePrescriptions = await prescriptionRepository
        .getActivePrescriptionsByPatient(input.patientId);

    // Get all current medications
    final currentMedications = <String>{};
    for (final prescription in activePrescriptions) {
      currentMedications.addAll(prescription.medicationNames);
    }

    // Check for interactions
    final interactions = <DrugInteractionWarning>[];

    for (final newMed in input.newMedicationNames) {
      for (final currentMed in currentMedications) {
        final interaction = _checkInteraction(newMed, currentMed);
        if (interaction != null) {
          interactions.add(interaction);
        }
      }
    }

    // Determine overall safety
    final hasCritical = interactions.any((i) => i.severity == 'CRITICAL');
    final hasWarnings = interactions.isNotEmpty;
    final isSafe = !hasWarnings;

    // Generate recommendation
    String recommendation;
    if (hasCritical) {
      recommendation =
          'DO NOT PRESCRIBE: Critical drug interactions detected. Consult pharmacist immediately.';
    } else if (hasWarnings) {
      recommendation =
          'CAUTION: Potential interactions detected. Monitor patient closely or consider alternatives.';
    } else {
      recommendation = 'Safe to prescribe. No known interactions detected.';
    }

    // Sort by severity
    interactions.sort((a, b) {
      const severityOrder = {'CRITICAL': 0, 'HIGH': 1, 'MEDIUM': 2, 'LOW': 3};
      return (severityOrder[a.severity] ?? 99)
          .compareTo(severityOrder[b.severity] ?? 99);
    });

    return DrugInteractionResult(
      interactions: interactions,
      hasCriticalInteractions: hasCritical,
      hasWarnings: hasWarnings,
      isSafe: isSafe,
      recommendation: recommendation,
    );
  }

  /// Check for drug interactions (simplified implementation)
  /// In production, this would use a comprehensive drug interaction database
  DrugInteractionWarning? _checkInteraction(String med1, String med2) {
    final med1Lower = med1.toLowerCase();
    final med2Lower = med2.toLowerCase();

    // Known critical interactions (simplified list)
    final criticalPairs = {
      {'warfarin', 'aspirin'}: {
        'severity': 'CRITICAL',
        'description': 'Increased bleeding risk',
        'recommendation': 'Avoid combination or monitor INR closely',
      },
      {'warfarin', 'ibuprofen'}: {
        'severity': 'CRITICAL',
        'description': 'Increased bleeding risk',
        'recommendation': 'Use alternative pain medication',
      },
      {'metformin', 'alcohol'}: {
        'severity': 'HIGH',
        'description': 'Risk of lactic acidosis',
        'recommendation': 'Limit alcohol consumption',
      },
      {'ssri', 'mao inhibitor'}: {
        'severity': 'CRITICAL',
        'description': 'Risk of serotonin syndrome',
        'recommendation': 'DO NOT combine - life threatening',
      },
    };

    // Check for keyword matches
    for (final pair in criticalPairs.keys) {
      if (_matchesPair(med1Lower, med2Lower, pair)) {
        final info = criticalPairs[pair]!;
        return DrugInteractionWarning(
          medication1: med1,
          medication2: med2,
          severity: info['severity'] as String,
          description: info['description'] as String,
          recommendation: info['recommendation'] as String,
        );
      }
    }

    return null; // No interaction found
  }

  bool _matchesPair(String med1, String med2, Set<String> pair) {
    final keywords = pair.toList();
    return (med1.contains(keywords[0]) && med2.contains(keywords[1])) ||
        (med1.contains(keywords[1]) && med2.contains(keywords[0]));
  }

  @override
  Future<void> onSuccess(
      DrugInteractionResult result, CheckDrugInteractionsInput input) async {
    if (result.hasCriticalInteractions) {
      print('🔴 CRITICAL: Drug interactions detected!');
    } else if (result.hasWarnings) {
      print('⚠️ WARNING: Potential interactions found');
    } else {
      print('✅ No drug interactions detected');
    }
  }
}
