import 'dart:collection';
import 'person.dart';

abstract class Staff extends Person {
  final String _staffID;
  final DateTime _hireDate;
  final double _salary;
  final Map<String, List<DateTime>> _schedule;

  String get staffID => _staffID;
  DateTime get hireDate => _hireDate;
  double get salary => _salary;
  UnmodifiableMapView<String, List<DateTime>> get schedule =>
      UnmodifiableMapView(_schedule);

  Staff({
    required String name,
    required String dateOfBirth,
    required String address,
    required String tel,
    required String staffID,
    required DateTime hireDate,
    required double salary,
    required Map<String, List<DateTime>> schedule,
  })  : _staffID = staffID,
        _hireDate = hireDate,
        _salary = salary,
        _schedule = Map.from(schedule),
        super(
          name: name,
          dateOfBirth: dateOfBirth,
          address: address,
          tel: tel,
        ) {
    _validateStaff();
  }

  void _validateStaff() {
    if (_staffID.trim().isEmpty) {
      throw ArgumentError('Staff ID cannot be empty');
    }
    _validateHireDate();
    _validateSalary();
  }

  void _validateHireDate() {
    if (_hireDate.isAfter(DateTime.now())) {
      throw ArgumentError('Hire date cannot be in the future');
    }
  }

  void _validateSalary() {
    if (_salary < 0) {
      throw ArgumentError('Salary cannot be negative');
    }
  }

  void addScheduleEntry(String key, DateTime time) {
    _schedule.update(
      key,
      (times) => [...times, time],
      ifAbsent: () => [time],
    );
  }

  void removeScheduleEntry(String key, DateTime time) {
    _schedule[key]?.remove(time);
    if (_schedule[key]?.isEmpty ?? false) {
      _schedule.remove(key);
    }
  }

  List<DateTime> getScheduleFor(String key) {
    return UnmodifiableListView(_schedule[key] ?? []);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is Staff &&
          runtimeType == other.runtimeType &&
          _staffID == other._staffID;

  @override
  int get hashCode => super.hashCode ^ _staffID.hashCode;

  @override
  String toString() => '${runtimeType}(staffID: $_staffID, name: $name)';
}
