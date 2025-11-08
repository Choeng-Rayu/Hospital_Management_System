import '../../models/equipment_model.dart';

/// Abstract interface for Equipment data source operations
abstract class EquipmentDataSource {
  /// Read all equipment
  Future<List<EquipmentModel>> readAll();

  /// Add new equipment
  Future<void> add(
    EquipmentModel equipment,
    String Function(EquipmentModel) getId,
    Map<String, dynamic> Function(EquipmentModel) toJson,
  );

  /// Update existing equipment
  Future<void> update(
    String id,
    EquipmentModel equipment,
    String Function(EquipmentModel) getId,
    Map<String, dynamic> Function(EquipmentModel) toJson,
  );

  /// Delete equipment
  Future<void> delete(
    String id,
    String Function(EquipmentModel) getId,
    Map<String, dynamic> Function(EquipmentModel) toJson,
  );

  /// Find equipment by ID
  Future<EquipmentModel?> findByEquipmentId(String equipmentId);

  /// Check if equipment exists
  Future<bool> equipmentExists(String equipmentId);

  /// Find equipment by IDs
  Future<List<EquipmentModel>> findEquipmentByIds(List<String> equipmentIds);

  /// Find equipment by type
  Future<List<EquipmentModel>> findEquipmentByType(String type);

  /// Find equipment by status
  Future<List<EquipmentModel>> findEquipmentByStatus(String status);

  /// Find equipment needing service (next service date is in the past or near future)
  Future<List<EquipmentModel>> findEquipmentNeedingService();

  /// Find equipment by name (partial match)
  Future<List<EquipmentModel>> findEquipmentByName(String name);
}
