import '../../domain/repositories/room_repository.dart';
import '../../domain/entities/room.dart';
import '../../domain/entities/patient.dart';
import '../../domain/entities/bed.dart';
import '../../domain/entities/enums/room_type.dart';
import '../../domain/entities/enums/room_status.dart';
import '../datasources/room_local_data_source.dart';
import '../datasources/bed_local_data_source.dart';
import '../datasources/equipment_local_data_source.dart';
import '../datasources/patient_local_data_source.dart';
import '../models/room_model.dart';

/// Implementation of RoomRepository using local JSON data sources
class RoomRepositoryImpl implements RoomRepository {
  final RoomLocalDataSource _roomDataSource;
  final BedLocalDataSource _bedDataSource;
  final EquipmentLocalDataSource _equipmentDataSource;
  final PatientLocalDataSource _patientDataSource;

  RoomRepositoryImpl({
    required RoomLocalDataSource roomDataSource,
    required BedLocalDataSource bedDataSource,
    required EquipmentLocalDataSource equipmentDataSource,
    required PatientLocalDataSource patientDataSource,
  })  : _roomDataSource = roomDataSource,
        _bedDataSource = bedDataSource,
        _equipmentDataSource = equipmentDataSource,
        _patientDataSource = patientDataSource;

  @override
  Future<Room> getRoomById(String roomId) async {
    final model = await _roomDataSource.findByRoomId(roomId);
    if (model == null) {
      throw Exception('Room with ID $roomId not found');
    }

    // Fetch related entities
    final equipment =
        await _equipmentDataSource.findEquipmentByIds(model.equipmentIds);
    final beds = await _bedDataSource.findBedsByIds(model.bedIds);

    return model.toEntity(
      equipment: equipment.map((e) => e.toEntity()).toList(),
      beds: beds.map((b) => b.toEntity()).toList(),
    );
  }

  @override
  Future<List<Room>> getAllRooms() async {
    final models = await _roomDataSource.readAll();
    final List<Room> rooms = [];

    for (final model in models) {
      final equipment =
          await _equipmentDataSource.findEquipmentByIds(model.equipmentIds);
      final beds = await _bedDataSource.findBedsByIds(model.bedIds);

      rooms.add(model.toEntity(
        equipment: equipment.map((e) => e.toEntity()).toList(),
        beds: beds.map((b) => b.toEntity()).toList(),
      ));
    }

    return rooms;
  }

  @override
  Future<void> saveRoom(Room room) async {
    final model = RoomModel.fromEntity(room);

    // Check if room exists
    final exists = await _roomDataSource.roomExists(room.roomId);

    if (exists) {
      await _roomDataSource.update(
        room.roomId,
        model,
        (r) => r.roomId,
        (r) => r.toJson(),
      );
    } else {
      await _roomDataSource.add(
        model,
        (r) => r.roomId,
        (r) => r.toJson(),
      );
    }
  }

  @override
  Future<void> updateRoom(Room room) async {
    final model = RoomModel.fromEntity(room);

    // Check if room exists
    final exists = await _roomDataSource.roomExists(room.roomId);

    if (!exists) {
      throw Exception('Room with ID ${room.roomId} not found for update');
    }

    await _roomDataSource.update(
      room.roomId,
      model,
      (r) => r.roomId,
      (r) => r.toJson(),
    );
  }

  @override
  Future<void> deleteRoom(String roomId) async {
    await _roomDataSource.delete(
      roomId,
      (r) => r.roomId,
      (r) => r.toJson(),
    );
  }

  @override
  Future<List<Room>> getRoomsByType(RoomType type) async {
    final models = await _roomDataSource.findRoomsByType(type.toString());
    final List<Room> rooms = [];

    for (final model in models) {
      final equipment =
          await _equipmentDataSource.findEquipmentByIds(model.equipmentIds);
      final beds = await _bedDataSource.findBedsByIds(model.bedIds);

      rooms.add(model.toEntity(
        equipment: equipment.map((e) => e.toEntity()).toList(),
        beds: beds.map((b) => b.toEntity()).toList(),
      ));
    }

    return rooms;
  }

  @override
  Future<List<Room>> getRoomsByStatus(RoomStatus status) async {
    final models = await _roomDataSource.findRoomsByStatus(status.toString());
    final List<Room> rooms = [];

    for (final model in models) {
      final equipment =
          await _equipmentDataSource.findEquipmentByIds(model.equipmentIds);
      final beds = await _bedDataSource.findBedsByIds(model.bedIds);

      rooms.add(model.toEntity(
        equipment: equipment.map((e) => e.toEntity()).toList(),
        beds: beds.map((b) => b.toEntity()).toList(),
      ));
    }

    return rooms;
  }

  @override
  Future<List<Room>> getAvailableRooms() async {
    final models = await _roomDataSource.findAvailableRooms();
    final List<Room> rooms = [];

    for (final model in models) {
      final equipment =
          await _equipmentDataSource.findEquipmentByIds(model.equipmentIds);
      final beds = await _bedDataSource.findBedsByIds(model.bedIds);

      // Only include rooms with at least one available bed
      final bedEntities = beds.map((b) => b.toEntity()).toList();
      final hasAvailableBed = bedEntities.any((bed) => !bed.isOccupied);

      if (hasAvailableBed) {
        rooms.add(model.toEntity(
          equipment: equipment.map((e) => e.toEntity()).toList(),
          beds: bedEntities,
        ));
      }
    }

    return rooms;
  }

  @override
  Future<Room> getRoomByNumber(String number) async {
    final model = await _roomDataSource.findByRoomNumber(number);
    if (model == null) {
      throw Exception('Room with number $number not found');
    }

    // Fetch related entities
    final equipment =
        await _equipmentDataSource.findEquipmentByIds(model.equipmentIds);
    final beds = await _bedDataSource.findBedsByIds(model.bedIds);

    return model.toEntity(
      equipment: equipment.map((e) => e.toEntity()).toList(),
      beds: beds.map((b) => b.toEntity()).toList(),
    );
  }

  @override
  Future<List<Patient>> getRoomPatients(String roomId) async {
    final patientModels = await _patientDataSource.findPatientsByRoomId(roomId);
    final List<Patient> patients = [];

    for (final model in patientModels) {
      // Note: This is a simplified version - in full implementation,
      // you'd need to fetch assigned doctors for each patient
      patients.add(model.toEntity(assignedDoctors: []));
    }

    return patients;
  }

  @override
  Future<List<Bed>> getRoomBeds(String roomId) async {
    final room = await getRoomById(roomId);
    return room.beds;
  }

  @override
  Future<bool> roomExists(String roomId) async {
    return await _roomDataSource.roomExists(roomId);
  }
}
