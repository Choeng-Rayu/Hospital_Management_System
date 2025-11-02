import '../entities/nurse.dart';
import '../entities/patient.dart';
import '../entities/room.dart';

/// Repository interface for Nurse entity
/// Defines all data operations needed for nurse management
abstract class NurseRepository {
  /// Retrieve a nurse by their staff ID
  Future<Nurse> getNurseById(String staffId);

  /// Retrieve all nurses in the system
  Future<List<Nurse>> getAllNurses();

  /// Save a new nurse to the system
  Future<void> saveNurse(Nurse nurse);

  /// Update an existing nurse's information
  Future<void> updateNurse(Nurse nurse);

  /// Delete a nurse from the system
  Future<void> deleteNurse(String staffId);

  /// Search nurses by name
  Future<List<Nurse>> searchNursesByName(String name);

  /// Get nurses assigned to a specific room
  Future<List<Nurse>> getNursesByRoom(String roomId);

  /// Get available nurses (with fewer than max patients)
  Future<List<Nurse>> getAvailableNurses();

  /// Get all patients assigned to a nurse
  Future<List<Patient>> getNursePatients(String nurseId);

  /// Get all rooms assigned to a nurse
  Future<List<Room>> getNurseRooms(String nurseId);

  /// Check if a nurse exists
  Future<bool> nurseExists(String staffId);
}
