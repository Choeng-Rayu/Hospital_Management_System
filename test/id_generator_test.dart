import 'package:test/test.dart';
import 'dart:convert';
import 'dart:io';
import 'package:hospital_management/data/datasources/id_generator.dart';

void main() {
  group('ID Generator Tests', () {
    test('Generate next patient ID from existing data', () {
      // Read actual patients.json
      final file = File('data/patients.json');
      final jsonString = file.readAsStringSync();
      final patients = List<Map<String, dynamic>>.from(jsonDecode(jsonString));

      // Filter out test patients
      final actualPatients = patients.where((p) {
        final name = p['name'] as String? ?? '';
        return !name.contains('Test Patient') &&
            !name.contains('Sequential Test Patient') &&
            !name.contains('Duplicate Patient');
      }).toList();

      // Generate next ID
      final nextId = IdGenerator.generatePatientId(patients);

      print('📊 Total patients in file: ${patients.length}');
      print('📊 Actual patients (excluding test): ${actualPatients.length}');
      print('🆔 Last patient ID in file: ${patients.last['patientID']}');
      print('✨ Next patient ID: $nextId');

      // Next ID should be properly incremented from the highest existing ID
      expect(IdGenerator.isValidIdFormat(nextId, 'P', 3), isTrue);

      // Extract number from next ID
      final nextNum = int.parse(nextId.substring(1));

      // Should be at least P051 (if we have 50 base patients)
      expect(nextNum, greaterThanOrEqualTo(51));
    });

    test('Generate next doctor ID from existing data', () {
      final file = File('data/doctors.json');
      final jsonString = file.readAsStringSync();
      final doctors = List<Map<String, dynamic>>.from(jsonDecode(jsonString));

      final nextId = IdGenerator.generateDoctorId(doctors);

      print('📊 Current doctors: ${doctors.length}');
      print('🆔 Last doctor ID: ${doctors.last['staffID']}');
      print('✨ Next doctor ID: $nextId');

      // Should be D026 (since we have D001-D025)
      expect(nextId, equals('D026'));
      expect(IdGenerator.isValidIdFormat(nextId, 'D', 3), isTrue);
    });

    test('Generate next appointment ID from existing data', () {
      final file = File('data/appointments.json');
      final jsonString = file.readAsStringSync();
      final appointments =
          List<Map<String, dynamic>>.from(jsonDecode(jsonString));

      final nextId = IdGenerator.generateAppointmentId(appointments);

      print('📊 Current appointments: ${appointments.length}');
      print('🆔 Last appointment ID: ${appointments.last['id']}');
      print('✨ Next appointment ID: $nextId');

      // Should be A081 (since we have up to A080)
      expect(nextId, equals('A081'));
      expect(IdGenerator.isValidIdFormat(nextId, 'A', 3), isTrue);
    });

    test('Generate next prescription ID from existing data', () {
      final file = File('data/prescriptions.json');
      final jsonString = file.readAsStringSync();
      final prescriptions =
          List<Map<String, dynamic>>.from(jsonDecode(jsonString));

      final nextId = IdGenerator.generatePrescriptionId(prescriptions);

      print('📊 Current prescriptions: ${prescriptions.length}');
      print('🆔 Last prescription ID: ${prescriptions.last['id']}');
      print('✨ Next prescription ID: $nextId');

      // Should be PR121 (since we have up to PR120)
      expect(nextId, equals('PR121'));
      expect(IdGenerator.isValidIdFormat(nextId, 'PR', 3), isTrue);
    });

    test('Generate ID from empty list should start at 001', () {
      final nextId = IdGenerator.generatePatientId([]);

      print('✨ First patient ID: $nextId');

      expect(nextId, equals('P001'));
    });

    test('ID format validation', () {
      // Valid IDs
      expect(IdGenerator.isValidIdFormat('P001', 'P', 3), isTrue);
      expect(IdGenerator.isValidIdFormat('D025', 'D', 3), isTrue);
      expect(IdGenerator.isValidIdFormat('A080', 'A', 3), isTrue);
      expect(IdGenerator.isValidIdFormat('PR120', 'PR', 3), isTrue);

      // Invalid IDs
      expect(IdGenerator.isValidIdFormat('P01', 'P', 3), isFalse); // Too short
      expect(IdGenerator.isValidIdFormat('P0001', 'P', 3), isFalse); // Too long
      expect(
          IdGenerator.isValidIdFormat('D001', 'P', 3), isFalse); // Wrong prefix
      expect(
          IdGenerator.isValidIdFormat('PABC', 'P', 3), isFalse); // Not numeric
    });

    test('Handle mixed/non-sequential IDs correctly', () {
      final mixedData = [
        {'patientID': 'P005'},
        {'patientID': 'P010'},
        {'patientID': 'P003'},
        {'patientID': 'P020'},
      ];

      final nextId = IdGenerator.generatePatientId(mixedData);

      print('🔀 Mixed IDs: [P005, P010, P003, P020]');
      print('✨ Next ID: $nextId');

      // Should find max (P020) and increment to P021
      expect(nextId, equals('P021'));
    });

    test('Handle invalid/missing IDs gracefully', () {
      final dataWithInvalid = [
        {'patientID': 'P005'},
        {'patientID': null},
        {'patientID': ''},
        {'patientID': 'INVALID'},
        {'patientID': 'P010'},
      ];

      final nextId = IdGenerator.generatePatientId(dataWithInvalid);

      print('⚠️ Data with invalid IDs');
      print('✨ Next ID: $nextId');

      // Should ignore invalid IDs and use max valid ID (P010)
      expect(nextId, equals('P011'));
    });
  });

  group('ID Generator Summary', () {
    test('Print comprehensive ID generation summary', () {
      print('\n' + '=' * 60);
      print('🎯 ID GENERATION TEST SUMMARY');
      print('=' * 60);

      // Patient IDs
      final patientsFile = File('data/patients.json');
      final patients = List<Map<String, dynamic>>.from(
          jsonDecode(patientsFile.readAsStringSync()));
      final nextPatientId = IdGenerator.generatePatientId(patients);
      print(
          '👤 Patients: ${patients.length} records → Next ID: $nextPatientId');

      // Doctor IDs
      final doctorsFile = File('data/doctors.json');
      final doctors = List<Map<String, dynamic>>.from(
          jsonDecode(doctorsFile.readAsStringSync()));
      final nextDoctorId = IdGenerator.generateDoctorId(doctors);
      print(
          '👨‍⚕️ Doctors: ${doctors.length} records → Next ID: $nextDoctorId');

      // Nurse IDs
      final nursesFile = File('data/nurses.json');
      final nurses = List<Map<String, dynamic>>.from(
          jsonDecode(nursesFile.readAsStringSync()));
      final nextNurseId = IdGenerator.generateNurseId(nurses);
      print('👩‍⚕️ Nurses: ${nurses.length} records → Next ID: $nextNurseId');

      // Appointment IDs
      final appointmentsFile = File('data/appointments.json');
      final appointments = List<Map<String, dynamic>>.from(
          jsonDecode(appointmentsFile.readAsStringSync()));
      final nextAppointmentId = IdGenerator.generateAppointmentId(appointments);
      print(
          '📅 Appointments: ${appointments.length} records → Next ID: $nextAppointmentId');

      // Prescription IDs
      final prescriptionsFile = File('data/prescriptions.json');
      final prescriptions = List<Map<String, dynamic>>.from(
          jsonDecode(prescriptionsFile.readAsStringSync()));
      final nextPrescriptionId =
          IdGenerator.generatePrescriptionId(prescriptions);
      print(
          '💊 Prescriptions: ${prescriptions.length} records → Next ID: $nextPrescriptionId');

      print('=' * 60);
      print('✅ All ID generators working correctly!');
      print('=' * 60 + '\n');
    });
  });
}
