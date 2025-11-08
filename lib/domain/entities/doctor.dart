import 'dart:collection';
import 'staff.dart';
import 'patient.dart';

class Doctor extends Staff {
  final String _specialization;
  final List<String> _certifications;
  final List<Patient> _currentPatients;
  final Map<String, Map<String, String>>
      _workingHours; // Working schedule from JSON

  String get specialization => _specialization;
  UnmodifiableListView<String> get certifications =>
      UnmodifiableListView(_certifications);
  UnmodifiableListView<Patient> get currentPatients =>
      UnmodifiableListView(_currentPatients);
  int get patientCount => _currentPatients.length;
  UnmodifiableMapView<String, Map<String, String>> get workingHours =>
      UnmodifiableMapView(_workingHours);

  Doctor({
    required String name,
    required String dateOfBirth,
    required String address,
    required String tel,
    required String staffID,
    required DateTime hireDate,
    required double salary,
    required Map<String, List<DateTime>> schedule,
    required String specialization,
    required List<String> certifications,
    required List<Patient> currentPatients,
    required Map<String, Map<String, String>> workingHours,
  })  : _specialization = specialization,
        _certifications = List.from(certifications),
        _currentPatients = List.from(currentPatients),
        _workingHours = Map.from(workingHours),
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
    _validateDoctor();
  }

  void _validateDoctor() {
    if (_specialization.trim().isEmpty) {
      throw ArgumentError('Specialization cannot be empty');
    }
  }

  void addPatient(Patient patient) {
    if (!_currentPatients.contains(patient)) {
      _currentPatients.add(patient);
    }
  }

  void removePatient(Patient patient) {
    _currentPatients.remove(patient);
  }

  bool hasCertification(String certification) {
    return _certifications.contains(certification);
  }

  void addCertification(String certification) {
    if (!_certifications.contains(certification)) {
      _certifications.add(certification);
    }
  }

  /// Check if the doctor is working during the specified time period
  bool isWorkingDuring(DateTime dateTime, int durationMinutes) {
    final workingHours = getWorkingHoursForDate(dateTime);
    if (workingHours == null) {
      return false; // Doctor not working on this date
    }

    final workStartUtc = DateTime.parse(workingHours['start']!);
    final workEndUtc = DateTime.parse(workingHours['end']!);

    // Convert working hours to the same date as the requested time
    final workStart = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      workStartUtc.hour,
      workStartUtc.minute,
    );
    final workEnd = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      workEndUtc.hour,
      workEndUtc.minute,
    );

    final requestedEnd = dateTime.add(Duration(minutes: durationMinutes));

    return (dateTime.isAfter(workStart) ||
            dateTime.isAtSameMomentAs(workStart)) &&
        (requestedEnd.isBefore(workEnd) ||
            requestedEnd.isAtSameMomentAs(workEnd));
  }

  /// Get working hours for a specific date
  Map<String, String>? getWorkingHoursForDate(DateTime date) {
    // Try exact date match first
    final exactDateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final exactMatch = _workingHours[exactDateKey];
    if (exactMatch != null) {
      return exactMatch;
    }

    // If no exact date match, try to find by day name
    final dayName = _getDayName(date.weekday);
    final dayMatch = _workingHours[dayName];
    if (dayMatch != null) {
      return dayMatch;
    }

    // If still no match, look for any working hours with the same weekday
    // This handles cases where JSON has specific dates but we want recurring weekly schedule
    for (final entry in _workingHours.entries) {
      try {
        // Try to parse the key as a date
        final keyParts = entry.key.split('-');
        if (keyParts.length == 3) {
          final keyYear = int.tryParse(keyParts[0]);
          final keyMonth = int.tryParse(keyParts[1]);
          final keyDay = int.tryParse(keyParts[2]);

          if (keyYear != null && keyMonth != null && keyDay != null) {
            final keyDate = DateTime(keyYear, keyMonth, keyDay);
            // If it's the same weekday, use this schedule
            if (keyDate.weekday == date.weekday) {
              return entry.value;
            }
          }
        }
      } catch (e) {
        // Skip invalid date keys
        continue;
      }
    }

    return null; // No working hours found for this date
  }

  /// Convert weekday number to day name
  String _getDayName(int weekday) {
    const dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return dayNames[weekday - 1];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is Doctor &&
          runtimeType == other.runtimeType &&
          _specialization == other._specialization;

  @override
  int get hashCode => super.hashCode ^ _specialization.hashCode;

  @override
  String toString() =>
      'Doctor(staffID: $staffID, name: $name, specialization: $_specialization)';
}
