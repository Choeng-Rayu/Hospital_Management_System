import 'local/json_data_source.dart';
import '../models/nurse_model.dart';

/// Local data source for Nurse entity
/// Provides specialized queries for nurse data
class NurseLocalDataSource extends JsonDataSource<NurseModel> {
  NurseLocalDataSource()
      : super(
          fileName: 'nurses.json',
          fromJson: NurseModel.fromJson,
        );

  /// Find a nurse by staff ID
  Future<NurseModel?> findByStaffId(String staffId) {
    return findById(
      staffId,
      (nurse) => nurse.staffID,
      (nurse) => nurse.toJson(),
    );
  }

  /// Check if a nurse exists
  Future<bool> nurseExists(String staffId) {
    return exists(staffId, (nurse) => nurse.staffID);
  }

  /// Find nurses by name (case-insensitive partial match)
  Future<List<NurseModel>> findNursesByName(String name) {
    final lowerCaseName = name.toLowerCase();
    return findWhere(
      (nurse) => nurse.name.toLowerCase().contains(lowerCaseName),
    );
  }

  /// Find nurses assigned to a specific room
  Future<List<NurseModel>> findNursesByRoomId(String roomId) {
    return findWhere((nurse) => nurse.assignedRoomIds.contains(roomId));
  }

  /// Find nurses assigned to a specific patient
  Future<List<NurseModel>> findNursesByPatientId(String patientId) {
    return findWhere((nurse) => nurse.assignedPatientIds.contains(patientId));
  }

  /// Find nurses with fewer than a certain number of assigned patients (available nurses)
  Future<List<NurseModel>> findAvailableNurses({int maxPatients = 5}) {
    return findWhere((nurse) => nurse.assignedPatientIds.length < maxPatients);
  }

  /// Find nurses with schedule on a specific date
  Future<List<NurseModel>> findNursesWithScheduleOnDate(DateTime date) {
    final dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return findWhere((nurse) => nurse.schedule.containsKey(dateKey));
  }

  /// Find nurses available on a specific date/time
  Future<List<NurseModel>> findNursesAvailableAt(
      DateTime dateTime, int durationMinutes) async {
    final allNurses = await readAll();
    final availableNurses = <NurseModel>[];

    for (final nurse in allNurses) {
      final dateKey =
          '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';

      if (nurse.schedule.containsKey(dateKey)) {
        final timeSlot = nurse.schedule[dateKey]!;
        final startTime = DateTime.parse(timeSlot['start']!);
        final endTime = DateTime.parse(timeSlot['end']!);

        // Check if requested time falls within working hours
        final requestedEnd = dateTime.add(Duration(minutes: durationMinutes));
        if (dateTime.isAfter(startTime) &&
            requestedEnd.isBefore(endTime) &&
            nurse.assignedPatientIds.length < 5) {
          availableNurses.add(nurse);
        }
      }
    }

    return availableNurses;
  }
}
