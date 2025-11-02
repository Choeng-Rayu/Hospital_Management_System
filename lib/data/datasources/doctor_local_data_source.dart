import 'local/json_data_source.dart';
import '../models/doctor_model.dart';

/// Local data source for Doctor entity
/// Provides specialized queries for doctor data
class DoctorLocalDataSource extends JsonDataSource<DoctorModel> {
  DoctorLocalDataSource()
      : super(
          fileName: 'doctors.json',
          fromJson: DoctorModel.fromJson,
        );

  /// Find a doctor by staff ID
  Future<DoctorModel?> findByStaffID(String staffID) {
    return findById(
        staffID, (doctor) => doctor.staffID, (doctor) => doctor.toJson());
  }

  /// Check if a doctor exists
  Future<bool> doctorExists(String staffID) {
    return exists(staffID, (doctor) => doctor.staffID);
  }

  /// Find doctors by specialization
  Future<List<DoctorModel>> findDoctorsBySpecialization(String specialization) {
    return findWhere((doctor) => doctor.specialization == specialization);
  }

  /// Find doctors with availability on a specific date
  Future<List<DoctorModel>> findAvailableDoctors(DateTime date) async {
    final requestedDate = DateTime(date.year, date.month, date.day);

    return findWhere((doctor) {
      // Search through all schedule entries to find ones matching the requested date
      for (final scheduleEntry in doctor.schedule.values) {
        final startTime = DateTime.parse(scheduleEntry['start']!);
        final startDate =
            DateTime(startTime.year, startTime.month, startTime.day);

        if (startDate.isAtSameMomentAs(requestedDate)) {
          return true;
        }
      }
      return false;
    });
  }

  /// Find doctors available at a specific time
  Future<List<DoctorModel>> findDoctorsAvailableAt(DateTime dateTime) async {
    return findWhere((doctor) {
      // Search through all schedule entries to find ones that include the requested time
      for (final scheduleEntry in doctor.schedule.values) {
        final startTime = DateTime.parse(scheduleEntry['start']!);
        final endTime = DateTime.parse(scheduleEntry['end']!);

        // Check if the requested time falls within the doctor's working hours
        if ((dateTime.isAfter(startTime) ||
                dateTime.isAtSameMomentAs(startTime)) &&
            dateTime.isBefore(endTime)) {
          return true;
        }
      }
      return false;
    });
  }

  /// Find doctors with a specific certification
  Future<List<DoctorModel>> findDoctorsByCertification(String certification) {
    return findWhere((doctor) => doctor.certifications.contains(certification));
  }

  /// Find doctors with patients
  Future<List<DoctorModel>> findDoctorsWithPatients() {
    return findWhere((doctor) => doctor.currentPatientIds.isNotEmpty);
  }

  /// Find doctors by multiple IDs
  Future<List<DoctorModel>> findDoctorsByIds(List<String> doctorIds) async {
    if (doctorIds.isEmpty) return [];

    final allDoctors = await readAll();
    return allDoctors
        .where((doctor) => doctorIds.contains(doctor.staffID))
        .toList();
  }
}
