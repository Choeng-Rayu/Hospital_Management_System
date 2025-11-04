import '../../domain/repositories/nurse_repository.dart';
import '../../domain/entities/nurse.dart';
import '../../domain/entities/patient.dart';
import '../../domain/entities/room.dart';
import '../datasources/nurse_local_data_source.dart';
import '../datasources/patient_local_data_source.dart';
import '../datasources/room_local_data_source.dart';
import '../datasources/bed_local_data_source.dart';
import '../datasources/equipment_local_data_source.dart';
import '../models/nurse_model.dart';

/// Implementation of NurseRepository using local JSON data sources
class NurseRepositoryImpl implements NurseRepository {
  final NurseLocalDataSource _nurseDataSource;
  final PatientLocalDataSource _patientDataSource;
  final RoomLocalDataSource _roomDataSource;
  final BedLocalDataSource _bedDataSource;
  final EquipmentLocalDataSource _equipmentDataSource;

  NurseRepositoryImpl({
    required NurseLocalDataSource nurseDataSource,
    required PatientLocalDataSource patientDataSource,
    required RoomLocalDataSource roomDataSource,
    required BedLocalDataSource bedDataSource,
    required EquipmentLocalDataSource equipmentDataSource,
  })  : _nurseDataSource = nurseDataSource,
        _patientDataSource = patientDataSource,
        _roomDataSource = roomDataSource,
        _bedDataSource = bedDataSource,
        _equipmentDataSource = equipmentDataSource;

  @override
  Future<Nurse> getNurseById(String staffId) async {
    final model = await _nurseDataSource.findByStaffId(staffId);
    if (model == null) {
      throw Exception('Nurse with ID $staffId not found');
    }

    // Fetch related entities
    final rooms = await _getRoomEntities(model.assignedRoomIds);
    final patients = await _getPatientEntities(model.assignedPatientIds);

    return model.toEntity(
      assignedRooms: rooms,
      assignedPatients: patients,
    );
  }

  @override
  Future<List<Nurse>> getAllNurses() async {
    final models = await _nurseDataSource.readAll();
    final List<Nurse> nurses = [];

    for (final model in models) {
      final rooms = await _getRoomEntities(model.assignedRoomIds);
      final patients = await _getPatientEntities(model.assignedPatientIds);

      nurses.add(model.toEntity(
        assignedRooms: rooms,
        assignedPatients: patients,
      ));
    }

    return nurses;
  }

  @override
  Future<void> saveNurse(Nurse nurse) async {
    final model = NurseModel.fromEntity(nurse);

    // Check if nurse exists
    final exists = await _nurseDataSource.nurseExists(nurse.staffID);

    if (exists) {
      await _nurseDataSource.update(
        nurse.staffID,
        model,
        (n) => n.staffID,
        (n) => n.toJson(),
      );
    } else {
      await _nurseDataSource.add(
        model,
        (n) => n.staffID,
        (n) => n.toJson(),
      );
    }
  }

  @override
  Future<void> updateNurse(Nurse nurse) async {
    final model = NurseModel.fromEntity(nurse);

    // Check if nurse exists
    final exists = await _nurseDataSource.nurseExists(nurse.staffID);

    if (!exists) {
      throw Exception('Nurse with ID ${nurse.staffID} not found for update');
    }

    await _nurseDataSource.update(
      nurse.staffID,
      model,
      (n) => n.staffID,
      (n) => n.toJson(),
    );
  }

  @override
  Future<void> deleteNurse(String staffId) async {
    await _nurseDataSource.delete(
      staffId,
      (n) => n.staffID,
      (n) => n.toJson(),
    );
  }

  @override
  Future<List<Nurse>> searchNursesByName(String name) async {
    final models = await _nurseDataSource.findNursesByName(name);
    final List<Nurse> nurses = [];

    for (final model in models) {
      final rooms = await _getRoomEntities(model.assignedRoomIds);
      final patients = await _getPatientEntities(model.assignedPatientIds);

      nurses.add(model.toEntity(
        assignedRooms: rooms,
        assignedPatients: patients,
      ));
    }

    return nurses;
  }

  @override
  Future<List<Nurse>> getNursesByRoom(String roomId) async {
    final models = await _nurseDataSource.findNursesByRoomId(roomId);
    final List<Nurse> nurses = [];

    for (final model in models) {
      final rooms = await _getRoomEntities(model.assignedRoomIds);
      final patients = await _getPatientEntities(model.assignedPatientIds);

      nurses.add(model.toEntity(
        assignedRooms: rooms,
        assignedPatients: patients,
      ));
    }

    return nurses;
  }

  @override
  Future<List<Nurse>> getAvailableNurses() async {
    final models = await _nurseDataSource.findAvailableNurses();
    final List<Nurse> nurses = [];

    for (final model in models) {
      final rooms = await _getRoomEntities(model.assignedRoomIds);
      final patients = await _getPatientEntities(model.assignedPatientIds);

      nurses.add(model.toEntity(
        assignedRooms: rooms,
        assignedPatients: patients,
      ));
    }

    return nurses;
  }

  @override
  Future<List<Patient>> getNursePatients(String nurseId) async {
    final nurse = await getNurseById(nurseId);
    return nurse.assignedPatients;
  }

  @override
  Future<List<Room>> getNurseRooms(String nurseId) async {
    final nurse = await getNurseById(nurseId);
    return nurse.assignedRooms;
  }

  @override
  Future<bool> nurseExists(String staffId) async {
    return await _nurseDataSource.nurseExists(staffId);
  }

  /// Helper method to convert room IDs to Room entities
  Future<List<Room>> _getRoomEntities(List<String> roomIds) async {
    if (roomIds.isEmpty) return [];

    final List<Room> rooms = [];
    for (final roomId in roomIds) {
      try {
        final roomModel = await _roomDataSource.findByRoomId(roomId);
        if (roomModel != null) {
          final equipment = await _equipmentDataSource
              .findEquipmentByIds(roomModel.equipmentIds);
          final beds = await _bedDataSource.findBedsByIds(roomModel.bedIds);

          rooms.add(roomModel.toEntity(
            equipment: equipment.map((e) => e.toEntity()).toList(),
            beds: beds.map((b) => b.toEntity()).toList(),
          ));
        }
      } catch (e) {
        // Skip rooms that can't be found
        continue;
      }
    }

    return rooms;
  }

  /// Helper method to convert patient IDs to Patient entities
  Future<List<Patient>> _getPatientEntities(List<String> patientIds) async {
    if (patientIds.isEmpty) return [];

    final List<Patient> patients = [];
    for (final patientId in patientIds) {
      try {
        final patientModel =
            await _patientDataSource.findByPatientID(patientId);
        if (patientModel != null) {
          // Note: Simplified - not fetching assigned doctors to avoid circular dependencies
          patients.add(patientModel.toEntity(assignedDoctors: []));
        }
      } catch (e) {
        // Skip patients that can't be found
        continue;
      }
    }

    return patients;
  }
}
