import '../../models/prescription_model.dart';

/// Abstract interface for Prescription data source operations
abstract class PrescriptionDataSource {
  /// Read all prescriptions
  Future<List<PrescriptionModel>> readAll();

  /// Add a new prescription
  Future<void> add(
    PrescriptionModel prescription,
    String Function(PrescriptionModel) getId,
    Map<String, dynamic> Function(PrescriptionModel) toJson,
  );

  /// Update an existing prescription
  Future<void> update(
    String id,
    PrescriptionModel prescription,
    String Function(PrescriptionModel) getId,
    Map<String, dynamic> Function(PrescriptionModel) toJson,
  );

  /// Delete a prescription
  Future<void> delete(
    String id,
    String Function(PrescriptionModel) getId,
    Map<String, dynamic> Function(PrescriptionModel) toJson,
  );

  /// Find a prescription by prescription ID
  Future<PrescriptionModel?> findByPrescriptionId(String prescriptionId);

  /// Check if a prescription exists
  Future<bool> prescriptionExists(String prescriptionId);

  /// Find prescriptions by patient ID
  Future<List<PrescriptionModel>> findPrescriptionsByPatientId(String patientId);

  /// Find prescriptions by doctor ID
  Future<List<PrescriptionModel>> findPrescriptionsByDoctorId(String doctorId);

  /// Find prescriptions by medication ID
  Future<List<PrescriptionModel>> findPrescriptionsByMedicationId(
      String medicationId);

  /// Find recent prescriptions (within last 30 days)
  Future<List<PrescriptionModel>> findRecentPrescriptions();

  /// Find active prescriptions for a patient (within last 90 days)
  Future<List<PrescriptionModel>> findActivePrescriptionsByPatientId(
      String patientId);

  /// Find prescriptions created on a specific date
  Future<List<PrescriptionModel>> findPrescriptionsByDate(DateTime date);

  /// Find prescriptions created between two dates
  Future<List<PrescriptionModel>> findPrescriptionsBetweenDates(
      DateTime startDate, DateTime endDate);

  /// Find prescriptions with specific instructions (case-insensitive partial match)
  Future<List<PrescriptionModel>> findPrescriptionsByInstructions(
      String instructions);
}
