import 'package:hospital_management/domain/entities/patient.dart';

abstract class PatientDataSource {
  Future<Patient> getPatientById(String patientId);
  Future<List<Patient>> getAllPatients();
  Future<void> savePatient(Patient patient);
  Future<void> updatePatient(Patient patient);
  Future<void> deletePatient(String patientId);
  Future<bool> patientExists(String patientId);
}

/// Local implementation of PatientDataSource that stores data in memory
class LocalPatientDataSource implements PatientDataSource {
  final Map<String, Patient> _patients = {};

  @override
  Future<Patient> getPatientById(String patientId) async {
    final patient = _patients[patientId];
    if (patient == null) {
      throw Exception('Patient not found');
    }
    return patient;
  }

  @override
  Future<List<Patient>> getAllPatients() async {
    return _patients.values.toList();
  }

  @override
  Future<void> savePatient(Patient patient) async {
    if (_patients.containsKey(patient.patientID)) {
      throw Exception('Patient already exists');
    }
    _patients[patient.patientID] = patient;
  }

  @override
  Future<void> updatePatient(Patient patient) async {
    if (!_patients.containsKey(patient.patientID)) {
      throw Exception('Patient not found');
    }
    _patients[patient.patientID] = patient;
  }

  @override
  Future<void> deletePatient(String patientId) async {
    if (!_patients.containsKey(patientId)) {
      throw Exception('Patient not found');
    }
    _patients.remove(patientId);
  }

  @override
  Future<bool> patientExists(String patientId) async {
    return _patients.containsKey(patientId);
  }
}
