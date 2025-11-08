import 'dart:collection';

class Medication {
  final String _id;
  final String _name;
  final String _dosage;
  final String _manufacturer;
  final List<String> _sideEffects;

  String get id => _id;
  String get name => _name;
  String get dosage => _dosage;
  String get manufacturer => _manufacturer;
  UnmodifiableListView<String> get sideEffects =>
      UnmodifiableListView(_sideEffects);

  Medication({
    required String id,
    required String name,
    required String dosage,
    required String manufacturer,
    required List<String> sideEffects,
  })  : _id = id,
        _name = name,
        _dosage = dosage,
        _manufacturer = manufacturer,
        _sideEffects = List.from(sideEffects) {
    _validateMedication();
  }

  void _validateMedication() {
    if (_id.trim().isEmpty) {
      throw ArgumentError('Medication ID cannot be empty');
    }
    if (_name.trim().isEmpty) {
      throw ArgumentError('Name cannot be empty');
    }
    if (_dosage.trim().isEmpty) {
      throw ArgumentError('Dosage cannot be empty');
    }
    if (_manufacturer.trim().isEmpty) {
      throw ArgumentError('Manufacturer cannot be empty');
    }
  }

  bool hasSideEffect(String sideEffect) {
    return _sideEffects.contains(sideEffect);
  }

  void addSideEffect(String sideEffect) {
    if (sideEffect.trim().isNotEmpty && !_sideEffects.contains(sideEffect)) {
      _sideEffects.add(sideEffect);
    }
  }

  String get dosageInfo => '$_name - $_dosage';

  Map<String, dynamic> get fullDetails => {
        'id': _id,
        'name': _name,
        'dosage': _dosage,
        'manufacturer': _manufacturer,
        'sideEffects': List.from(_sideEffects),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Medication &&
          runtimeType == other.runtimeType &&
          _id == other._id;

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() => 'Medication(id: $_id, name: $_name, dosage: $_dosage)';
}
