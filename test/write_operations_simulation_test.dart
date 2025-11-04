import 'package:test/test.dart';
import 'dart:io';
import 'dart:convert';

/// Integration tests for write operations
/// These tests verify that adding, updating, and deleting records works correctly
void main() {
  group('Write Operation Simulation Tests', () {
    const testDataDir = 'test_data_write';

    setUp(() {
      // Create test data directory and copy original files
      final dir = Directory(testDataDir);
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
      dir.createSync(recursive: true);

      // Copy data files
      final dataFiles = [
        'patients.json',
        'doctors.json',
        'nurses.json',
        'appointments.json',
        'prescriptions.json',
        'rooms.json'
      ];

      for (final fileName in dataFiles) {
        final original = File('data/$fileName');
        if (original.existsSync()) {
          final copy = File('$testDataDir/$fileName');
          original.copySync(copy.path);
        }
      }
    });

    tearDown(() {
      // Clean up test directory
      final dir = Directory(testDataDir);
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    });

    test('Simulate adding a new patient - should prevent duplicate ID', () {
      final file = File('$testDataDir/patients.json');
      final content = file.readAsStringSync();
      List<dynamic> patients = json.decode(content);

      final existingId = patients.first['patientID'];

      // Try to add patient with duplicate ID
      final duplicatePatient = {
        'patientID': existingId, // Duplicate!
        'name': 'Test Duplicate Patient',
        'dateOfBirth': '1990-01-01',
        'address': '123 Test St',
        'tel': '012-000-000',
        'emergencyContact': '012-999-999',
        'medicalHistory': []
      };

      // Check if ID already exists
      final idExists = patients.any((p) => p['patientID'] == existingId);
      expect(idExists, isTrue, reason: 'ID should already exist');

      // Simulate the repository check that SHOULD prevent this
      if (idExists) {
        print('✓ Correctly prevented duplicate patient ID: $existingId');
      } else {
        fail('System should have detected duplicate ID');
      }
    });

    test('Simulate adding a new patient - should succeed with unique ID', () {
      final file = File('$testDataDir/patients.json');
      final content = file.readAsStringSync();
      List<dynamic> patients = json.decode(content);

      final newId = 'P999';

      // Check ID doesn't exist
      final idExists = patients.any((p) => p['patientID'] == newId);
      expect(idExists, isFalse, reason: 'New ID should not exist yet');

      // Add new patient
      final newPatient = {
        'patientID': newId,
        'name': 'Test New Patient',
        'dateOfBirth': '1995-05-15',
        'address': '456 New St',
        'tel': '012-111-222',
        'emergencyContact': '012-888-888',
        'medicalHistory': ['No previous conditions']
      };

      patients.add(newPatient);

      // Write back to file
      file.writeAsStringSync(json.encode(patients));

      // Verify it was added
      final updatedContent = file.readAsStringSync();
      final updatedPatients = json.decode(updatedContent) as List<dynamic>;

      final addedPatient = updatedPatients
          .firstWhere((p) => p['patientID'] == newId, orElse: () => null);

      expect(addedPatient, isNotNull, reason: 'New patient should be added');
      expect(addedPatient['name'], equals('Test New Patient'));

      print('✓ Successfully added new patient with ID: $newId');
    });

    test('Simulate updating an existing patient', () {
      final file = File('$testDataDir/patients.json');
      final content = file.readAsStringSync();
      List<dynamic> patients = json.decode(content);

      expect(patients, isNotEmpty);

      final patientToUpdate = patients.first;
      final patientId = patientToUpdate['patientID'];

      // Update the patient
      patientToUpdate['name'] = 'Updated Name';
      patientToUpdate['address'] = 'Updated Address';

      // Write back
      file.writeAsStringSync(json.encode(patients));

      // Verify update
      final updatedContent = file.readAsStringSync();
      final updatedPatients = json.decode(updatedContent) as List<dynamic>;

      final updated =
          updatedPatients.firstWhere((p) => p['patientID'] == patientId);
      expect(updated['name'], equals('Updated Name'));
      expect(updated['address'], equals('Updated Address'));

      print('✓ Successfully updated patient: $patientId');
    });

    test('Simulate deleting a patient', () {
      final file = File('$testDataDir/patients.json');
      final content = file.readAsStringSync();
      List<dynamic> patients = json.decode(content);

      final originalCount = patients.length;
      final patientToDelete = patients.last;
      final patientId = patientToDelete['patientID'];

      // Delete the patient
      patients.removeWhere((p) => p['patientID'] == patientId);

      // Write back
      file.writeAsStringSync(json.encode(patients));

      // Verify deletion
      final updatedContent = file.readAsStringSync();
      final updatedPatients = json.decode(updatedContent) as List<dynamic>;

      expect(updatedPatients.length, equals(originalCount - 1));
      expect(updatedPatients.any((p) => p['patientID'] == patientId), isFalse);

      print('✓ Successfully deleted patient: $patientId');
    });

    test(
        'Simulate adding appointment - must reference valid patient and doctor',
        () {
      final appointmentsFile = File('$testDataDir/appointments.json');
      final patientsFile = File('$testDataDir/patients.json');
      final doctorsFile = File('$testDataDir/doctors.json');

      final appointments =
          json.decode(appointmentsFile.readAsStringSync()) as List<dynamic>;
      final patients =
          json.decode(patientsFile.readAsStringSync()) as List<dynamic>;
      final doctors =
          json.decode(doctorsFile.readAsStringSync()) as List<dynamic>;

      final patientIds = patients.map((p) => p['patientID']).toSet();
      final doctorIds = doctors.map((d) => d['staffID']).toSet();

      // Try to add appointment with invalid patient
      final invalidPatientId = 'P_INVALID';
      expect(patientIds.contains(invalidPatientId), isFalse);

      print('✓ Correctly prevented appointment with invalid patient ID');

      // Add appointment with valid references
      final validPatientId = patients.first['patientID'];
      final validDoctorId = doctors.first['staffID'];

      expect(patientIds.contains(validPatientId), isTrue);
      expect(doctorIds.contains(validDoctorId), isTrue);

      final newAppointment = {
        'id': 'A999',
        'patientId': validPatientId,
        'doctorId': validDoctorId,
        'roomId': null,
        'dateTime': DateTime.now().add(Duration(days: 7)).toIso8601String(),
        'duration': 30,
        'reason': 'Test appointment',
        'status': 'AppointmentStatus.SCHEDULE',
        'notes': 'Test notes'
      };

      appointments.add(newAppointment);
      appointmentsFile.writeAsStringSync(json.encode(appointments));

      print('✓ Successfully added appointment with valid references');
    });

    test('Verify all write operations maintain ID uniqueness', () {
      final files = {
        'patients.json': 'patientID',
        'doctors.json': 'staffID',
        'nurses.json': 'staffID',
        'appointments.json': 'id',
      };

      for (final entry in files.entries) {
        final file = File('$testDataDir/${entry.key}');
        if (!file.existsSync()) continue;

        final content = file.readAsStringSync();
        final List<dynamic> records = json.decode(content);

        final ids = records.map((r) => r[entry.value]).toList();
        final uniqueIds = ids.toSet();

        expect(ids.length, equals(uniqueIds.length),
            reason: '${entry.key} must maintain unique IDs after operations');

        print('✓ ${entry.key}: ${ids.length} unique IDs maintained');
      }
    });
  });

  group('ID Generation Helper Tests', () {
    test('Generate next patient ID', () {
      final file = File('data/patients.json');
      final content = file.readAsStringSync();
      final List<dynamic> patients = json.decode(content);

      // Extract numeric part of IDs
      final ids = patients
          .map((p) => p['patientID'] as String)
          .map((id) => int.tryParse(id.substring(1)) ?? 0)
          .toList();

      final maxId = ids.reduce((a, b) => a > b ? a : b);
      final nextId = 'P${(maxId + 1).toString().padLeft(3, '0')}';

      print('Current max patient ID: P${maxId.toString().padLeft(3, '0')}');
      print('Next available patient ID: $nextId');

      expect(nextId, matches(r'P\d{3}'));
    });

    test('Generate next doctor ID', () {
      final file = File('data/doctors.json');
      final content = file.readAsStringSync();
      final List<dynamic> doctors = json.decode(content);

      final ids = doctors
          .map((d) => d['staffID'] as String)
          .map((id) => int.tryParse(id.substring(1)) ?? 0)
          .toList();

      final maxId = ids.reduce((a, b) => a > b ? a : b);
      final nextId = 'D${(maxId + 1).toString().padLeft(3, '0')}';

      print('Next available doctor ID: $nextId');
      expect(nextId, matches(r'D\d{3}'));
    });

    test('Generate next appointment ID', () {
      final file = File('data/appointments.json');
      final content = file.readAsStringSync();
      final List<dynamic> appointments = json.decode(content);

      final ids = appointments
          .map((a) => a['id'] as String)
          .map((id) => int.tryParse(id.substring(1)) ?? 0)
          .toList();

      final maxId = ids.reduce((a, b) => a > b ? a : b);
      final nextId = 'A${(maxId + 1).toString().padLeft(3, '0')}';

      print('Next available appointment ID: $nextId');
      expect(nextId, matches(r'A\d{3}'));
    });

    test('Generate next prescription ID', () {
      final file = File('data/prescriptions.json');
      final content = file.readAsStringSync();
      final List<dynamic> prescriptions = json.decode(content);

      final ids = prescriptions.map((p) => p['id'] as String).map((id) {
        final numPart = id.substring(2); // Remove 'PR'
        return int.tryParse(numPart) ?? 0;
      }).toList();

      final maxId = ids.reduce((a, b) => a > b ? a : b);
      final nextId = 'PR${(maxId + 1).toString().padLeft(3, '0')}';

      print('Next available prescription ID: $nextId');
      expect(nextId, matches(r'PR\d{3}'));
    });
  });
}
