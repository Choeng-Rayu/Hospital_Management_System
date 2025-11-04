/// Utility class for generating unique IDs for entities
///
/// This class provides methods to auto-generate IDs by finding the maximum
/// existing ID in a collection and incrementing it.
///
/// Example:
/// ```dart
/// // Current IDs: P001, P002, P050
/// final nextId = IdGenerator.generateNextId(patients, 'patientID', 'P', 3);
/// // Returns: P051
/// ```
class IdGenerator {
  /// Generate the next available ID by finding max ID and incrementing
  ///
  /// [records] - List of JSON objects containing the entities
  /// [idField] - Name of the ID field in the JSON (e.g., 'patientID', 'staffID')
  /// [prefix] - ID prefix (e.g., 'P' for patients, 'D' for doctors)
  /// [digits] - Number of digits for the numeric part (usually 3)
  ///
  /// Returns a formatted ID string (e.g., 'P051', 'D026')
  static String generateNextId(
    List<Map<String, dynamic>> records,
    String idField,
    String prefix,
    int digits,
  ) {
    if (records.isEmpty) {
      // If no records exist, start from 1
      return '$prefix${'1'.padLeft(digits, '0')}';
    }

    // Find the maximum numeric ID value
    int maxId = 0;
    for (var record in records) {
      try {
        final id = record[idField] as String?;
        if (id == null || id.isEmpty) continue;

        // Remove prefix to get numeric part
        final numericPart = id.replaceAll(prefix, '');
        final num = int.tryParse(numericPart) ?? 0;

        if (num > maxId) {
          maxId = num;
        }
      } catch (e) {
        // Skip invalid records
        continue;
      }
    }

    // Increment and format with leading zeros
    final nextNum = maxId + 1;
    return '$prefix${nextNum.toString().padLeft(digits, '0')}';
  }

  /// Generate next patient ID (format: P###)
  static String generatePatientId(List<Map<String, dynamic>> patients) {
    return generateNextId(patients, 'patientID', 'P', 3);
  }

  /// Generate next doctor ID (format: D###)
  static String generateDoctorId(List<Map<String, dynamic>> doctors) {
    return generateNextId(doctors, 'staffID', 'D', 3);
  }

  /// Generate next nurse ID (format: N###)
  static String generateNurseId(List<Map<String, dynamic>> nurses) {
    return generateNextId(nurses, 'staffID', 'N', 3);
  }

  /// Generate next appointment ID (format: A###)
  static String generateAppointmentId(List<Map<String, dynamic>> appointments) {
    return generateNextId(appointments, 'id', 'A', 3);
  }

  /// Generate next prescription ID (format: PR###)
  static String generatePrescriptionId(
      List<Map<String, dynamic>> prescriptions) {
    return generateNextId(prescriptions, 'id', 'PR', 3);
  }

  /// Generate next room ID (format: R###)
  static String generateRoomId(List<Map<String, dynamic>> rooms) {
    return generateNextId(rooms, 'roomId', 'R', 3);
  }

  /// Generate next equipment ID (format: EQ###)
  static String generateEquipmentId(List<Map<String, dynamic>> equipment) {
    return generateNextId(equipment, 'equipmentId', 'EQ', 3);
  }

  /// Generate next medication ID (format: M###)
  static String generateMedicationId(List<Map<String, dynamic>> medications) {
    return generateNextId(medications, 'id', 'M', 3);
  }

  /// Generate next administrative staff ID (format: AD###)
  static String generateAdministrativeId(List<Map<String, dynamic>> admins) {
    return generateNextId(admins, 'staffID', 'AD', 3);
  }

  /// Check if an ID follows the expected format
  ///
  /// [id] - The ID to validate
  /// [prefix] - Expected prefix (e.g., 'P', 'D')
  /// [digits] - Expected number of digits (usually 3)
  ///
  /// Returns true if the ID matches the format
  static bool isValidIdFormat(String id, String prefix, int digits) {
    if (!id.startsWith(prefix)) return false;

    final numericPart = id.replaceAll(prefix, '');
    if (numericPart.length != digits) return false;

    return int.tryParse(numericPart) != null;
  }
}
