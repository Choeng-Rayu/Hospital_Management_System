import '../../entities/prescription.dart';
import '../../repositories/prescription_repository.dart';
import '../base/use_case.dart';

/// Input for getting medication schedule
class GetMedicationScheduleInput {
  final String patientId;
  final DateTime? date; // Specific date, defaults to today

  GetMedicationScheduleInput({
    required this.patientId,
    this.date,
  });
}

/// Medication dose schedule
class MedicationDose {
  final String medicationName;
  final String dosage;
  final DateTime scheduledTime;
  final bool isTaken;

  MedicationDose({
    required this.medicationName,
    required this.dosage,
    required this.scheduledTime,
    this.isTaken = false,
  });

  @override
  String toString() {
    final timeStr =
        '${scheduledTime.hour.toString().padLeft(2, '0')}:${scheduledTime.minute.toString().padLeft(2, '0')}';
    final status = isTaken ? '✓' : '○';
    return '$status $timeStr - $medicationName ($dosage)';
  }
}

/// Result containing medication schedule
class MedicationScheduleResult {
  final String patientId;
  final DateTime date;
  final List<MedicationDose> schedule;
  final int totalDoses;
  final int takenDoses;
  final int missedDoses;
  final double adherencePercentage;

  MedicationScheduleResult({
    required this.patientId,
    required this.date,
    required this.schedule,
    required this.totalDoses,
    required this.takenDoses,
    required this.missedDoses,
    required this.adherencePercentage,
  });

  @override
  String toString() {
    return '''
📅 MEDICATION SCHEDULE
━━━━━━━━━━━━━━━━━━━━━━━━
Patient: $patientId
Date: ${date.toString().split(' ')[0]}
Total Doses: $totalDoses
Taken: $takenDoses
Missed: $missedDoses
Adherence: ${adherencePercentage.toStringAsFixed(1)}%

${schedule.map((d) => d.toString()).join('\n')}
''';
  }
}

/// Use case for getting patient's daily medication schedule
/// Organizes medications by time for easy compliance tracking
class GetMedicationSchedule
    extends UseCase<GetMedicationScheduleInput, MedicationScheduleResult> {
  final PrescriptionRepository prescriptionRepository;

  GetMedicationSchedule({required this.prescriptionRepository});

  @override
  Future<bool> validate(GetMedicationScheduleInput input) async {
    if (input.patientId.trim().isEmpty) {
      throw UseCaseValidationException('Patient ID is required');
    }
    return true;
  }

  @override
  Future<MedicationScheduleResult> execute(
      GetMedicationScheduleInput input) async {
    final targetDate = input.date ?? DateTime.now();
    final scheduleDate = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );

    final activePrescriptions = await prescriptionRepository
        .getActivePrescriptionsByPatient(input.patientId);

    final schedule = <MedicationDose>[];

    for (final prescription in activePrescriptions) {
      final doses = _generateDosesForDay(
        prescription,
        scheduleDate,
      );
      schedule.addAll(doses);
    }

    schedule.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

    final takenDoses = schedule.where((d) => d.isTaken).length;
    final missedDoses = schedule.length - takenDoses;
    final adherencePercentage = schedule.isNotEmpty
        ? (takenDoses.toDouble() / schedule.length.toDouble()) * 100
        : 100.0;

    return MedicationScheduleResult(
      patientId: input.patientId,
      date: scheduleDate,
      schedule: schedule,
      totalDoses: schedule.length,
      takenDoses: takenDoses,
      missedDoses: missedDoses,
      adherencePercentage: adherencePercentage,
    );
  }

  List<MedicationDose> _generateDosesForDay(
    Prescription prescription,
    DateTime date,
  ) {
    final doses = <MedicationDose>[];

    final instructions = prescription.instructions.toLowerCase();

    List<int> dosingHours;
    if (instructions.contains('once daily') || instructions.contains('1x')) {
      dosingHours = [8]; // 8 AM
    } else if (instructions.contains('twice daily') ||
        instructions.contains('2x') ||
        instructions.contains('bid')) {
      dosingHours = [8, 20]; // 8 AM, 8 PM
    } else if (instructions.contains('three times') ||
        instructions.contains('3x') ||
        instructions.contains('tid')) {
      dosingHours = [8, 14, 20]; // 8 AM, 2 PM, 8 PM
    } else if (instructions.contains('four times') ||
        instructions.contains('4x') ||
        instructions.contains('qid')) {
      dosingHours = [8, 12, 16, 20]; // 8 AM, 12 PM, 4 PM, 8 PM
    } else {
      // Default to once daily
      dosingHours = [8];
    }

    for (final medName in prescription.medicationNames) {
      for (final hour in dosingHours) {
        doses.add(MedicationDose(
          medicationName: medName,
          dosage: 'As prescribed', // Would parse from prescription
          scheduledTime: DateTime(date.year, date.month, date.day, hour),
          isTaken: false, // Would check intake records
        ));
      }
    }

    return doses;
  }
}
