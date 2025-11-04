import 'local/json_data_source.dart';
import '../models/administrative_model.dart';

/// Local data source for Administrative entity
/// Provides specialized queries for administrative staff data
class AdministrativeLocalDataSource
    extends JsonDataSource<AdministrativeModel> {
  AdministrativeLocalDataSource()
      : super(
          fileName: 'administrative.json',
          fromJson: AdministrativeModel.fromJson,
        );

  /// Find an administrative staff member by staff ID
  Future<AdministrativeModel?> findByStaffId(String staffId) {
    return findById(
      staffId,
      (admin) => admin.staffID,
      (admin) => admin.toJson(),
    );
  }

  /// Check if an administrative staff member exists
  Future<bool> administrativeExists(String staffId) {
    return exists(staffId, (admin) => admin.staffID);
  }

  /// Find administrative staff by name (case-insensitive partial match)
  Future<List<AdministrativeModel>> findAdministrativeByName(String name) {
    final lowerCaseName = name.toLowerCase();
    return findWhere(
      (admin) => admin.name.toLowerCase().contains(lowerCaseName),
    );
  }

  /// Find administrative staff by responsibility
  Future<List<AdministrativeModel>> findAdministrativeByResponsibility(
      String responsibility) {
    final lowerCaseResponsibility = responsibility.toLowerCase();
    return findWhere(
      (admin) =>
          admin.responsibility.toLowerCase().contains(lowerCaseResponsibility),
    );
  }

  /// Find administrative staff with schedule on a specific date
  Future<List<AdministrativeModel>> findAdministrativeWithScheduleOnDate(
      DateTime date) {
    final dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return findWhere((admin) => admin.schedule.containsKey(dateKey));
  }

  /// Find administrative staff available on a specific date/time
  Future<List<AdministrativeModel>> findAdministrativeAvailableAt(
      DateTime dateTime, int durationMinutes) async {
    final allAdministrative = await readAll();
    final availableAdministrative = <AdministrativeModel>[];

    for (final admin in allAdministrative) {
      final dateKey =
          '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';

      if (admin.schedule.containsKey(dateKey)) {
        final timeSlot = admin.schedule[dateKey]!;
        final startTime = DateTime.parse(timeSlot['start']!);
        final endTime = DateTime.parse(timeSlot['end']!);

        // Check if requested time falls within working hours
        final requestedEnd = dateTime.add(Duration(minutes: durationMinutes));
        if (dateTime.isAfter(startTime) && requestedEnd.isBefore(endTime)) {
          availableAdministrative.add(admin);
        }
      }
    }

    return availableAdministrative;
  }

  /// Find administrative staff hired after a specific date
  Future<List<AdministrativeModel>> findAdministrativeHiredAfter(
      DateTime date) {
    return findWhere((admin) {
      final hireDate = DateTime.parse(admin.hireDate);
      return hireDate.isAfter(date);
    });
  }

  /// Find administrative staff with salary above a threshold
  Future<List<AdministrativeModel>> findAdministrativeWithSalaryAbove(
      double salary) {
    return findWhere((admin) => admin.salary > salary);
  }
}
