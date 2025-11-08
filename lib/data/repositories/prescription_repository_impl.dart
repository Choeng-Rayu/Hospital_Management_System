import '../../domain/repositories/prescription_repository.dart';
import '../../domain/entities/prescription.dart';
import 'package:hospital_management/data/datasources/local/prescription_local_data_source.dart';
import 'package:hospital_management/data/datasources/local/patient_local_data_source.dart';
import 'package:hospital_management/data/datasources/local/doctor_local_data_source.dart';
import 'package:hospital_management/data/datasources/local/medication_local_data_source.dart';
import '../datasources/id_generator.dart';
import '../models/prescription_model.dart';

/// Implementation of PrescriptionRepository using local JSON data sources
class PrescriptionRepositoryImpl implements PrescriptionRepository {
  final PrescriptionLocalDataSource _prescriptionDataSource;
  final PatientLocalDataSource _patientDataSource;
  final DoctorLocalDataSource _doctorDataSource;
  final MedicationLocalDataSource _medicationDataSource;

  PrescriptionRepositoryImpl({
    required PrescriptionLocalDataSource prescriptionDataSource,
    required PatientLocalDataSource patientDataSource,
    required DoctorLocalDataSource doctorDataSource,
    required MedicationLocalDataSource medicationDataSource,
  })  : _prescriptionDataSource = prescriptionDataSource,
        _patientDataSource = patientDataSource,
        _doctorDataSource = doctorDataSource,
        _medicationDataSource = medicationDataSource;

  @override
  Future<Prescription> getPrescriptionById(String prescriptionId) async {
    final model =
        await _prescriptionDataSource.findByPrescriptionId(prescriptionId);
    if (model == null) {
      throw Exception('Prescription with ID $prescriptionId not found');
    }

    return await _convertModelToEntity(model);
  }

  @override
  Future<List<Prescription>> getAllPrescriptions() async {
    final models = await _prescriptionDataSource.readAll();
    final List<Prescription> prescriptions = [];

    for (final model in models) {
      try {
        prescriptions.add(await _convertModelToEntity(model));
      } catch (e) {
        // Skip prescriptions with missing related entities
        continue;
      }
    }

    return prescriptions;
  }

  @override
  Future<void> savePrescription(Prescription prescription) async {
    String prescriptionId = prescription.id;

    // Auto-generate ID if it's a placeholder or empty
    if (prescriptionId.isEmpty ||
        prescriptionId == 'AUTO' ||
        prescriptionId == 'PR000' ||
        prescriptionId == 'PR001') {
      // Read all existing prescriptions to generate next ID
      final allPrescriptions = await _prescriptionDataSource.readAll();
      final allPrescriptionsJson =
          allPrescriptions.map((p) => p.toJson()).toList();

      // Generate next available ID
      prescriptionId = IdGenerator.generatePrescriptionId(allPrescriptionsJson);

      // Create new prescription instance with generated ID
      prescription = Prescription(
        id: prescriptionId,
        time: prescription.time,
        medications: prescription.medications.toList(),
        instructions: prescription.instructions,
        prescribedBy: prescription.prescribedBy,
        prescribedTo: prescription.prescribedTo,
      );
    }

    final model = PrescriptionModel.fromEntity(prescription);

    // Check if prescription exists
    final exists =
        await _prescriptionDataSource.prescriptionExists(prescriptionId);

    if (exists) {
      throw Exception(
          'Prescription with ID $prescriptionId already exists. Use updatePrescription() to modify existing prescriptions.');
    } else {
      await _prescriptionDataSource.add(
        model,
        (p) => p.id,
        (p) => p.toJson(),
      );
    }
  }

  @override
  Future<void> updatePrescription(Prescription prescription) async {
    final model = PrescriptionModel.fromEntity(prescription);

    // Check if prescription exists
    final exists =
        await _prescriptionDataSource.prescriptionExists(prescription.id);

    if (!exists) {
      throw Exception(
          'Prescription with ID ${prescription.id} not found for update');
    }

    await _prescriptionDataSource.update(
      prescription.id,
      model,
      (p) => p.id,
      (p) => p.toJson(),
    );
  }

  @override
  Future<void> deletePrescription(String prescriptionId) async {
    await _prescriptionDataSource.delete(
      prescriptionId,
      (p) => p.id,
      (p) => p.toJson(),
    );
  }

  @override
  Future<List<Prescription>> getPrescriptionsByPatient(String patientId) async {
    final models =
        await _prescriptionDataSource.findPrescriptionsByPatientId(patientId);
    final List<Prescription> prescriptions = [];

    for (final model in models) {
      try {
        prescriptions.add(await _convertModelToEntity(model));
      } catch (e) {
        // Skip prescriptions with missing related entities
        continue;
      }
    }

    return prescriptions;
  }

  @override
  Future<List<Prescription>> getPrescriptionsByDoctor(String doctorId) async {
    final models =
        await _prescriptionDataSource.findPrescriptionsByDoctorId(doctorId);
    final List<Prescription> prescriptions = [];

    for (final model in models) {
      try {
        prescriptions.add(await _convertModelToEntity(model));
      } catch (e) {
        // Skip prescriptions with missing related entities
        continue;
      }
    }

    return prescriptions;
  }

  @override
  Future<List<Prescription>> getRecentPrescriptions() async {
    final models = await _prescriptionDataSource.findRecentPrescriptions();
    final List<Prescription> prescriptions = [];

    for (final model in models) {
      try {
        prescriptions.add(await _convertModelToEntity(model));
      } catch (e) {
        // Skip prescriptions with missing related entities
        continue;
      }
    }

    return prescriptions;
  }

  @override
  Future<List<Prescription>> getActivePrescriptionsByPatient(
      String patientId) async {
    final models = await _prescriptionDataSource
        .findActivePrescriptionsByPatientId(patientId);
    final List<Prescription> prescriptions = [];

    for (final model in models) {
      try {
        prescriptions.add(await _convertModelToEntity(model));
      } catch (e) {
        // Skip prescriptions with missing related entities
        continue;
      }
    }

    return prescriptions;
  }

  @override
  Future<bool> prescriptionExists(String prescriptionId) async {
    return await _prescriptionDataSource.prescriptionExists(prescriptionId);
  }

  /// Helper method to convert PrescriptionModel to Prescription entity
  /// Fetches all related entities (patient, doctor, medications)
  Future<Prescription> _convertModelToEntity(PrescriptionModel model) async {
    // Fetch patient
    final patientModel =
        await _patientDataSource.findByPatientID(model.patientId);
    if (patientModel == null) {
      throw Exception('Patient with ID ${model.patientId} not found');
    }

    // Fetch doctor
    final doctorModel = await _doctorDataSource.findByStaffID(model.doctorId);
    if (doctorModel == null) {
      throw Exception('Doctor with ID ${model.doctorId} not found');
    }

    // Fetch medications
    final medications =
        await _medicationDataSource.findMedicationsByIds(model.medicationIds);

    // Convert to entities
    final patient = patientModel.toEntity(assignedDoctors: []);
    final doctor = doctorModel.toEntity();
    final medicationEntities = medications.map((m) => m.toEntity()).toList();

    return model.toEntity(
      patient: patient,
      doctor: doctor,
      medications: medicationEntities,
    );
  }
}
