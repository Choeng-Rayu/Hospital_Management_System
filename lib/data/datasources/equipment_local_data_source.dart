import 'local/json_data_source.dart';
import '../models/equipment_model.dart';

/// Local data source for Equipment entity
/// Provides specialized queries for equipment data
class EquipmentLocalDataSource extends JsonDataSource<EquipmentModel> {
  EquipmentLocalDataSource()
      : super(
          fileName: 'equipment.json',
          fromJson: EquipmentModel.fromJson,
        );

  /// Find equipment by ID
  Future<EquipmentModel?> findByEquipmentId(String equipmentId) {
    return findById(
      equipmentId,
      (equipment) => equipment.equipmentId,
      (equipment) => equipment.toJson(),
    );
  }

  /// Check if equipment exists
  Future<bool> equipmentExists(String equipmentId) {
    return exists(equipmentId, (equipment) => equipment.equipmentId);
  }

  /// Find equipment by IDs
  Future<List<EquipmentModel>> findEquipmentByIds(
      List<String> equipmentIds) async {
    if (equipmentIds.isEmpty) return [];
    final allEquipment = await readAll();
    return allEquipment
        .where((equipment) => equipmentIds.contains(equipment.equipmentId))
        .toList();
  }

  /// Find equipment by type
  Future<List<EquipmentModel>> findEquipmentByType(String type) {
    return findWhere((equipment) => equipment.type == type);
  }

  /// Find equipment by status
  Future<List<EquipmentModel>> findEquipmentByStatus(String status) {
    return findWhere((equipment) => equipment.status == status);
  }

  /// Find equipment needing service (next service date is in the past or near future)
  Future<List<EquipmentModel>> findEquipmentNeedingService() async {
    final now = DateTime.now();
    final threshold = now.add(const Duration(days: 30)); // 30 days in advance

    return findWhere((equipment) {
      final nextServiceDate = DateTime.parse(equipment.nextServiceDate);
      return nextServiceDate.isBefore(threshold);
    });
  }

  /// Find equipment by name (partial match)
  Future<List<EquipmentModel>> findEquipmentByName(String name) {
    final lowerCaseName = name.toLowerCase();
    return findWhere(
      (equipment) => equipment.name.toLowerCase().contains(lowerCaseName),
    );
  }
}
