import 'package:hospital_management/domain/repositories/patient_repository.dart';
import 'package:hospital_management/domain/repositories/doctor_repository.dart';
import 'package:hospital_management/domain/repositories/room_repository.dart';
import 'package:hospital_management/domain/repositories/nurse_repository.dart';
import 'package:hospital_management/domain/entities/patient.dart';
import 'package:hospital_management/domain/entities/enums/room_type.dart';
import 'package:hospital_management/domain/entities/enums/room_status.dart';
import 'package:hospital_management/presentation/menus/base_menu.dart';
import 'package:hospital_management/presentation/utils/ui_helper.dart';
import 'package:hospital_management/presentation/utils/input_validator.dart';

class EmergencyMenu extends BaseMenu {
  final PatientRepository patientRepository;
  final RoomRepository roomRepository;
  final DoctorRepository doctorRepository;
  final NurseRepository nurseRepository;

  EmergencyMenu({
    required this.patientRepository,
    required this.roomRepository,
    required this.doctorRepository,
    required this.nurseRepository,
  });

  @override
  String get menuTitle => 'EMERGENCY OPERATIONS';

  @override
  List<String> get menuOptions => [
        'Register Emergency Patient',
        'Find Available Emergency Room',
        'Assign Emergency Doctor',
        'Emergency Bed Assignment',
        'View Emergency Status',
      ];

  @override
  Future<void> handleChoice(int choice) async {
    switch (choice) {
      case 1:
        await _registerEmergencyPatient();
        break;
      case 2:
        await _findEmergencyRoom();
        break;
      case 3:
        await _assignEmergencyDoctor();
        break;
      case 4:
        await _assignEmergencyBed();
        break;
      case 5:
        await _viewEmergencyStatus();
        break;
    }
  }

  Future<void> _registerEmergencyPatient() async {
    UIHelper.printHeader('Register Emergency Patient');

    try {
      // Generate patient ID
      final allPatients = await patientRepository.getAllPatients();
      final patientID = 'P${(allPatients.length + 1).toString().padLeft(3, '0')}';

      // Get patient information
      final name = InputValidator.readString('Enter patient name');
      final dob = InputValidator.readString('Enter date of birth (YYYY-MM-DD)');
      final address = InputValidator.readString('Enter address');
      final tel = InputValidator.readString('Enter telephone');
      final bloodType = InputValidator.readString('Enter blood type (e.g., A+, O-)');
      final emergencyContact = InputValidator.readString('Enter emergency contact');

      // Emergency specific information
      UIHelper.printWarning('EMERGENCY REGISTRATION');
      final emergencyReason = InputValidator.readString('Enter emergency reason/condition');

      final patient = Patient(
        name: name,
        dateOfBirth: dob,
        address: address,
        tel: tel,
        patientID: patientID,
        bloodType: bloodType,
        medicalRecords: ['EMERGENCY: $emergencyReason - ${DateTime.now()}'],
        allergies: [],
        emergencyContact: emergencyContact,
        assignedDoctors: [],
        assignedNurses: [],
        prescriptions: [],
      );

      await patientRepository.savePatient(patient);

      UIHelper.printSuccess('Emergency patient registered successfully!');
      UIHelper.printInfo('Patient ID: $patientID');
      UIHelper.printInfo('Name: $name');
      UIHelper.printInfo('Emergency: $emergencyReason');
      UIHelper.printWarning('Next: Assign emergency room and doctor!');
    } catch (e) {
      UIHelper.printError('Failed to register emergency patient: $e');
    }
  }

  Future<void> _findEmergencyRoom() async {
    UIHelper.printHeader('Find Available Emergency Room');

    try {
      // Get emergency rooms
      final emergencyRooms = await roomRepository.getRoomsByType(RoomType.EMERGENCY);

      if (emergencyRooms.isEmpty) {
        UIHelper.printError('No emergency rooms in the system');
        return;
      }

      // Filter for available emergency rooms
      final availableRooms = emergencyRooms
          .where((room) => 
              room.status == RoomStatus.AVAILABLE && 
              room.hasAvailableBeds)
          .toList();

      if (availableRooms.isEmpty) {
        UIHelper.printWarning('No available emergency rooms');
        UIHelper.printInfo('Showing all emergency rooms:');

        final allTableData = emergencyRooms
            .map((room) => [
                  room.roomId,
                  room.number,
                  room.status.toString().split('.').last,
                  room.beds.length.toString(),
                  room.availableBedCount.toString(),
                ])
            .toList();

        UIHelper.printTable(
          allTableData,
          headers: ['ID', 'Number', 'Status', 'Total Beds', 'Available'],
        );
        return;
      }

      final tableData = availableRooms
          .map((room) => [
                room.roomId,
                room.number,
                room.status.toString().split('.').last,
                room.beds.length.toString(),
                room.availableBedCount.toString(),
              ])
          .toList();

      UIHelper.printTable(
        tableData,
        headers: ['ID', 'Number', 'Status', 'Total Beds', 'Available'],
      );

      UIHelper.printSuccess('Found ${availableRooms.length} available emergency rooms');
    } catch (e) {
      UIHelper.printError('Failed to find emergency rooms: $e');
    }
  }

  Future<void> _assignEmergencyDoctor() async {
    UIHelper.printHeader('Assign Emergency Doctor');

    try {
      // Get patient
      final patientId = InputValidator.readId('Enter patient ID', 'P');
      final patient = await patientRepository.getPatientById(patientId);

      UIHelper.printInfo('Patient: ${patient.name}');

      // Get available doctors (preferably emergency/general specialists)
      final allDoctors = await doctorRepository.getAllDoctors();
      
      if (allDoctors.isEmpty) {
        UIHelper.printError('No doctors available');
        return;
      }

      // Show available doctors
      UIHelper.printSubHeader('Available Doctors');
      final tableData = allDoctors
          .map((doctor) => [
                doctor.staffID,
                doctor.name,
                doctor.specialization,
                doctor.tel,
              ])
          .toList();

      UIHelper.printTable(
        tableData,
        headers: ['ID', 'Name', 'Specialization', 'Phone'],
      );

      // Assign doctor
      final doctorId = InputValidator.readId('Enter doctor ID to assign', 'D');
      final doctor = await doctorRepository.getDoctorById(doctorId);

      patient.assignDoctor(doctor);
      await patientRepository.updatePatient(patient);

      UIHelper.printSuccess('Emergency doctor assigned successfully!');
      UIHelper.printInfo('Patient: ${patient.name}');
      UIHelper.printInfo('Doctor: ${doctor.name} (${doctor.specialization})');
    } catch (e) {
      UIHelper.printError('Failed to assign emergency doctor: $e');
    }
  }

  Future<void> _assignEmergencyBed() async {
    UIHelper.printHeader('Emergency Bed Assignment');

    try {
      // Get patient
      final patientId = InputValidator.readId('Enter patient ID', 'P');
      final patient = await patientRepository.getPatientById(patientId);

      UIHelper.printInfo('Patient: ${patient.name}');

      // Get available emergency rooms
      final emergencyRooms = await roomRepository.getRoomsByType(RoomType.EMERGENCY);
      final availableRooms = emergencyRooms
          .where((room) => room.hasAvailableBeds)
          .toList();

      if (availableRooms.isEmpty) {
        UIHelper.printError('No available emergency beds');
        return;
      }

      // Show available rooms
      UIHelper.printSubHeader('Available Emergency Rooms');
      for (var i = 0; i < availableRooms.length; i++) {
        final room = availableRooms[i];
        print('${i + 1}. Room ${room.number} - ${room.availableBedCount} beds available');
      }

      final roomChoice = InputValidator.readChoice(availableRooms.length);
      if (roomChoice == 0) return;

      final selectedRoom = availableRooms[roomChoice - 1];

      // Show available beds in selected room
      UIHelper.printSubHeader('Available Beds');
      final availableBeds = selectedRoom.getAvailableBeds();
      for (var i = 0; i < availableBeds.length; i++) {
        print('${i + 1}. ${availableBeds[i].bedNumber} (${availableBeds[i].bedType.toString().split('.').last})');
      }

      final bedChoice = InputValidator.readChoice(availableBeds.length);
      if (bedChoice == 0) return;

      final selectedBed = availableBeds[bedChoice - 1];

      // Assign bed
      selectedRoom.assignPatientToBed(patient, selectedBed.bedNumber);
      await roomRepository.updateRoom(selectedRoom);
      await patientRepository.updatePatient(patient);

      UIHelper.printSuccess('Emergency bed assigned successfully!');
      UIHelper.printInfo('Patient: ${patient.name}');
      UIHelper.printInfo('Room: ${selectedRoom.number}');
      UIHelper.printInfo('Bed: ${selectedBed.bedNumber}');
    } catch (e) {
      UIHelper.printError('Failed to assign emergency bed: $e');
    }
  }

  Future<void> _viewEmergencyStatus() async {
    UIHelper.printHeader('Emergency Status Overview');

    try {
      // Get emergency rooms
      final emergencyRooms = await roomRepository.getRoomsByType(RoomType.EMERGENCY);

      if (emergencyRooms.isEmpty) {
        UIHelper.printWarning('No emergency rooms in the system');
        return;
      }

      UIHelper.printSubHeader('Emergency Rooms Status');
      
      for (final room in emergencyRooms) {
        print('\nRoom ${room.number} (${room.roomId})');
        print('Status: ${room.status.toString().split('.').last}');
        print('Total Beds: ${room.beds.length}');
        print('Available Beds: ${room.availableBedCount}');
        print('Occupied Beds: ${room.beds.length - room.availableBedCount}');

        if (room.currentPatients.isNotEmpty) {
          print('Current Patients:');
          for (final patient in room.currentPatients) {
            print('  - ${patient.name} (${patient.patientID})');
            if (patient.medicalRecords.isNotEmpty) {
              print('    Condition: ${patient.medicalRecords.last}');
            }
          }
        }
        print('---');
      }

      // Summary
      final totalBeds = emergencyRooms.fold<int>(0, (sum, room) => sum + room.beds.length);
      final availableBeds = emergencyRooms.fold<int>(0, (sum, room) => sum + room.availableBedCount);
      final totalPatients = emergencyRooms.fold<int>(0, (sum, room) => sum + room.currentPatients.length);

      UIHelper.printSubHeader('Summary');
      print('Total Emergency Rooms: ${emergencyRooms.length}');
      print('Total Beds: $totalBeds');
      print('Available Beds: $availableBeds');
      print('Occupied Beds: ${totalBeds - availableBeds}');
      print('Total Emergency Patients: $totalPatients');
      
      final occupancyRate = totalBeds > 0 ? ((totalBeds - availableBeds) / totalBeds * 100) : 0;
      print('Occupancy Rate: ${occupancyRate.toStringAsFixed(1)}%');

      if (availableBeds == 0) {
        UIHelper.printWarning('⚠ CRITICAL: No emergency beds available!');
      } else if (availableBeds <= 2) {
        UIHelper.printWarning('⚠ WARNING: Low emergency bed availability!');
      } else {
        UIHelper.printSuccess('✓ Emergency capacity available');
      }
    } catch (e) {
      UIHelper.printError('Failed to view emergency status: $e');
    }
  }
}
