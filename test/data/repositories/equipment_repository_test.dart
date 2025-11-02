import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_management/data/datasources/equipment_local_data_source.dart';
import 'package:hospital_management/data/models/equipment_model.dart';
import 'package:hospital_management/data/repositories/equipment_repository_impl.dart';
import 'package:hospital_management/domain/entities/equipment.dart';
import 'package:hospital_management/domain/entities/enums/equipment_status.dart';

void main() {
  late EquipmentRepositoryImpl repository;
  late EquipmentLocalDataSource mockDataSource;

  setUp(() async {
    mockDataSource = EquipmentLocalDataSource();
    repository = EquipmentRepositoryImpl(equipmentDataSource: mockDataSource);

    // Clear any existing data
    await mockDataSource.clear((e) => e.toJson());
  });

  group('EquipmentRepositoryImpl', () {
    final testEquipment = Equipment(
      equipmentId: 'EQ001',
      name: 'Test Equipment',
      type: 'Test Type',
      serialNumber: 'SN001',
      status: EquipmentStatus.OPERATIONAL,
      lastServiceDate: DateTime(2023, 1, 1),
      nextServiceDate: DateTime(2023, 12, 31),
    );

    test('saveEquipment should add new equipment when it does not exist',
        () async {
      await repository.saveEquipment(testEquipment);

      final saved =
          await repository.getEquipmentById(testEquipment.equipmentId);
      expect(saved.equipmentId, equals(testEquipment.equipmentId));
      expect(saved.name, equals(testEquipment.name));
      expect(saved.type, equals(testEquipment.type));
      expect(saved.status, equals(testEquipment.status));
    });

    test('saveEquipment should update existing equipment', () async {
      // First save
      await repository.saveEquipment(testEquipment);

      // Create updated equipment with same ID
      final updatedEquipment = Equipment(
        equipmentId: testEquipment.equipmentId,
        name: 'Updated Equipment',
        type: testEquipment.type,
        serialNumber: testEquipment.serialNumber,
        status: EquipmentStatus.IN_MAINTENANCE,
        lastServiceDate: testEquipment.lastServiceDate,
        nextServiceDate: testEquipment.nextServiceDate,
      );

      // Save updated version
      await repository.saveEquipment(updatedEquipment);

      // Verify update
      final saved =
          await repository.getEquipmentById(testEquipment.equipmentId);
      expect(saved.name, equals('Updated Equipment'));
      expect(saved.status, equals(EquipmentStatus.IN_MAINTENANCE));
    });

    test('deleteEquipment should remove equipment', () async {
      // First save
      await repository.saveEquipment(testEquipment);

      // Then delete
      await repository.deleteEquipment(testEquipment.equipmentId);

      // Verify deletion
      expect(
        () => repository.getEquipmentById(testEquipment.equipmentId),
        throwsException,
      );
    });

    test('searchEquipmentByName should return matching equipment', () async {
      // Save test equipment
      await repository.saveEquipment(testEquipment);

      // Search for partial name
      final results = await repository.searchEquipmentByName('Test');
      expect(results, isNotEmpty);
      expect(results.first.name, contains('Test'));
    });

    test('getEquipmentByType should return equipment of specified type',
        () async {
      // Save test equipment
      await repository.saveEquipment(testEquipment);

      // Search by type
      final results = await repository.getEquipmentByType(testEquipment.type);
      expect(results, isNotEmpty);
      expect(results.first.type, equals(testEquipment.type));
    });

    test('getEquipmentByStatus should return equipment with specified status',
        () async {
      // Save test equipment
      await repository.saveEquipment(testEquipment);

      // Search by status
      final results = await repository
          .getEquipmentByStatus(testEquipment.status.toString());
      expect(results, isNotEmpty);
      expect(results.first.status, equals(testEquipment.status));
    });

    test('getEquipmentNeedingService should return equipment needing service',
        () async {
      final serviceNeededEquipment = Equipment(
        equipmentId: 'EQ002',
        name: 'Service Needed Equipment',
        type: 'Test Type',
        serialNumber: 'SN002',
        status: EquipmentStatus.NEEDS_CALIBRATION,
        lastServiceDate: DateTime(2023, 1, 1),
        nextServiceDate:
            DateTime.now().add(const Duration(days: 15)), // Soon needs service
      );

      // Save equipment
      await repository.saveEquipment(serviceNeededEquipment);

      // Check for equipment needing service
      final results = await repository.getEquipmentNeedingService();
      expect(results, isNotEmpty);
      expect(results.first.equipmentId,
          equals(serviceNeededEquipment.equipmentId));
    });

    test('getAllEquipment should return all saved equipment', () async {
      // Save multiple equipment
      final equipment2 = Equipment(
        equipmentId: 'EQ002',
        name: 'Second Equipment',
        type: 'Test Type',
        serialNumber: 'SN002',
        status: EquipmentStatus.OPERATIONAL,
        lastServiceDate: DateTime(2023, 1, 1),
        nextServiceDate: DateTime(2023, 12, 31),
      );

      await repository.saveEquipment(testEquipment);
      await repository.saveEquipment(equipment2);

      // Get all equipment
      final allEquipment = await repository.getAllEquipment();
      expect(allEquipment.length, equals(2));
      expect(
        allEquipment.map((e) => e.equipmentId).toList(),
        containsAll([testEquipment.equipmentId, equipment2.equipmentId]),
      );
    });

    // Clean up after each test
    tearDown(() async {
      try {
        await repository.deleteEquipment(testEquipment.equipmentId);
      } catch (_) {}
    });
  });
}
