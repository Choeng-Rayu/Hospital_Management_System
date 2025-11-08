import 'enums/equipment_status.dart';

class Equipment {
  final String _equipmentId;
  final String _name;
  final String _type;
  final String _serialNumber;
  EquipmentStatus _status;
  final DateTime _lastServiceDate;
  final DateTime _nextServiceDate;

  String get equipmentId => _equipmentId;
  String get name => _name;
  String get type => _type;
  String get serialNumber => _serialNumber;
  EquipmentStatus get status => _status;
  DateTime get lastServiceDate => _lastServiceDate;
  DateTime get nextServiceDate => _nextServiceDate;

  Equipment({
    required String equipmentId,
    required String name,
    required String type,
    required String serialNumber,
    required EquipmentStatus status,
    required DateTime lastServiceDate,
    required DateTime nextServiceDate,
  })  : _equipmentId = equipmentId,
        _name = name,
        _type = type,
        _serialNumber = serialNumber,
        _status = status,
        _lastServiceDate = lastServiceDate,
        _nextServiceDate = nextServiceDate {
    _validateEquipment();
  }

  void _validateEquipment() {
    if (_equipmentId.trim().isEmpty) {
      throw ArgumentError('Equipment ID cannot be empty');
    }
    if (_name.trim().isEmpty) {
      throw ArgumentError('Name cannot be empty');
    }
    if (_type.trim().isEmpty) {
      throw ArgumentError('Type cannot be empty');
    }
    if (_serialNumber.trim().isEmpty) {
      throw ArgumentError('Serial number cannot be empty');
    }
    if (_nextServiceDate.isBefore(_lastServiceDate)) {
      throw ArgumentError('Next service date must be after last service date');
    }
  }

  void reportMaintenance() {
    _status = EquipmentStatus.IN_MAINTENANCE;
  }

  void updateStatus(EquipmentStatus newStatus) {
    _status = newStatus;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Equipment &&
          runtimeType == other.runtimeType &&
          _equipmentId == other._equipmentId;

  @override
  int get hashCode => _equipmentId.hashCode;

  @override
  String toString() =>
      'Equipment(id: $_equipmentId, name: $_name, status: $_status)';
}
