import '../lib/data/models/doctor_model.dart';
import '../lib/data/models/nurse_model.dart';
import '../lib/data/models/administrative_model.dart';

void main() async {
  print('Testing schedule format integration...');

  // Test doctor schedule parsing
  await testDoctorSchedule();

  // Test nurse schedule parsing
  await testNurseSchedule();

  // Test administrative schedule parsing
  await testAdministrativeSchedule();

  print('All tests completed successfully!');
}

Future<void> testDoctorSchedule() async {
  print('\n=== Testing Doctor Schedule ===');

  final sampleJson = {
    "staffID": "D001",
    "name": "Dr. Test Doctor",
    "dateOfBirth": "1975-08-20",
    "address": "456 Street 240, Phnom Penh",
    "tel": "012-200-300",
    "hireDate": "2010-03-15T00:00:00.000Z",
    "salary": 120000.0,
    "schedule": {
      "Monday": {
        "start": "2025-11-04T09:00:00.000Z",
        "end": "2025-11-04T17:00:00.000Z"
      },
      "Tuesday": {
        "start": "2025-11-05T09:00:00.000Z",
        "end": "2025-11-05T17:00:00.000Z"
      }
    },
    "specialization": "Cardiology",
    "certifications": ["Board Certified"],
    "currentPatientIds": []
  };

  try {
    final model = DoctorModel.fromJson(sampleJson);
    print('✓ Doctor model created successfully');
    print('  - Staff ID: ${model.staffID}');
    print('  - Name: ${model.name}');
    print('  - Schedule days: ${model.schedule.keys.join(', ')}');

    // Test conversion to entity
    final entity = model.toEntity();
    print('✓ Doctor entity created successfully');
    print('  - Schedule in entity: ${entity.schedule.keys.join(', ')}');

    // Check if times are correctly parsed
    final mondayTimes = entity.getScheduleFor('Monday');
    if (mondayTimes.length == 2) {
      print('✓ Monday schedule: ${mondayTimes[0]} to ${mondayTimes[1]}');
    } else {
      throw Exception('Expected 2 times for Monday, got ${mondayTimes.length}');
    }
  } catch (e) {
    print('✗ Doctor test failed: $e');
    rethrow;
  }
}

Future<void> testNurseSchedule() async {
  print('\n=== Testing Nurse Schedule ===');

  final sampleJson = {
    "staffID": "N001",
    "name": "Test Nurse",
    "dateOfBirth": "1988-06-14",
    "address": "234 Street 136, Phnom Penh",
    "tel": "012-800-900",
    "hireDate": "2018-04-12T00:00:00.000Z",
    "salary": 45000.0,
    "schedule": {
      "Monday": {
        "start": "2025-11-04T07:00:00.000Z",
        "end": "2025-11-04T19:00:00.000Z"
      },
      "Wednesday": {
        "start": "2025-11-06T07:00:00.000Z",
        "end": "2025-11-06T19:00:00.000Z"
      }
    },
    "assignedRoomIds": ["R101"],
    "assignedPatientIds": []
  };

  try {
    final model = NurseModel.fromJson(sampleJson);
    print('✓ Nurse model created successfully');
    print('  - Staff ID: ${model.staffID}');
    print('  - Name: ${model.name}');
    print('  - Schedule days: ${model.schedule.keys.join(', ')}');

    // Test conversion to entity
    final entity = model.toEntity();
    print('✓ Nurse entity created successfully');
    print('  - Schedule in entity: ${entity.schedule.keys.join(', ')}');

    // Check if times are correctly parsed
    final mondayTimes = entity.getScheduleFor('Monday');
    if (mondayTimes.length == 2) {
      print('✓ Monday schedule: ${mondayTimes[0]} to ${mondayTimes[1]}');
    } else {
      throw Exception('Expected 2 times for Monday, got ${mondayTimes.length}');
    }
  } catch (e) {
    print('✗ Nurse test failed: $e');
    rethrow;
  }
}

Future<void> testAdministrativeSchedule() async {
  print('\n=== Testing Administrative Schedule ===');

  final sampleJson = {
    "staffID": "A001",
    "name": "Test Admin",
    "dateOfBirth": "1979-07-18",
    "address": "123 Preah Monivong Boulevard, Phnom Penh",
    "tel": "012-555-001",
    "hireDate": "2015-05-20T00:00:00.000Z",
    "salary": 35000.0,
    "schedule": {
      "Monday": {
        "start": "2025-11-04T08:00:00.000Z",
        "end": "2025-11-04T17:00:00.000Z"
      },
      "Friday": {
        "start": "2025-11-08T08:00:00.000Z",
        "end": "2025-11-08T17:00:00.000Z"
      }
    },
    "responsibility": "Hospital Administration"
  };

  try {
    final model = AdministrativeModel.fromJson(sampleJson);
    print('✓ Administrative model created successfully');
    print('  - Staff ID: ${model.staffID}');
    print('  - Name: ${model.name}');
    print('  - Schedule days: ${model.schedule.keys.join(', ')}');
    print('  - Responsibility: ${model.responsibility}');

    // Test conversion to entity
    final entity = model.toEntity();
    print('✓ Administrative entity created successfully');
    print('  - Schedule in entity: ${entity.schedule.keys.join(', ')}');

    // Check if times are correctly parsed
    final mondayTimes = entity.getScheduleFor('Monday');
    if (mondayTimes.length == 2) {
      print('✓ Monday schedule: ${mondayTimes[0]} to ${mondayTimes[1]}');
    } else {
      throw Exception('Expected 2 times for Monday, got ${mondayTimes.length}');
    }
  } catch (e) {
    print('✗ Administrative test failed: $e');
    rethrow;
  }
}
