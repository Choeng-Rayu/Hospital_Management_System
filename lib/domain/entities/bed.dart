import 'dart:collection';
import 'enums/bed_type.dart';
import 'patient.dart';

class Bed {
  final String _bedNumber;
  final BedType _bedType;
  bool _isOccupied;
  Patient? _currentPatient; // Nullable since bed might be empty
  final List<String> _features;

  String get bedNumber => _bedNumber;
  BedType get bedType => _bedType;
  bool get isOccupied => _isOccupied;
  Patient? get currentPatient => _currentPatient;
  UnmodifiableListView<String> get features => UnmodifiableListView(_features);
  bool get isAvailable => !_isOccupied;

  Bed({
    required String bedNumber,
    required BedType bedType,
    bool isOccupied = false,
    Patient? patient,
    required List<String> features,
  })  : _bedNumber = bedNumber,
        _bedType = bedType,
        _isOccupied = isOccupied,
        _currentPatient = patient,
        _features = List.from(features) {
    _validateBed();
  }

  void _validateBed() {
    if (_bedNumber.trim().isEmpty) {
      throw ArgumentError('Bed number cannot be empty');
    }
  }

  // Assign patient to bed
  void assignPatient(Patient patient) {
    _currentPatient = patient;
    _isOccupied = true;
  }

  // Remove patient from bed
  void removePatient() {
    _currentPatient = null;
    _isOccupied = false;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bed &&
          runtimeType == other.runtimeType &&
          _bedNumber == other._bedNumber;

  @override
  int get hashCode => _bedNumber.hashCode;

  @override
  String toString() =>
      'Bed(number: $_bedNumber, type: $_bedType, occupied: $_isOccupied)';
}
