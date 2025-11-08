import '../../domain/entities/equipment.dart';
import '../../domain/repositories/equipment_repository.dart';
import 'package:hospital_management/data/datasources/local/equipment_local_data_source.dart';
import '../models/equipment_model.dart';

/// Implementation of EquipmentRepository using local JSON data source
class EquipmentRepositoryImpl implements EquipmentRepository {
  final EquipmentLocalDataSource _equipmentDataSource;

  EquipmentRepositoryImpl({
    required EquipmentLocalDataSource equipmentDataSource,
  }) : _equipmentDataSource = equipmentDataSource;

  @override
  Future<Equipment> getEquipmentById(String equipmentId) async {
    final model = await _equipmentDataSource.findByEquipmentId(equipmentId);
    if (model == null) {
      throw Exception('Equipment with ID $equipmentId not found');
    }
    return model.toEntity();
  }

  @override
  Future<List<Equipment>> getAllEquipment() async {
    final models = await _equipmentDataSource.readAll();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> saveEquipment(Equipment equipment) async {
    final model = EquipmentModel.fromEntity(equipment);
    final exists =
        await _equipmentDataSource.equipmentExists(equipment.equipmentId);

    if (exists) {
      await _equipmentDataSource.update(
        equipment.equipmentId,
        model,
        (e) => e.equipmentId,
        (e) => e.toJson(),
      );
    } else {
      await _equipmentDataSource.add(
        model,
        (e) => e.equipmentId,
        (e) => e.toJson(),
      );
    }
  }

  @override
  Future<void> updateEquipment(Equipment equipment) async {
    final model = EquipmentModel.fromEntity(equipment);
    final exists =
        await _equipmentDataSource.equipmentExists(equipment.equipmentId);

    if (!exists) {
      throw Exception(
          'Equipment with ID ${equipment.equipmentId} not found for update');
    }

    await _equipmentDataSource.update(
      equipment.equipmentId,
      model,
      (e) => e.equipmentId,
      (e) => e.toJson(),
    );
  }

  @override
  Future<void> deleteEquipment(String equipmentId) async {
    await _equipmentDataSource.delete(
      equipmentId,
      (e) => e.equipmentId,
      (e) => e.toJson(),
    );
  }

  @override
  Future<List<Equipment>> searchEquipmentByName(String name) async {
    final models = await _equipmentDataSource.findEquipmentByName(name);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Equipment>> getEquipmentByType(String type) async {
    final models = await _equipmentDataSource.findEquipmentByType(type);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Equipment>> getEquipmentByStatus(String status) async {
    final models = await _equipmentDataSource.findEquipmentByStatus(status);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Equipment>> getEquipmentNeedingService() async {
    final models = await _equipmentDataSource.findEquipmentNeedingService();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<bool> equipmentExists(String equipmentId) async {
    return await _equipmentDataSource.equipmentExists(equipmentId);
  }
}
