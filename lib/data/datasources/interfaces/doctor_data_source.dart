import '../../models/doctor_model.dart';

/// Abstract interface for Doctor data source operations
abstract class DoctorDataSource {
  /// Read all doctors
  Future<List<DoctorModel>> readAll();

  /// Add a new doctor
  Future<void> add(
    DoctorModel doctor,
    String Function(DoctorModel) getId,
    Map<String, dynamic> Function(DoctorModel) toJson,
  );

  /// Update an existing doctor
  Future<void> update(
    String id,
    DoctorModel doctor,
    String Function(DoctorModel) getId,
    Map<String, dynamic> Function(DoctorModel) toJson,
  );

  /// Delete a doctor
  Future<void> delete(
    String id,
    String Function(DoctorModel) getId,
    Map<String, dynamic> Function(DoctorModel) toJson,
  );

  /// Find a doctor by staff ID
  Future<DoctorModel?> findByStaffID(String staffID);

  /// Check if a doctor exists
  Future<bool> doctorExists(String staffID);

  /// Find doctors by specialization
  Future<List<DoctorModel>> findDoctorsBySpecialization(String specialization);

  /// Find doctors with availability on a specific date
  Future<List<DoctorModel>> findAvailableDoctors(DateTime date);

  /// Find doctors available at a specific time
  Future<List<DoctorModel>> findDoctorsAvailableAt(DateTime dateTime);

  /// Find doctors with a specific certification
  Future<List<DoctorModel>> findDoctorsByCertification(String certification);

  /// Find doctors with patients
  Future<List<DoctorModel>> findDoctorsWithPatients();

  /// Find doctors by multiple IDs
  Future<List<DoctorModel>> findDoctorsByIds(List<String> doctorIds);
}
