import 'staff.dart';

class Administrative extends Staff {
  final String _responsibility;

  String get responsibility => _responsibility;

  Administrative({
    required String name,
    required String dateOfBirth,
    required String address,
    required String tel,
    required String staffID,
    required DateTime hireDate,
    required double salary,
    required Map<String, List<DateTime>> schedule,
    required String responsibility,
  })  : _responsibility = responsibility,
        super(
          name: name,
          dateOfBirth: dateOfBirth,
          address: address,
          tel: tel,
          staffID: staffID,
          hireDate: hireDate,
          salary: salary,
          schedule: schedule,
        ) {
    _validateAdministrative();
  }

  void _validateAdministrative() {
    if (_responsibility.trim().isEmpty) {
      throw ArgumentError('Responsibility cannot be empty');
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is Administrative &&
          runtimeType == other.runtimeType &&
          _responsibility == other._responsibility;

  @override
  int get hashCode => super.hashCode ^ _responsibility.hashCode;

  @override
  String toString() =>
      'Administrative(staffID: $staffID, name: $name, responsibility: $_responsibility)';
}
