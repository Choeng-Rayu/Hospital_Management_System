import '../../models/patient_model.dart';

/// Abstract interface for Patient data source operations
abstract class PatientDataSource {
  /// Read all patients
  Future<List<PatientModel>> readAll();

  /// Add a new patient
  Future<void> add(
    PatientModel patient,
    String Function(PatientModel) getId,
    Map<String, dynamic> Function(PatientModel) toJson,
  );

  /// Update an existing patient
  Future<void> update(
    String id,
    PatientModel patient,
    String Function(PatientModel) getId,
    Map<String, dynamic> Function(PatientModel) toJson,
  );

  /// Delete a patient
  Future<void> delete(
    String id,
    String Function(PatientModel) getId,
    Map<String, dynamic> Function(PatientModel) toJson,
  );

  /// Find a patient by patient ID
  Future<PatientModel?> findByPatientID(String patientID);

  /// Check if a patient exists
  Future<bool> patientExists(String patientID);

  /// Find all patients with upcoming meetings
  Future<List<PatientModel>> findPatientsWithUpcomingMeetings();

  /// Find patients with meetings on a specific date
  Future<List<PatientModel>> findPatientsByMeetingDate(DateTime date);

  /// Find patients assigned to a specific doctor
  Future<List<PatientModel>> findPatientsByDoctorId(String doctorId);

  /// Find patients assigned to a specific nurse
  Future<List<PatientModel>> findPatientsByNurseId(String nurseId);

  /// Find patients in a specific room
  Future<List<PatientModel>> findPatientsByRoomId(String roomId);

  /// Find patients by blood group
  Future<List<PatientModel>> findPatientsByBloodGroup(String bloodGroup);

  /// Find currently admitted patients (those with room assignments)
  Future<List<PatientModel>> findAdmittedPatients();

  /// Find patients by name (case-insensitive partial match)
  Future<List<PatientModel>> findPatientsByName(String name);

  /// Find patients by blood type
  Future<List<PatientModel>> findPatientsByBloodType(String bloodType);

  /// Find patients by meeting doctor ID
  Future<List<PatientModel>> findPatientsByMeetingDoctorId(String doctorId);
}
