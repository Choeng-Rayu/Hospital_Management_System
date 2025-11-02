import 'local/json_data_source.dart';
import '../models/patient_model.dart';

/// Local data source for Patient entity
/// Provides specialized queries for patient data
class PatientLocalDataSource extends JsonDataSource<PatientModel> {
  PatientLocalDataSource()
      : super(
          fileName: 'patients.json',
          fromJson: PatientModel.fromJson,
        );

  /// Find a patient by patient ID
  Future<PatientModel?> findByPatientID(String patientID) {
    return findById(patientID, (patient) => patient.patientID,
        (patient) => patient.toJson());
  }

  /// Check if a patient exists
  Future<bool> patientExists(String patientID) {
    return exists(patientID, (patient) => patient.patientID);
  }

  /// Find all patients with upcoming meetings
  Future<List<PatientModel>> findPatientsWithUpcomingMeetings() async {
    return findWhere((patient) {
      if (!patient.hasNextMeeting || patient.nextMeetingDate == null) {
        return false;
      }

      final meetingDate = DateTime.parse(patient.nextMeetingDate!);
      return meetingDate.isAfter(DateTime.now());
    });
  }

  /// Find patients with meetings on a specific date
  Future<List<PatientModel>> findPatientsByMeetingDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return findWhere((patient) {
      if (!patient.hasNextMeeting || patient.nextMeetingDate == null) {
        return false;
      }

      final meetingDate = DateTime.parse(patient.nextMeetingDate!);
      return meetingDate.isAfter(startOfDay) && meetingDate.isBefore(endOfDay);
    });
  }

  /// Find patients assigned to a specific doctor
  Future<List<PatientModel>> findPatientsByDoctorId(String doctorId) {
    return findWhere((patient) => patient.assignedDoctorIds.contains(doctorId));
  }

  /// Find patients assigned to a specific nurse
  Future<List<PatientModel>> findPatientsByNurseId(String nurseId) {
    return findWhere((patient) => patient.assignedNurseIds.contains(nurseId));
  }

  /// Find patients in a specific room
  Future<List<PatientModel>> findPatientsByRoomId(String roomId) {
    return findWhere((patient) => patient.currentRoomId == roomId);
  }

  /// Find patients by blood group
  Future<List<PatientModel>> findPatientsByBloodGroup(String bloodGroup) {
    return findWhere((patient) => patient.bloodType == bloodGroup);
  }

  /// Find currently admitted patients (those with room assignments)
  Future<List<PatientModel>> findAdmittedPatients() {
    return findWhere((patient) => patient.currentRoomId != null);
  }

  /// Find patients by name (case-insensitive partial match)
  Future<List<PatientModel>> findPatientsByName(String name) {
    final lowerCaseName = name.toLowerCase();
    return findWhere(
        (patient) => patient.name.toLowerCase().contains(lowerCaseName));
  }

  /// Find patients by blood type
  Future<List<PatientModel>> findPatientsByBloodType(String bloodType) {
    return findWhere((patient) => patient.bloodType == bloodType);
  }

  /// Find patients by meeting doctor ID
  Future<List<PatientModel>> findPatientsByMeetingDoctorId(String doctorId) {
    return findWhere((patient) => patient.nextMeetingDoctorId == doctorId);
  }
}
