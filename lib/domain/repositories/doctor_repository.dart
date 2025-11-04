import '../entities/doctor.dart';
import '../entities/patient.dart';

/// Repository interface for Doctor entity
/// Defines all data operations needed for doctor management
abstract class DoctorRepository {
  Future<Doctor> getDoctorById(String staffId);

  Future<List<Doctor>> getAllDoctors();

  Future<void> saveDoctor(Doctor doctor);

  Future<void> updateDoctor(Doctor doctor);

  Future<void> deleteDoctor(String staffId);

  /// Search doctors by name
  Future<List<Doctor>> searchDoctorsByName(String name);

  Future<List<Doctor>> getDoctorsBySpecialization(String specialization);

  /// Get doctors available on a specific date
  Future<List<Doctor>> getAvailableDoctors(DateTime date);

  /// Get all patients assigned to a doctor
  Future<List<Patient>> getDoctorPatients(String doctorId);

  /// Check if a doctor exists
  Future<bool> doctorExists(String staffId);

  // Meeting and schedule management methods

  /// Get doctor's schedule for a specific date
  Future<List<DateTime>> getDoctorScheduleForDate(
      String doctorId, DateTime date);

  /// Check if doctor is available at a specific time
  Future<bool> isDoctorAvailableAt(
    String doctorId,
    DateTime dateTime,
    int durationMinutes,
  );

  /// Get available time slots for a doctor on a specific date
  Future<List<DateTime>> getAvailableTimeSlots(
    String doctorId,
    DateTime date, {
    int durationMinutes = 30,
    int startHour = 8,
    int endHour = 17,
  });

  /// Get all doctors available for a meeting at a specific time
  Future<List<Doctor>> getDoctorsAvailableAt(
    DateTime dateTime,
    int durationMinutes,
  );

  // Enhanced availability checking with appointment conflicts

  /// Check if doctor is available considering both working hours and appointment conflicts
  Future<bool> isDoctorFullyAvailable(
    String doctorId,
    DateTime dateTime,
    int durationMinutes,
  );
}
