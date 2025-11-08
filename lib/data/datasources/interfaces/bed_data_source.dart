import '../../models/bed_model.dart';

/// Abstract interface for Bed data source operations
abstract class BedDataSource {
  /// Read all beds
  Future<List<BedModel>> readAll();

  /// Add a new bed
  Future<void> add(
    BedModel bed,
    String Function(BedModel) getId,
    Map<String, dynamic> Function(BedModel) toJson,
  );

  /// Update an existing bed
  Future<void> update(
    String id,
    BedModel bed,
    String Function(BedModel) getId,
    Map<String, dynamic> Function(BedModel) toJson,
  );

  /// Delete a bed
  Future<void> delete(
    String id,
    String Function(BedModel) getId,
    Map<String, dynamic> Function(BedModel) toJson,
  );

  /// Find a bed by bed number
  Future<BedModel?> findByBedNumber(String bedNumber);

  /// Check if a bed exists
  Future<bool> bedExists(String bedNumber);

  /// Find beds by IDs
  Future<List<BedModel>> findBedsByIds(List<String> bedIds);

  /// Find occupied beds
  Future<List<BedModel>> findOccupiedBeds();

  /// Find available beds
  Future<List<BedModel>> findAvailableBeds();

  /// Find bed by patient ID
  Future<BedModel?> findBedByPatientId(String patientId);

  /// Find beds by type
  Future<List<BedModel>> findBedsByType(String bedType);
}
