import 'package:hospital_management/domain/entities/nurse.dart';

abstract class NurseDataSource {
  Future<Nurse> getNurseById(String staffID);
  Future<List<Nurse>> getAllNurses();
  Future<void> saveNurse(Nurse nurse);
  Future<void> updateNurse(Nurse nurse);
  Future<void> deleteNurse(String staffID);
  Future<bool> nurseExists(String staffID);
  Future<List<Nurse>> getNursesByShift(String shift);
}

/// Local implementation of NurseDataSource that stores data in memory
class LocalNurseDataSource implements NurseDataSource {
  final Map<String, Nurse> _nurses = {};

  @override
  Future<Nurse> getNurseById(String staffID) async {
    final nurse = _nurses[staffID];
    if (nurse == null) {
      throw Exception('Nurse not found');
    }
    return nurse;
  }

  @override
  Future<List<Nurse>> getAllNurses() async {
    return _nurses.values.toList();
  }

  @override
  Future<void> saveNurse(Nurse nurse) async {
    if (_nurses.containsKey(nurse.staffID)) {
      throw Exception('Nurse already exists');
    }
    _nurses[nurse.staffID] = nurse;
  }

  @override
  Future<void> updateNurse(Nurse nurse) async {
    if (!_nurses.containsKey(nurse.staffID)) {
      throw Exception('Nurse not found');
    }
    _nurses[nurse.staffID] = nurse;
  }

  @override
  Future<void> deleteNurse(String staffID) async {
    if (!_nurses.containsKey(staffID)) {
      throw Exception('Nurse not found');
    }
    _nurses.remove(staffID);
  }

  @override
  Future<bool> nurseExists(String staffID) async {
    return _nurses.containsKey(staffID);
  }

  @override
  Future<List<Nurse>> getNursesByShift(String shift) async {
    final DateTime now = DateTime.now();
    final String scheduleKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    return _nurses.values.where((nurse) {
      final List<DateTime> shiftTimes = nurse.schedule[scheduleKey] ?? [];
      if (shift.toLowerCase() == 'morning') {
        return shiftTimes.any((time) => time.hour >= 6 && time.hour < 14);
      } else if (shift.toLowerCase() == 'afternoon') {
        return shiftTimes.any((time) => time.hour >= 14 && time.hour < 22);
      } else if (shift.toLowerCase() == 'night') {
        return shiftTimes.any((time) => time.hour >= 22 || time.hour < 6);
      }
      return false;
    }).toList();
  }
}
