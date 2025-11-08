import '../../models/nurse_model.dart';

/// Abstract interface for Nurse data source operations
abstract class NurseDataSource {
  /// Read all nurses
  Future<List<NurseModel>> readAll();

  /// Add a new nurse
  Future<void> add(
    NurseModel nurse,
    String Function(NurseModel) getId,
    Map<String, dynamic> Function(NurseModel) toJson,
  );

  /// Update an existing nurse
  Future<void> update(
    String id,
    NurseModel nurse,
    String Function(NurseModel) getId,
    Map<String, dynamic> Function(NurseModel) toJson,
  );

  /// Delete a nurse
  Future<void> delete(
    String id,
    String Function(NurseModel) getId,
    Map<String, dynamic> Function(NurseModel) toJson,
  );

  /// Find a nurse by staff ID
  Future<NurseModel?> findByStaffId(String staffId);

  /// Check if a nurse exists
  Future<bool> nurseExists(String staffId);

  /// Find nurses by name (case-insensitive partial match)
  Future<List<NurseModel>> findNursesByName(String name);

  /// Find nurses assigned to a specific room
  Future<List<NurseModel>> findNursesByRoomId(String roomId);

  /// Find nurses assigned to a specific patient
  Future<List<NurseModel>> findNursesByPatientId(String patientId);

  /// Find nurses with fewer than a certain number of assigned patients (available nurses)
  Future<List<NurseModel>> findAvailableNurses({int maxPatients = 5});

  /// Find nurses with schedule on a specific date
  Future<List<NurseModel>> findNursesWithScheduleOnDate(DateTime date);

  /// Find nurses available on a specific date/time
  Future<List<NurseModel>> findNursesAvailableAt(
      DateTime dateTime, int durationMinutes);
}
