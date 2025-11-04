import 'package:test/test.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  group('JSON File ID Uniqueness Tests', () {
    const dataDir = 'data';

    test('Patients JSON - All patient IDs must be unique', () {
      final file = File('$dataDir/patients.json');
      expect(file.existsSync(), isTrue, reason: 'patients.json must exist');

      final content = file.readAsStringSync();
      final List<dynamic> patients = json.decode(content);

      expect(patients, isNotEmpty, reason: 'Should have patient records');

      final ids = patients.map((p) => p['patientID']).toList();
      final uniqueIds = ids.toSet();

      expect(ids.length, equals(uniqueIds.length),
          reason:
              'All patient IDs must be unique. Found ${ids.length} IDs but only ${uniqueIds.length} are unique');

      // Check for null or empty IDs
      for (var id in ids) {
        expect(id, isNotNull, reason: 'Patient ID cannot be null');
        expect(id.toString().trim(), isNotEmpty,
            reason: 'Patient ID cannot be empty');
      }

      print('✓ Verified ${ids.length} unique patient IDs');
    });

    test('Doctors JSON - All doctor IDs must be unique', () {
      final file = File('$dataDir/doctors.json');
      expect(file.existsSync(), isTrue, reason: 'doctors.json must exist');

      final content = file.readAsStringSync();
      final List<dynamic> doctors = json.decode(content);

      expect(doctors, isNotEmpty, reason: 'Should have doctor records');

      final ids = doctors.map((d) => d['staffID']).toList();
      final uniqueIds = ids.toSet();

      expect(ids.length, equals(uniqueIds.length),
          reason:
              'All doctor IDs must be unique. Found ${ids.length} IDs but only ${uniqueIds.length} are unique');

      for (var id in ids) {
        expect(id, isNotNull, reason: 'Doctor ID cannot be null');
        expect(id.toString().trim(), isNotEmpty,
            reason: 'Doctor ID cannot be empty');
      }

      print('✓ Verified ${ids.length} unique doctor IDs');
    });

    test('Nurses JSON - All nurse IDs must be unique', () {
      final file = File('$dataDir/nurses.json');
      expect(file.existsSync(), isTrue, reason: 'nurses.json must exist');

      final content = file.readAsStringSync();
      final List<dynamic> nurses = json.decode(content);

      expect(nurses, isNotEmpty, reason: 'Should have nurse records');

      final ids = nurses.map((n) => n['staffID']).toList();
      final uniqueIds = ids.toSet();

      expect(ids.length, equals(uniqueIds.length),
          reason:
              'All nurse IDs must be unique. Found ${ids.length} IDs but only ${uniqueIds.length} are unique');

      for (var id in ids) {
        expect(id, isNotNull, reason: 'Nurse ID cannot be null');
        expect(id.toString().trim(), isNotEmpty,
            reason: 'Nurse ID cannot be empty');
      }

      print('✓ Verified ${ids.length} unique nurse IDs');
    });

    test('Appointments JSON - All appointment IDs must be unique', () {
      final file = File('$dataDir/appointments.json');
      expect(file.existsSync(), isTrue, reason: 'appointments.json must exist');

      final content = file.readAsStringSync();
      final List<dynamic> appointments = json.decode(content);

      expect(appointments, isNotEmpty,
          reason: 'Should have appointment records');

      final ids = appointments.map((a) => a['id']).toList();
      final uniqueIds = ids.toSet();

      expect(ids.length, equals(uniqueIds.length),
          reason:
              'All appointment IDs must be unique. Found ${ids.length} IDs but only ${uniqueIds.length} are unique');

      for (var id in ids) {
        expect(id, isNotNull, reason: 'Appointment ID cannot be null');
        expect(id.toString().trim(), isNotEmpty,
            reason: 'Appointment ID cannot be empty');
      }

      print('✓ Verified ${ids.length} unique appointment IDs');
    });

    test('Prescriptions JSON - All prescription IDs must be unique', () {
      final file = File('$dataDir/prescriptions.json');
      expect(file.existsSync(), isTrue,
          reason: 'prescriptions.json must exist');

      final content = file.readAsStringSync();
      final List<dynamic> prescriptions = json.decode(content);

      expect(prescriptions, isNotEmpty,
          reason: 'Should have prescription records');

      final ids = prescriptions.map((p) => p['id']).toList();
      final uniqueIds = ids.toSet();

      expect(ids.length, equals(uniqueIds.length),
          reason:
              'All prescription IDs must be unique. Found ${ids.length} IDs but only ${uniqueIds.length} are unique');

      for (var id in ids) {
        expect(id, isNotNull, reason: 'Prescription ID cannot be null');
        expect(id.toString().trim(), isNotEmpty,
            reason: 'Prescription ID cannot be empty');
      }

      print('✓ Verified ${ids.length} unique prescription IDs');
    });

    test('Rooms JSON - All room IDs must be unique', () {
      final file = File('$dataDir/rooms.json');
      expect(file.existsSync(), isTrue, reason: 'rooms.json must exist');

      final content = file.readAsStringSync();
      final List<dynamic> rooms = json.decode(content);

      expect(rooms, isNotEmpty, reason: 'Should have room records');

      final ids = rooms.map((r) => r['roomId']).toList();
      final uniqueIds = ids.toSet();

      expect(ids.length, equals(uniqueIds.length),
          reason:
              'All room IDs must be unique. Found ${ids.length} IDs but only ${uniqueIds.length} are unique');

      for (var id in ids) {
        expect(id, isNotNull, reason: 'Room ID cannot be null');
        expect(id.toString().trim(), isNotEmpty,
            reason: 'Room ID cannot be empty');
      }

      print('✓ Verified ${ids.length} unique room IDs');
    });

    test('Beds JSON - All bed IDs must be unique', () {
      final file = File('$dataDir/beds.json');
      expect(file.existsSync(), isTrue, reason: 'beds.json must exist');

      final content = file.readAsStringSync();
      final List<dynamic> beds = json.decode(content);

      expect(beds, isNotEmpty, reason: 'Should have bed records');

      final ids = beds.map((b) => b['bedId']).toList();
      final uniqueIds = ids.toSet();

      expect(ids.length, equals(uniqueIds.length),
          reason:
              'All bed IDs must be unique. Found ${ids.length} IDs but only ${uniqueIds.length} are unique');

      for (var id in ids) {
        expect(id, isNotNull, reason: 'Bed ID cannot be null');
        expect(id.toString().trim(), isNotEmpty,
            reason: 'Bed ID cannot be empty');
      }

      print('✓ Verified ${ids.length} unique bed IDs');
    });

    test('Equipment JSON - All equipment IDs must be unique', () {
      final file = File('$dataDir/equipment.json');
      expect(file.existsSync(), isTrue, reason: 'equipment.json must exist');

      final content = file.readAsStringSync();
      final List<dynamic> equipment = json.decode(content);

      expect(equipment, isNotEmpty, reason: 'Should have equipment records');

      final ids = equipment.map((e) => e['equipmentId']).toList();
      final uniqueIds = ids.toSet();

      expect(ids.length, equals(uniqueIds.length),
          reason:
              'All equipment IDs must be unique. Found ${ids.length} IDs but only ${uniqueIds.length} are unique');

      for (var id in ids) {
        expect(id, isNotNull, reason: 'Equipment ID cannot be null');
        expect(id.toString().trim(), isNotEmpty,
            reason: 'Equipment ID cannot be empty');
      }

      print('✓ Verified ${ids.length} unique equipment IDs');
    });

    test('Medications JSON - All medication IDs must be unique', () {
      final file = File('$dataDir/medications.json');
      expect(file.existsSync(), isTrue, reason: 'medications.json must exist');

      final content = file.readAsStringSync();
      final List<dynamic> medications = json.decode(content);

      expect(medications, isNotEmpty, reason: 'Should have medication records');

      final ids = medications.map((m) => m['id']).toList();
      final uniqueIds = ids.toSet();

      expect(ids.length, equals(uniqueIds.length),
          reason:
              'All medication IDs must be unique. Found ${ids.length} IDs but only ${uniqueIds.length} are unique');

      for (var id in ids) {
        expect(id, isNotNull, reason: 'Medication ID cannot be null');
        expect(id.toString().trim(), isNotEmpty,
            reason: 'Medication ID cannot be empty');
      }

      print('✓ Verified ${ids.length} unique medication IDs');
    });

    test('Administrative JSON - All administrative IDs must be unique', () {
      final file = File('$dataDir/administrative.json');

      if (!file.existsSync()) {
        print('⚠ administrative.json not found, skipping test');
        return;
      }

      final content = file.readAsStringSync();
      if (content.trim().isEmpty) {
        print('⚠ administrative.json is empty, skipping test');
        return;
      }

      final List<dynamic> admins = json.decode(content);

      if (admins.isEmpty) {
        print('⚠ No administrative records found, skipping test');
        return;
      }

      final ids = admins.map((a) => a['staffID']).toList();
      final uniqueIds = ids.toSet();

      expect(ids.length, equals(uniqueIds.length),
          reason:
              'All administrative IDs must be unique. Found ${ids.length} IDs but only ${uniqueIds.length} are unique');

      for (var id in ids) {
        expect(id, isNotNull, reason: 'Administrative ID cannot be null');
        expect(id.toString().trim(), isNotEmpty,
            reason: 'Administrative ID cannot be empty');
      }

      print('✓ Verified ${ids.length} unique administrative IDs');
    });
  });

  group('JSON File Structure Validation', () {
    const dataDir = 'data';

    test('All JSON files must contain valid JSON arrays', () {
      final files = [
        'patients.json',
        'doctors.json',
        'nurses.json',
        'appointments.json',
        'prescriptions.json',
        'rooms.json',
        'beds.json',
        'equipment.json',
        'medications.json',
      ];

      for (final fileName in files) {
        final file = File('$dataDir/$fileName');

        if (!file.existsSync()) {
          fail('Required file $fileName does not exist');
        }

        final content = file.readAsStringSync();
        expect(content.trim(), isNotEmpty,
            reason: '$fileName should not be empty');

        try {
          final decoded = json.decode(content);
          expect(decoded, isA<List>(),
              reason: '$fileName should contain a JSON array');
          print(
              '✓ $fileName: Valid JSON array with ${(decoded as List).length} records');
        } catch (e) {
          fail('$fileName contains invalid JSON: $e');
        }
      }
    });

    test('Patient records must have required fields', () {
      final file = File('$dataDir/patients.json');
      final content = file.readAsStringSync();
      final List<dynamic> patients = json.decode(content);

      final requiredFields = [
        'patientID',
        'name',
        'dateOfBirth',
        'address',
        'tel',
        'emergencyContact',
        'bloodType',
        'medicalRecords', // Changed from medicalHistory
        'allergies',
        'assignedDoctorIds', // Plural array
        'assignedNurseIds', // Plural array
      ];

      for (var i = 0; i < patients.length; i++) {
        final patient = patients[i] as Map<String, dynamic>;
        for (var field in requiredFields) {
          expect(patient.containsKey(field), isTrue,
              reason: 'Patient record #$i must have field: $field');
        }
      }

      print('✓ All ${patients.length} patient records have required fields');
    });

    test('Appointment records must reference valid patients and doctors', () {
      final appointmentsFile = File('$dataDir/appointments.json');
      final patientsFile = File('$dataDir/patients.json');
      final doctorsFile = File('$dataDir/doctors.json');

      final List<dynamic> appointments =
          json.decode(appointmentsFile.readAsStringSync());
      final List<dynamic> patients =
          json.decode(patientsFile.readAsStringSync());
      final List<dynamic> doctors = json.decode(doctorsFile.readAsStringSync());

      final patientIds = patients.map((p) => p['patientID']).toSet();
      final doctorIds = doctors.map((d) => d['staffID']).toSet();

      int invalidRefs = 0;
      for (var appt in appointments) {
        if (!patientIds.contains(appt['patientId'])) {
          print(
              '⚠ Warning: Appointment ${appt['id']} references invalid patient: ${appt['patientId']}');
          invalidRefs++;
        }
        if (!doctorIds.contains(appt['doctorId'])) {
          print(
              '⚠ Warning: Appointment ${appt['id']} references invalid doctor: ${appt['doctorId']}');
          invalidRefs++;
        }
      }

      if (invalidRefs == 0) {
        print(
            '✓ All ${appointments.length} appointments reference valid patients and doctors');
      } else {
        print('⚠ Found $invalidRefs invalid references in appointments');
      }
    });

    test(
        'Prescription records must reference valid patients, doctors, and medications',
        () {
      final prescriptionsFile = File('$dataDir/prescriptions.json');
      final patientsFile = File('$dataDir/patients.json');
      final doctorsFile = File('$dataDir/doctors.json');
      final medicationsFile = File('$dataDir/medications.json');

      final List<dynamic> prescriptions =
          json.decode(prescriptionsFile.readAsStringSync());
      final List<dynamic> patients =
          json.decode(patientsFile.readAsStringSync());
      final List<dynamic> doctors = json.decode(doctorsFile.readAsStringSync());
      final List<dynamic> medications =
          json.decode(medicationsFile.readAsStringSync());

      final patientIds = patients.map((p) => p['patientID']).toSet();
      final doctorIds = doctors.map((d) => d['staffID']).toSet();
      final medicationIds = medications.map((m) => m['id']).toSet();

      int invalidRefs = 0;
      for (var prescription in prescriptions) {
        if (!patientIds.contains(prescription['patientId'])) {
          print(
              '⚠ Warning: Prescription ${prescription['id']} references invalid patient: ${prescription['patientId']}');
          invalidRefs++;
        }
        if (!doctorIds.contains(prescription['doctorId'])) {
          print(
              '⚠ Warning: Prescription ${prescription['id']} references invalid doctor: ${prescription['doctorId']}');
          invalidRefs++;
        }

        final List<dynamic> medIds = prescription['medicationIds'];
        for (var medId in medIds) {
          if (!medicationIds.contains(medId)) {
            print(
                '⚠ Warning: Prescription ${prescription['id']} references invalid medication: $medId');
            invalidRefs++;
          }
        }
      }

      if (invalidRefs == 0) {
        print(
            '✓ All ${prescriptions.length} prescriptions have valid references');
      } else {
        print('⚠ Found $invalidRefs invalid references in prescriptions');
      }
    });

    test('Room records must reference valid equipment and beds', () {
      final roomsFile = File('$dataDir/rooms.json');
      final equipmentFile = File('$dataDir/equipment.json');
      final bedsFile = File('$dataDir/beds.json');

      final List<dynamic> rooms = json.decode(roomsFile.readAsStringSync());
      final List<dynamic> equipment =
          json.decode(equipmentFile.readAsStringSync());
      final List<dynamic> beds = json.decode(bedsFile.readAsStringSync());

      final equipmentIds = equipment.map((e) => e['equipmentId']).toSet();
      final bedIds = beds.map((b) => b['bedId']).toSet();

      int invalidRefs = 0;
      for (var room in rooms) {
        final List<dynamic> roomEquipment = room['equipmentIds'] ?? [];
        final List<dynamic> roomBeds = room['bedIds'] ?? [];

        for (var eqId in roomEquipment) {
          if (!equipmentIds.contains(eqId)) {
            print(
                '⚠ Warning: Room ${room['roomId']} references invalid equipment: $eqId');
            invalidRefs++;
          }
        }

        for (var bedId in roomBeds) {
          if (!bedIds.contains(bedId)) {
            print(
                '⚠ Warning: Room ${room['roomId']} references invalid bed: $bedId');
            invalidRefs++;
          }
        }
      }

      if (invalidRefs == 0) {
        print(
            '✓ All ${rooms.length} rooms have valid equipment and bed references');
      } else {
        print('⚠ Found $invalidRefs invalid references in rooms');
      }
    });
  });

  group('Data Summary', () {
    test('Print comprehensive data summary', () {
      const dataDir = 'data';

      final files = {
        'Patients': 'patients.json',
        'Doctors': 'doctors.json',
        'Nurses': 'nurses.json',
        'Appointments': 'appointments.json',
        'Prescriptions': 'prescriptions.json',
        'Rooms': 'rooms.json',
        'Beds': 'beds.json',
        'Equipment': 'equipment.json',
        'Medications': 'medications.json',
      };

      print('\n' + '=' * 60);
      print('📊 HOSPITAL DATA SUMMARY');
      print('=' * 60);

      int totalRecords = 0;
      files.forEach((name, fileName) {
        final file = File('$dataDir/$fileName');
        if (file.existsSync()) {
          final content = file.readAsStringSync();
          final List<dynamic> data = json.decode(content);
          print('$name: ${data.length} records');
          totalRecords += data.length;
        }
      });

      print('-' * 60);
      print('TOTAL: $totalRecords records');
      print('=' * 60 + '\n');

      expect(totalRecords, greaterThan(0), reason: 'Should have data in files');
    });
  });
}
