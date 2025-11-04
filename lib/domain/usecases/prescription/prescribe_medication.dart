import '../../entities/prescription.dart';
import '../../entities/medication.dart';
import '../../entities/patient.dart';
import '../../repositories/prescription_repository.dart';
import '../../repositories/patient_repository.dart';
import '../../repositories/doctor_repository.dart';

/// Use case for prescribing medication to a patient
/// Handles validation including allergy checks
class PrescribeMedication {
  final PrescriptionRepository prescriptionRepository;
  final PatientRepository patientRepository;
  final DoctorRepository doctorRepository;

  PrescribeMedication({
    required this.prescriptionRepository,
    required this.patientRepository,
    required this.doctorRepository,
  });

  /// Execute medication prescription
  ///
  /// Steps:
  /// 1. Validate patient exists
  /// 2. Validate doctor exists
  /// 3. Check doctor is assigned to patient
  /// 4. Check for medication allergies
  /// 5. Create and save prescription
  Future<Prescription> execute({
    required String prescriptionId,
    required String patientId,
    required String doctorId,
    required List<Medication> medications,
    required String instructions,
  }) async {
    // 1. Get patient
    final patient = await patientRepository.getPatientById(patientId);

    // 2. Get doctor
    final doctor = await doctorRepository.getDoctorById(doctorId);

    // 3. Validate doctor is assigned to patient
    if (!patient.assignedDoctors.any((d) => d.staffID == doctorId)) {
      throw DoctorNotAssignedException(
        'Doctor $doctorId is not assigned to patient $patientId',
      );
    }

    // 4. Check for allergies and side effects
    for (final medication in medications) {
      _checkForAllergicReaction(patient, medication);
    }

    // 5. Create prescription
    final prescription = Prescription(
      id: prescriptionId,
      time: DateTime.now(),
      medications: medications,
      instructions: instructions,
      prescribedBy: doctor,
      prescribedTo: patient,
    );

    // 6. Add prescription to patient's records
    patient.addPrescription(prescription);

    // 7. Save prescription
    await prescriptionRepository.savePrescription(prescription);

    // 8. Update patient record
    await patientRepository.updatePatient(patient);

    return prescription;
  }

  /// Check if patient has allergies to medication or its side effects
  void _checkForAllergicReaction(Patient patient, Medication medication) {
    // Check medication name against patient allergies
    for (final allergy in patient.allergies) {
      if (medication.name.toLowerCase().contains(allergy.toLowerCase()) ||
          allergy.toLowerCase().contains(medication.name.toLowerCase())) {
        throw AllergicReactionException(
          'Patient is allergic to ${medication.name}',
        );
      }

      // Check medication side effects against patient allergies
      for (final sideEffect in medication.sideEffects) {
        if (sideEffect.toLowerCase().contains(allergy.toLowerCase()) ||
            allergy.toLowerCase().contains(sideEffect.toLowerCase())) {
          throw AllergicReactionException(
            'Patient may have allergic reaction to ${medication.name} '
            '(side effect: $sideEffect)',
          );
        }
      }
    }
  }
}

// Custom exceptions
class DoctorNotAssignedException implements Exception {
  final String message;
  DoctorNotAssignedException(this.message);
  @override
  String toString() => message;
}

class AllergicReactionException implements Exception {
  final String message;
  AllergicReactionException(this.message);
  @override
  String toString() => message;
}
