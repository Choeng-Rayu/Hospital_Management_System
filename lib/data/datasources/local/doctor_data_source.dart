import 'package:hospital_management/domain/entities/doctor.dart';

abstract class DoctorDataSource {
  Future<Doctor> getDoctorById(String staffID);
  Future<List<Doctor>> getAllDoctors();
  Future<void> saveDoctor(Doctor doctor);
  Future<void> updateDoctor(Doctor doctor);
  Future<void> deleteDoctor(String staffID);
  Future<bool> doctorExists(String staffID);
  Future<List<Doctor>> getDoctorsBySpecialization(String specialization);
}

/// Local implementation of DoctorDataSource that stores data in memory
class LocalDoctorDataSource implements DoctorDataSource {
  final Map<String, Doctor> _doctors = {};

  @override
  Future<Doctor> getDoctorById(String staffID) async {
    final doctor = _doctors[staffID];
    if (doctor == null) {
      throw Exception('Doctor not found');
    }
    return doctor;
  }

  @override
  Future<List<Doctor>> getAllDoctors() async {
    return _doctors.values.toList();
  }

  @override
  Future<void> saveDoctor(Doctor doctor) async {
    if (_doctors.containsKey(doctor.staffID)) {
      throw Exception('Doctor already exists');
    }
    _doctors[doctor.staffID] = doctor;
  }

  @override
  Future<void> updateDoctor(Doctor doctor) async {
    if (!_doctors.containsKey(doctor.staffID)) {
      throw Exception('Doctor not found');
    }
    _doctors[doctor.staffID] = doctor;
  }

  @override
  Future<void> deleteDoctor(String staffID) async {
    if (!_doctors.containsKey(staffID)) {
      throw Exception('Doctor not found');
    }
    _doctors.remove(staffID);
  }

  @override
  Future<bool> doctorExists(String staffID) async {
    return _doctors.containsKey(staffID);
  }

  @override
  Future<List<Doctor>> getDoctorsBySpecialization(String specialization) async {
    return _doctors.values
        .where((doctor) => doctor.specialization == specialization)
        .toList();
  }
}
