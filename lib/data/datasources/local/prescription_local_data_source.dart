import 'json_data_source.dart';
import '../../models/prescription_model.dart';
import '../interfaces/prescription_data_source.dart';

/// Local data source for Prescription entity
/// Provides specialized queries for prescription data
class PrescriptionLocalDataSource extends JsonDataSource<PrescriptionModel>
    implements PrescriptionDataSource {
  PrescriptionLocalDataSource()
      : super(
          fileName: 'prescriptions.json',
          fromJson: PrescriptionModel.fromJson,
        );

  /// Find a prescription by prescription ID
  Future<PrescriptionModel?> findByPrescriptionId(String prescriptionId) {
    return findById(
      prescriptionId,
      (prescription) => prescription.id,
      (prescription) => prescription.toJson(),
    );
  }

  /// Check if a prescription exists
  Future<bool> prescriptionExists(String prescriptionId) {
    return exists(prescriptionId, (prescription) => prescription.id);
  }

  /// Find prescriptions by patient ID
  Future<List<PrescriptionModel>> findPrescriptionsByPatientId(
      String patientId) {
    return findWhere((prescription) => prescription.patientId == patientId);
  }

  /// Find prescriptions by doctor ID
  Future<List<PrescriptionModel>> findPrescriptionsByDoctorId(String doctorId) {
    return findWhere((prescription) => prescription.doctorId == doctorId);
  }

  /// Find prescriptions by medication ID
  Future<List<PrescriptionModel>> findPrescriptionsByMedicationId(
      String medicationId) {
    return findWhere(
        (prescription) => prescription.medicationIds.contains(medicationId));
  }

  /// Find recent prescriptions (within last 30 days)
  Future<List<PrescriptionModel>> findRecentPrescriptions() async {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    return findWhere((prescription) {
      final prescriptionDate = DateTime.parse(prescription.time);
      return prescriptionDate.isAfter(thirtyDaysAgo);
    });
  }

  /// Find active prescriptions for a patient (within last 90 days)
  Future<List<PrescriptionModel>> findActivePrescriptionsByPatientId(
      String patientId) async {
    final now = DateTime.now();
    final ninetyDaysAgo = now.subtract(const Duration(days: 90));

    return findWhere((prescription) {
      final prescriptionDate = DateTime.parse(prescription.time);
      return prescription.patientId == patientId &&
          prescriptionDate.isAfter(ninetyDaysAgo);
    });
  }

  /// Find prescriptions created on a specific date
  Future<List<PrescriptionModel>> findPrescriptionsByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return findWhere((prescription) {
      final prescriptionDate = DateTime.parse(prescription.time);
      return prescriptionDate.isAfter(startOfDay) &&
          prescriptionDate.isBefore(endOfDay);
    });
  }

  /// Find prescriptions created between two dates
  Future<List<PrescriptionModel>> findPrescriptionsBetweenDates(
      DateTime startDate, DateTime endDate) async {
    return findWhere((prescription) {
      final prescriptionDate = DateTime.parse(prescription.time);
      return prescriptionDate.isAfter(startDate) &&
          prescriptionDate.isBefore(endDate);
    });
  }

  /// Find prescriptions with specific instructions (case-insensitive partial match)
  Future<List<PrescriptionModel>> findPrescriptionsByInstructions(
      String instructions) {
    final lowerCaseInstructions = instructions.toLowerCase();
    return findWhere(
      (prescription) => prescription.instructions
          .toLowerCase()
          .contains(lowerCaseInstructions),
    );
  }
}
