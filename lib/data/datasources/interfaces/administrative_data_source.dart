import '../../models/administrative_model.dart';

/// Abstract interface for Administrative staff data source operations
abstract class AdministrativeDataSource {
  /// Read all administrative staff
  Future<List<AdministrativeModel>> readAll();

  /// Add a new administrative staff member
  Future<void> add(
    AdministrativeModel admin,
    String Function(AdministrativeModel) getId,
    Map<String, dynamic> Function(AdministrativeModel) toJson,
  );

  /// Update an existing administrative staff member
  Future<void> update(
    String id,
    AdministrativeModel admin,
    String Function(AdministrativeModel) getId,
    Map<String, dynamic> Function(AdministrativeModel) toJson,
  );

  /// Delete an administrative staff member
  Future<void> delete(
    String id,
    String Function(AdministrativeModel) getId,
    Map<String, dynamic> Function(AdministrativeModel) toJson,
  );

  /// Find an administrative staff member by staff ID
  Future<AdministrativeModel?> findByStaffId(String staffId);

  /// Check if an administrative staff member exists
  Future<bool> administrativeExists(String staffId);

  /// Find administrative staff by name (case-insensitive partial match)
  Future<List<AdministrativeModel>> findAdministrativeByName(String name);

  /// Find administrative staff by responsibility
  Future<List<AdministrativeModel>> findAdministrativeByResponsibility(
      String responsibility);

  /// Find administrative staff with schedule on a specific date
  Future<List<AdministrativeModel>> findAdministrativeWithScheduleOnDate(
      DateTime date);

  /// Find administrative staff available on a specific date/time
  Future<List<AdministrativeModel>> findAdministrativeAvailableAt(
      DateTime dateTime, int durationMinutes);

  /// Find administrative staff hired after a specific date
  Future<List<AdministrativeModel>> findAdministrativeHiredAfter(DateTime date);

  /// Find administrative staff with salary above a threshold
  Future<List<AdministrativeModel>> findAdministrativeWithSalaryAbove(
      double salary);
}
