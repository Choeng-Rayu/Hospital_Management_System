import 'dart:convert';
import 'dart:io';

void main() async {
  print('🧹 Cleaning up test data...\n');

  // Clean up patients - keep only P001-P050
  await cleanupPatients();

  // Clean up appointments - keep only original ones
  await cleanupAppointments();

  print('\n✅ Cleanup complete!');
  print('📊 Run tests again to verify all pass');
}

Future<void> cleanupPatients() async {
  final file = File('data/patients.json');
  final content = await file.readAsString();
  final List<dynamic> patients = jsonDecode(content);

  print('📋 Total patients before cleanup: ${patients.length}');

  // Keep only patients P001-P050 (original data)
  final cleaned = patients.where((p) {
    final id = p['patientID'] as String;
    final idNum = int.tryParse(id.substring(1));
    return idNum != null && idNum >= 1 && idNum <= 50;
  }).toList();

  print('📋 Patients after cleanup: ${cleaned.length}');
  print('🗑️  Removed: ${patients.length - cleaned.length} test patients\n');

  // Write back
  await file.writeAsString(jsonEncode(cleaned));

  // Pretty print for readability
  final prettyJson = JsonEncoder.withIndent('  ').convert(cleaned);
  await file.writeAsString(prettyJson);
}

Future<void> cleanupAppointments() async {
  final file = File('data/appointments.json');
  if (!await file.exists()) {
    print('⚠️  Appointments file not found, skipping...\n');
    return;
  }

  final content = await file.readAsString();
  final List<dynamic> appointments = jsonDecode(content);

  print('📅 Total appointments before cleanup: ${appointments.length}');

  // Keep only appointments with patient IDs P001-P050
  final cleaned = appointments.where((a) {
    final patientId = a['patientId'] as String?;
    if (patientId == null) return false;

    final idNum = int.tryParse(patientId.substring(1));
    return idNum != null && idNum >= 1 && idNum <= 50;
  }).toList();

  print('📅 Appointments after cleanup: ${cleaned.length}');
  print(
      '🗑️  Removed: ${appointments.length - cleaned.length} test appointments\n');

  // Write back
  final prettyJson = JsonEncoder.withIndent('  ').convert(cleaned);
  await file.writeAsString(prettyJson);
}
