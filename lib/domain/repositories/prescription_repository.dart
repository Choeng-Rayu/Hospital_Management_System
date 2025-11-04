import '../entities/prescription.dart';

/// Repository interface for Prescription entity
/// Defines all data operations needed for prescription management
abstract class PrescriptionRepository {
  Future<Prescription> getPrescriptionById(String prescriptionId);

  Future<List<Prescription>> getAllPrescriptions();

  Future<void> savePrescription(Prescription prescription);

  /// Update an existing prescription's information
  Future<void> updatePrescription(Prescription prescription);

  Future<void> deletePrescription(String prescriptionId);

  Future<List<Prescription>> getPrescriptionsByPatient(String patientId);

  Future<List<Prescription>> getPrescriptionsByDoctor(String doctorId);

  /// Get recent prescriptions (within last 30 days)
  Future<List<Prescription>> getRecentPrescriptions();

  /// Get active prescriptions for a patient
  Future<List<Prescription>> getActivePrescriptionsByPatient(String patientId);

  /// Check if a prescription exists
  Future<bool> prescriptionExists(String prescriptionId);
}
