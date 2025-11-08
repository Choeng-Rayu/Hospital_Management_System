import 'dart:collection';
import 'enums/room_type.dart';
import 'enums/room_status.dart';
import 'enums/equipment_status.dart';
import 'equipment.dart';
import 'bed.dart';
import 'patient.dart';

class Room {
  final String _roomId;
  final String _number;
  final RoomType _roomType;
  RoomStatus _status;
  final List<Equipment> _equipment;
  final List<Bed> _beds;

  String get roomId => _roomId;
  String get number => _number;
  RoomType get roomType => _roomType;
  RoomStatus get status => _status;
  UnmodifiableListView<Equipment> get equipment =>
      UnmodifiableListView(_equipment);
  UnmodifiableListView<Bed> get beds => UnmodifiableListView(_beds);

  Room({
    required String roomId,
    required String number,
    required RoomType roomType,
    required RoomStatus status,
    required List<Equipment> equipment,
    required List<Bed> beds,
  })  : _roomId = roomId,
        _number = number,
        _roomType = roomType,
        _status = status,
        _equipment = List.from(equipment),
        _beds = List.from(beds) {
    _validateRoom();
  }

  void _validateRoom() {
    if (_roomId.trim().isEmpty) {
      throw ArgumentError('Room ID cannot be empty');
    }
    if (_number.trim().isEmpty) {
      throw ArgumentError('Room number cannot be empty');
    }
  }

  // Get available beds in the room
  UnmodifiableListView<Bed> getAvailableBeds() {
    return UnmodifiableListView(_beds.where((bed) => bed.isAvailable));
  }

  // Check if room has any available beds
  bool get hasAvailableBeds => _beds.any((bed) => bed.isAvailable);

  // Get count of available beds
  int get availableBedCount => _beds.where((bed) => bed.isAvailable).length;

  // Update room status
  void updateStatus(RoomStatus newStatus) {
    _status = newStatus;
  }

  // Equipment management methods
  void addEquipment(Equipment newEquipment) {
    _equipment.add(newEquipment);
  }

  void removeEquipment(String equipmentId) {
    _equipment.removeWhere((equipment) => equipment.equipmentId == equipmentId);
  }

  UnmodifiableListView<Equipment> getOperationalEquipment() {
    return UnmodifiableListView(_equipment
        .where((equipment) => equipment.status == EquipmentStatus.OPERATIONAL));
  }

  // Bed and patient management methods
  bool assignPatientToBed(Patient patient, String bedNumber) {
    var bed = _beds.firstWhere(
      (b) => b.bedNumber == bedNumber && b.isAvailable,
      orElse: () =>
          throw ArgumentError('No available bed found with number $bedNumber'),
    );

    patient.assignToBed(this, bed);
    return true;
  }

  void dischargePatient(Patient patient) {
    _beds.firstWhere(
      (b) => b.currentPatient == patient,
      orElse: () => throw ArgumentError('Patient not found in any bed'),
    );

    patient.discharge();
  }

  // Get all patients currently in the room
  UnmodifiableListView<Patient> get currentPatients =>
      UnmodifiableListView(_beds
          .where((bed) => !bed.isAvailable)
          .map((bed) => bed.currentPatient!)
          .toList());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Room &&
          runtimeType == other.runtimeType &&
          _roomId == other._roomId;

  @override
  int get hashCode => _roomId.hashCode;

  @override
  String toString() =>
      'Room(roomId: $_roomId, number: $_number, type: $_roomType, status: $_status)';
}
