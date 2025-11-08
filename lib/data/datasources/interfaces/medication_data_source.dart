import '../../models/medication_model.dart';

/// Abstract interface for Medication data source operations
abstract class MedicationDataSource {
  /// Read all medications
  Future<List<MedicationModel>> readAll();

  /// Add a new medication
  Future<void> add(
    MedicationModel medication,
    String Function(MedicationModel) getId,
    Map<String, dynamic> Function(MedicationModel) toJson,
  );

  /// Update an existing medication
  Future<void> update(
    String id,
    MedicationModel medication,
    String Function(MedicationModel) getId,
    Map<String, dynamic> Function(MedicationModel) toJson,
  );

  /// Delete a medication
  Future<void> delete(
    String id,
    String Function(MedicationModel) getId,
    Map<String, dynamic> Function(MedicationModel) toJson,
  );

  /// Find medication by ID
  Future<MedicationModel?> findByMedicationId(String medicationId);

  /// Check if medication exists
  Future<bool> medicationExists(String medicationId);

  /// Find medications by IDs
  Future<List<MedicationModel>> findMedicationsByIds(List<String> medicationIds);

  /// Find medications by name (partial match)
  Future<List<MedicationModel>> findMedicationsByName(String name);

  /// Find medications by manufacturer
  Future<List<MedicationModel>> findMedicationsByManufacturer(String manufacturer);

  /// Find medications with specific side effect
  Future<List<MedicationModel>> findMedicationsWithSideEffect(String sideEffect);
}
