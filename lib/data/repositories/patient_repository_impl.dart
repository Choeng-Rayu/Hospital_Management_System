import '../../domain/repositories/patient_repository.dart';
import '../../domain/entities/patient.dart';
import '../../domain/entities/doctor.dart';
import 'package:hospital_management/data/datasources/local/patient_local_data_source.dart';
import 'package:hospital_management/data/datasources/local/doctor_local_data_source.dart';
import '../datasources/id_generator.dart';
import '../models/patient_model.dart';

/// Implementation of PatientRepository using local JSON data sources
class PatientRepositoryImpl implements PatientRepository {
  final PatientLocalDataSource _patientDataSource;
  final DoctorLocalDataSource _doctorDataSource;

  PatientRepositoryImpl({
    required PatientLocalDataSource patientDataSource,
    required DoctorLocalDataSource doctorDataSource,
  })  : _patientDataSource = patientDataSource,
        _doctorDataSource = doctorDataSource;

  @override
  Future<Patient> getPatientById(String patientId) async {
    final model = await _patientDataSource.findByPatientID(patientId);
    if (model == null) {
      throw Exception('Patient with ID $patientId not found');
    }

    // Fetch assigned doctors for this patient
    final assignedDoctorModels =
        await _doctorDataSource.findDoctorsByIds(model.assignedDoctorIds);
    final assignedDoctors =
        assignedDoctorModels.map((dm) => dm.toEntity()).toList();

    return model.toEntity(assignedDoctors: assignedDoctors);
  }

  @override
  Future<List<Patient>> getAllPatients() async {
    final models = await _patientDataSource.readAll();
    final List<Patient> patients = [];

    for (final model in models) {
      final assignedDoctors =
          await _convertDoctorModels(model.assignedDoctorIds);
      patients.add(model.toEntity(assignedDoctors: assignedDoctors));
    }

    return patients;
  }

  @override
  Future<void> savePatient(Patient patient) async {
    String patientId = patient.patientID;

    // Auto-generate ID if it's a placeholder or empty
    if (patientId.isEmpty || patientId == 'AUTO' || patientId == 'P000') {
      // Read all existing patients to generate next ID
      final allPatients = await _patientDataSource.readAll();
      final allPatientsJson = allPatients.map((p) => p.toJson()).toList();

      // Generate next available ID
      patientId = IdGenerator.generatePatientId(allPatientsJson);

      // Create new patient instance with generated ID
      patient = Patient(
        patientID: patientId,
        name: patient.name,
        dateOfBirth: patient.dateOfBirth,
        address: patient.address,
        tel: patient.tel,
        bloodType: patient.bloodType,
        medicalRecords: patient.medicalRecords.toList(),
        allergies: patient.allergies.toList(),
        emergencyContact: patient.emergencyContact,
        assignedDoctors: patient.assignedDoctors.toList(),
        assignedNurses: patient.assignedNurses.toList(),
        prescriptions: patient.prescriptions.toList(),
        currentRoom: patient.currentRoom,
        currentBed: patient.currentBed,
      );
    }

    final model = PatientModel.fromEntity(patient);

    // Check if patient exists
    final exists = await _patientDataSource.patientExists(patientId);

    if (exists) {
      throw Exception(
          'Patient with ID $patientId already exists. Use updatePatient() to modify existing patients.');
    } else {
      await _patientDataSource.add(
        model,
        (p) => p.patientID,
        (p) => p.toJson(),
      );
    }
  }

  @override
  Future<void> updatePatient(Patient patient) async {
    final model = PatientModel.fromEntity(patient);

    // Check if patient exists
    final exists = await _patientDataSource.patientExists(patient.patientID);

    if (!exists) {
      throw Exception(
          'Patient with ID ${patient.patientID} not found for update');
    }

    await _patientDataSource.update(
      patient.patientID,
      model,
      (p) => p.patientID,
      (p) => p.toJson(),
    );
  }

  @override
  Future<void> deletePatient(String patientId) async {
    await _patientDataSource.delete(
      patientId,
      (p) => p.patientID,
      (p) => p.toJson(),
    );
  }

  @override
  Future<List<Patient>> searchPatientsByName(String name) async {
    final models = await _patientDataSource.findPatientsByName(name);
    final List<Patient> patients = [];

    for (final model in models) {
      final assignedDoctors =
          await _convertDoctorModels(model.assignedDoctorIds);
      patients.add(model.toEntity(assignedDoctors: assignedDoctors));
    }

    return patients;
  }

  @override
  Future<List<Patient>> getPatientsByBloodType(String bloodType) async {
    final models = await _patientDataSource.findPatientsByBloodType(bloodType);
    final List<Patient> patients = [];

    for (final model in models) {
      final assignedDoctors =
          await _convertDoctorModels(model.assignedDoctorIds);
      patients.add(model.toEntity(assignedDoctors: assignedDoctors));
    }

    return patients;
  }

  @override
  Future<List<Patient>> getPatientsByDoctorId(String doctorId) async {
    final models = await _patientDataSource.findPatientsByDoctorId(doctorId);
    final List<Patient> patients = [];

    for (final model in models) {
      final assignedDoctors =
          await _convertDoctorModels(model.assignedDoctorIds);
      patients.add(model.toEntity(assignedDoctors: assignedDoctors));
    }

    return patients;
  }

  @override
  Future<bool> patientExists(String patientId) async {
    return await _patientDataSource.patientExists(patientId);
  }

  @override
  Future<List<Patient>> getPatientsWithUpcomingMeetings() async {
    final models = await _patientDataSource.findPatientsWithUpcomingMeetings();
    final List<Patient> patients = [];

    for (final model in models) {
      final assignedDoctors =
          await _convertDoctorModels(model.assignedDoctorIds);
      patients.add(model.toEntity(assignedDoctors: assignedDoctors));
    }

    return patients;
  }

  @override
  Future<List<Patient>> getPatientsWithOverdueMeetings() async {
    // Find patients with past meeting dates
    final allModels = await _patientDataSource.readAll();
    final overdueModels = allModels.where((patient) {
      if (!patient.hasNextMeeting || patient.nextMeetingDate == null) {
        return false;
      }

      final meetingDate = DateTime.parse(patient.nextMeetingDate!);
      return meetingDate.isBefore(DateTime.now());
    }).toList();

    final List<Patient> patients = [];
    for (final model in overdueModels) {
      final assignedDoctors =
          await _convertDoctorModels(model.assignedDoctorIds);
      patients.add(model.toEntity(assignedDoctors: assignedDoctors));
    }

    return patients;
  }

  @override
  Future<List<Patient>> getPatientsByDoctorMeetings(String doctorId) async {
    final models =
        await _patientDataSource.findPatientsByMeetingDoctorId(doctorId);
    final List<Patient> patients = [];

    for (final model in models) {
      final assignedDoctors =
          await _convertDoctorModels(model.assignedDoctorIds);
      patients.add(model.toEntity(assignedDoctors: assignedDoctors));
    }

    return patients;
  }

  @override
  Future<List<Patient>> getPatientsWithMeetingsOnDate(DateTime date) async {
    final models = await _patientDataSource.findPatientsByMeetingDate(date);
    final List<Patient> patients = [];

    for (final model in models) {
      final assignedDoctors =
          await _convertDoctorModels(model.assignedDoctorIds);
      patients.add(model.toEntity(assignedDoctors: assignedDoctors));
    }

    return patients;
  }

  /// Helper method to convert DoctorModels to Doctor entities
  Future<List<Doctor>> _convertDoctorModels(List<String> doctorIds) async {
    if (doctorIds.isEmpty) return [];
    final doctorModels = await _doctorDataSource.findDoctorsByIds(doctorIds);
    return doctorModels.map((dm) => dm.toEntity()).toList();
  }
}
