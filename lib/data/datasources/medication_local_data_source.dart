import 'local/json_data_source.dart';
import '../models/medication_model.dart';

/// Local data source for Medication entity
/// Provides specialized queries for medication data
class MedicationLocalDataSource extends JsonDataSource<MedicationModel> {
  MedicationLocalDataSource()
      : super(
          fileName: 'medications.json',
          fromJson: MedicationModel.fromJson,
        );

  /// Find medication by ID
  Future<MedicationModel?> findByMedicationId(String medicationId) {
    return findById(
      medicationId,
      (medication) => medication.id,
      (medication) => medication.toJson(),
    );
  }

  /// Check if medication exists
  Future<bool> medicationExists(String medicationId) {
    return exists(medicationId, (medication) => medication.id);
  }

  /// Find medications by IDs
  Future<List<MedicationModel>> findMedicationsByIds(
      List<String> medicationIds) async {
    if (medicationIds.isEmpty) return [];
    final allMedications = await readAll();
    return allMedications
        .where((medication) => medicationIds.contains(medication.id))
        .toList();
  }

  /// Find medications by name (partial match)
  Future<List<MedicationModel>> findMedicationsByName(String name) {
    final lowerCaseName = name.toLowerCase();
    return findWhere(
      (medication) => medication.name.toLowerCase().contains(lowerCaseName),
    );
  }

  /// Find medications by manufacturer
  Future<List<MedicationModel>> findMedicationsByManufacturer(
      String manufacturer) {
    final lowerCaseManufacturer = manufacturer.toLowerCase();
    return findWhere(
      (medication) =>
          medication.manufacturer.toLowerCase().contains(lowerCaseManufacturer),
    );
  }

  /// Find medications with specific side effect
  Future<List<MedicationModel>> findMedicationsWithSideEffect(
      String sideEffect) {
    final lowerCaseSideEffect = sideEffect.toLowerCase();
    return findWhere(
      (medication) => medication.sideEffects
          .any((effect) => effect.toLowerCase().contains(lowerCaseSideEffect)),
    );
  }
}
