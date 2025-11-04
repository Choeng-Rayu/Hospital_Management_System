import '../entities/equipment.dart';

/// Repository interface for Equipment entity
/// Defines operations for managing equipment data
abstract class EquipmentRepository {
  /// Get equipment by ID
  Future<Equipment> getEquipmentById(String equipmentId);

  /// Get all equipment
  Future<List<Equipment>> getAllEquipment();

  /// Save equipment (creates if it doesn't exist, updates if it does)
  Future<void> saveEquipment(Equipment equipment);

  /// Update existing equipment
  Future<void> updateEquipment(Equipment equipment);

  /// Delete equipment by ID
  Future<void> deleteEquipment(String equipmentId);

  /// Search equipment by name (partial match)
  Future<List<Equipment>> searchEquipmentByName(String name);

  /// Get equipment by type
  Future<List<Equipment>> getEquipmentByType(String type);

  /// Get equipment by status
  Future<List<Equipment>> getEquipmentByStatus(String status);

  /// Get equipment needing service
  Future<List<Equipment>> getEquipmentNeedingService();

  /// Check if equipment exists by ID
  Future<bool> equipmentExists(String equipmentId);
}
