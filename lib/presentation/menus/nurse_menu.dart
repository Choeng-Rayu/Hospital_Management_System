import 'package:hospital_management/domain/repositories/nurse_repository.dart';
import 'package:hospital_management/domain/repositories/patient_repository.dart';
import 'package:hospital_management/domain/entities/nurse.dart';
import 'package:hospital_management/presentation/menus/base_menu.dart';
import 'package:hospital_management/presentation/utils/ui_helper.dart';
import 'package:hospital_management/presentation/utils/input_validator.dart';

class NurseMenu extends BaseMenu {
  final NurseRepository nurseRepository;
  final PatientRepository patientRepository;

  NurseMenu({
    required this.nurseRepository,
    required this.patientRepository,
  });

  @override
  String get menuTitle => 'NURSE MANAGEMENT';

  @override
  List<String> get menuOptions => [
        'Add New Nurse',
        'View All Nurses',
        'Search Nurse',
        'View Nurse Details',
        'Update Nurse',
        'Delete Nurse',
        'View Nurse Schedule',
        'Assign Nurse to Patient',
      ];

  @override
  Future<void> handleChoice(int choice) async {
    switch (choice) {
      case 1:
        await _addNurse();
        break;
      case 2:
        await _viewAllNurses();
        break;
      case 3:
        await _searchNurse();
        break;
      case 4:
        await _viewNurseDetails();
        break;
      case 5:
        await _updateNurse();
        break;
      case 6:
        await _deleteNurse();
        break;
      case 7:
        await _viewNurseSchedule();
        break;
      case 8:
        await _assignNurseToPatient();
        break;
    }
  }

  Future<void> _addNurse() async {
    UIHelper.printHeader('Add New Nurse');

    try {
      // Generate staff ID
      final allNurses = await nurseRepository.getAllNurses();
      final staffId = 'N${(allNurses.length + 1).toString().padLeft(3, '0')}';

      // Get nurse information
      final name = InputValidator.readString('Enter nurse name');
      final dob = InputValidator.readString('Enter date of birth (YYYY-MM-DD)');
      final address = InputValidator.readString('Enter address');
      final tel = InputValidator.readString('Enter telephone');

      // Get hire date
      final hireDate = InputValidator.readDate('Enter hire date');

      // Get salary
      final salaryInput = InputValidator.readString('Enter salary');
      final salary = double.parse(salaryInput);

      // Create empty schedule and assignments
      final schedule = <String, List<DateTime>>{};

      final nurse = Nurse(
        name: name,
        dateOfBirth: dob,
        address: address,
        tel: tel,
        staffID: staffId,
        hireDate: hireDate,
        salary: salary,
        schedule: schedule,
        assignedRooms: [],
        assignedPatients: [],
      );

      await nurseRepository.saveNurse(nurse);

      UIHelper.printSuccess('Nurse added successfully!');
      UIHelper.printInfo('Staff ID: $staffId');
      UIHelper.printInfo('Name: $name');
    } catch (e) {
      UIHelper.printError('Failed to add nurse: $e');
    }
  }

  Future<void> _viewAllNurses() async {
    UIHelper.printHeader('All Nurses');

    try {
      final nurses = await nurseRepository.getAllNurses();

      if (nurses.isEmpty) {
        UIHelper.printWarning('No nurses found');
        return;
      }

      final tableData = nurses
          .map((nurse) => [
                nurse.staffID,
                nurse.name,
                nurse.tel,
                nurse.patientCount.toString(),
                nurse.roomCount.toString(),
                '\$${nurse.salary.toStringAsFixed(2)}',
              ])
          .toList();

      UIHelper.printTable(
        tableData,
        headers: ['Staff ID', 'Name', 'Phone', 'Patients', 'Rooms', 'Salary'],
      );

      UIHelper.printInfo('Total nurses: ${nurses.length}');
    } catch (e) {
      UIHelper.printError('Failed to retrieve nurses: $e');
    }
  }

  Future<void> _searchNurse() async {
    UIHelper.printHeader('Search Nurse');

    try {
      final name = InputValidator.readString('Enter nurse name to search');
      final nurses = await nurseRepository.searchNursesByName(name);

      if (nurses.isEmpty) {
        UIHelper.printWarning('No nurses found matching "$name"');
        return;
      }

      final tableData = nurses
          .map((nurse) => [
                nurse.staffID,
                nurse.name,
                nurse.tel,
                nurse.patientCount.toString(),
                nurse.roomCount.toString(),
              ])
          .toList();

      UIHelper.printTable(
        tableData,
        headers: ['Staff ID', 'Name', 'Phone', 'Patients', 'Rooms'],
      );

      UIHelper.printInfo('Found ${nurses.length} nurses');
    } catch (e) {
      UIHelper.printError('Failed to search nurses: $e');
    }
  }

  Future<void> _viewNurseDetails() async {
    UIHelper.printHeader('Nurse Details');

    try {
      final staffId = InputValidator.readId('Enter staff ID', 'N');
      final nurse = await nurseRepository.getNurseById(staffId);

      _displayNurseDetails(nurse);
    } catch (e) {
      UIHelper.printError('Failed to retrieve nurse details: $e');
    }
  }

  Future<void> _updateNurse() async {
    UIHelper.printHeader('Update Nurse');

    try {
      final staffId = InputValidator.readId('Enter staff ID', 'N');
      final nurse = await nurseRepository.getNurseById(staffId);

      _displayNurseDetails(nurse);

      UIHelper.printSubHeader('Update Options');
      print('1. Update Salary');
      print('2. Update Phone');
      print('3. Update Address');

      final updateChoice = InputValidator.readChoice(3);
      if (updateChoice == 0) return;

      // Note: Since Nurse fields are final, we would need to recreate
      // the nurse object with updated values. For this implementation,
      // we'll show the concept:
      UIHelper.printWarning('Update feature requires entity modification');
      UIHelper.printInfo('Current implementation stores immutable entities');

      // In a real system, you'd either:
      // 1. Make fields mutable with setters
      // 2. Create a new nurse instance with updated values
      // 3. Use a separate UpdateNurse use case
    } catch (e) {
      UIHelper.printError('Failed to update nurse: $e');
    }
  }

  Future<void> _deleteNurse() async {
    UIHelper.printHeader('Delete Nurse');

    try {
      final staffId = InputValidator.readId('Enter staff ID', 'N');
      final nurse = await nurseRepository.getNurseById(staffId);

      _displayNurseDetails(nurse);

      if (nurse.patientCount > 0) {
        UIHelper.printWarning(
          'Warning: This nurse has ${nurse.patientCount} assigned patients',
        );
      }

      final confirm = InputValidator.readBoolean(
        'Are you sure you want to delete this nurse?',
      );

      if (!confirm) {
        UIHelper.printInfo('Deletion cancelled');
        return;
      }

      await nurseRepository.deleteNurse(staffId);
      UIHelper.printSuccess('Nurse deleted successfully');
    } catch (e) {
      UIHelper.printError('Failed to delete nurse: $e');
    }
  }

  Future<void> _viewNurseSchedule() async {
    UIHelper.printHeader('Nurse Schedule');

    try {
      final staffId = InputValidator.readId('Enter staff ID', 'N');
      final nurse = await nurseRepository.getNurseById(staffId);

      UIHelper.printSubHeader('Schedule for ${nurse.name}');

      if (nurse.schedule.isEmpty) {
        UIHelper.printWarning('No schedule found for this nurse');
        return;
      }

      for (final entry in nurse.schedule.entries) {
        print('\n${entry.key}:');
        for (final dateTime in entry.value) {
          print('  - ${UIHelper.formatDateTime(dateTime)}');
        }
      }
    } catch (e) {
      UIHelper.printError('Failed to retrieve nurse schedule: $e');
    }
  }

  Future<void> _assignNurseToPatient() async {
    UIHelper.printHeader('Assign Nurse to Patient');

    try {
      final nurseId = InputValidator.readId('Enter nurse staff ID', 'N');
      final nurse = await nurseRepository.getNurseById(nurseId);

      UIHelper.printInfo('Nurse: ${nurse.name}');
      UIHelper.printInfo('Current patients: ${nurse.patientCount}');

      final patientId = InputValidator.readId('Enter patient ID', 'P');
      final patient = await patientRepository.getPatientById(patientId);

      UIHelper.printInfo('Patient: ${patient.name}');

      final confirm = InputValidator.readBoolean(
        'Assign ${nurse.name} to ${patient.name}?',
      );

      if (!confirm) {
        UIHelper.printInfo('Assignment cancelled');
        return;
      }

      nurse.assignPatient(patient);
      await nurseRepository.updateNurse(nurse);

      UIHelper.printSuccess('Nurse assigned to patient successfully!');
      UIHelper.printInfo('Nurse: ${nurse.name}');
      UIHelper.printInfo('Patient: ${patient.name}');
      UIHelper.printInfo('Total patients: ${nurse.patientCount}');
    } catch (e) {
      UIHelper.printError('Failed to assign nurse to patient: $e');
    }
  }

  void _displayNurseDetails(Nurse nurse) {
    UIHelper.printSubHeader('Nurse Information');
    print('Staff ID: ${nurse.staffID}');
    print('Name: ${nurse.name}');
    print('Date of Birth: ${nurse.dateOfBirth}');
    print('Address: ${nurse.address}');
    print('Phone: ${nurse.tel}');
    print('Hire Date: ${UIHelper.formatDate(nurse.hireDate)}');
    print('Salary: \$${nurse.salary.toStringAsFixed(2)}');
    final yearsOfService =
        DateTime.now().difference(nurse.hireDate).inDays ~/ 365;
    print('Years of Service: $yearsOfService');
    print('Assigned Patients: ${nurse.patientCount}');
    print('Assigned Rooms: ${nurse.roomCount}');

    if (nurse.assignedPatients.isNotEmpty) {
      print('\nPatients:');
      for (final patient in nurse.assignedPatients) {
        print('  - ${patient.name} (${patient.patientID})');
      }
    }

    if (nurse.assignedRooms.isNotEmpty) {
      print('\nRooms:');
      for (final room in nurse.assignedRooms) {
        print(
            '  - ${room.number} (${room.roomType.toString().split('.').last})');
      }
    }
  }
}
