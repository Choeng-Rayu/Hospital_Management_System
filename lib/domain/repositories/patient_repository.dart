import '../entities/patient.dart';

/// Repository interface for Patient entity
/// Defines all data operations needed for patient management
abstract class PatientRepository {
  Future<Patient> getPatientById(String patientId);

  Future<List<Patient>> getAllPatients();

  Future<void> savePatient(Patient patient);

  Future<void> updatePatient(Patient patient);

  Future<void> deletePatient(String patientId);

  Future<List<Patient>> searchPatientsByName(String name);

  Future<List<Patient>> getPatientsByBloodType(String bloodType);

  Future<List<Patient>> getPatientsByDoctorId(String doctorId);

  /// Check if a patient exists
  Future<bool> patientExists(String patientId);

  // Meeting management methods

  /// Get all patients with upcoming meetings (within next 7 days)
  Future<List<Patient>> getPatientsWithUpcomingMeetings();

  /// Get all patients with overdue meetings
  Future<List<Patient>> getPatientsWithOverdueMeetings();

  /// Get all patients scheduled to meet with a specific doctor
  Future<List<Patient>> getPatientsByDoctorMeetings(String doctorId);

  /// Get patients with meetings on a specific date
  Future<List<Patient>> getPatientsWithMeetingsOnDate(DateTime date);
}
