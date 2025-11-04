import 'package:hospital_management/domain/entities/prescription.dart';

abstract class PrescriptionDataSource {
  Future<Prescription> getPrescriptionById(String prescriptionId);
  Future<List<Prescription>> getAllPrescriptions();
  Future<void> savePrescription(Prescription prescription);
  Future<void> updatePrescription(Prescription prescription);
  Future<void> deletePrescription(String prescriptionId);
  Future<bool> prescriptionExists(String prescriptionId);
  Future<List<Prescription>> getPrescriptionsByPatientId(String patientId);
  Future<List<Prescription>> getPrescriptionsByDoctorId(String doctorId);
}

/// Local implementation of PrescriptionDataSource that stores data in memory
class LocalPrescriptionDataSource implements PrescriptionDataSource {
  final Map<String, Prescription> _prescriptions = {};

  @override
  Future<Prescription> getPrescriptionById(String prescriptionId) async {
    final prescription = _prescriptions[prescriptionId];
    if (prescription == null) {
      throw Exception('Prescription not found');
    }
    return prescription;
  }

  @override
  Future<List<Prescription>> getAllPrescriptions() async {
    return _prescriptions.values.toList();
  }

  @override
  Future<void> savePrescription(Prescription prescription) async {
    if (_prescriptions.containsKey(prescription.id)) {
      throw Exception('Prescription already exists');
    }
    _prescriptions[prescription.id] = prescription;
  }

  @override
  Future<void> updatePrescription(Prescription prescription) async {
    if (!_prescriptions.containsKey(prescription.id)) {
      throw Exception('Prescription not found');
    }
    _prescriptions[prescription.id] = prescription;
  }

  @override
  Future<void> deletePrescription(String prescriptionId) async {
    if (!_prescriptions.containsKey(prescriptionId)) {
      throw Exception('Prescription not found');
    }
    _prescriptions.remove(prescriptionId);
  }

  @override
  Future<bool> prescriptionExists(String prescriptionId) async {
    return _prescriptions.containsKey(prescriptionId);
  }

  @override
  Future<List<Prescription>> getPrescriptionsByPatientId(
      String patientId) async {
    return _prescriptions.values
        .where(
            (prescription) => prescription.prescribedTo.patientID == patientId)
        .toList();
  }

  @override
  Future<List<Prescription>> getPrescriptionsByDoctorId(String doctorId) async {
    return _prescriptions.values
        .where((prescription) => prescription.prescribedBy.staffID == doctorId)
        .toList();
  }
}
