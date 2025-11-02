import 'package:hospital_management/domain/repositories/patient_repository.dart';
import 'package:hospital_management/domain/repositories/doctor_repository.dart';
import 'package:hospital_management/domain/repositories/room_repository.dart';
import 'package:hospital_management/domain/repositories/nurse_repository.dart';
import 'package:hospital_management/domain/repositories/prescription_repository.dart';
import 'package:hospital_management/domain/repositories/appointment_repository.dart';
import 'package:hospital_management/presentation/menus/base_menu.dart';
import 'package:hospital_management/presentation/utils/ui_helper.dart';
import 'package:hospital_management/presentation/utils/input_validator.dart';

class SearchMenu extends BaseMenu {
  final PatientRepository patientRepository;
  final DoctorRepository doctorRepository;
  final RoomRepository roomRepository;
  final NurseRepository nurseRepository;
  final PrescriptionRepository prescriptionRepository;
  final AppointmentRepository appointmentRepository;

  SearchMenu({
    required this.patientRepository,
    required this.doctorRepository,
    required this.roomRepository,
    required this.nurseRepository,
    required this.prescriptionRepository,
    required this.appointmentRepository,
  });

  @override
  String get menuTitle => 'SEARCH OPERATIONS';

  @override
  List<String> get menuOptions => [
        'Search Patients',
        'Search Doctors',
        'Search Appointments',
        'Search Prescriptions',
        'Search Rooms',
        'Search Nurses',
      ];

  @override
  Future<void> handleChoice(int choice) async {
    switch (choice) {
      case 1:
        await _searchPatients();
        break;
      case 2:
        await _searchDoctors();
        break;
      case 3:
        await _searchAppointments();
        break;
      case 4:
        await _searchPrescriptions();
        break;
      case 5:
        await _searchRooms();
        break;
      case 6:
        await _searchNurses();
        break;
    }
  }

  Future<void> _searchPatients() async {
    UIHelper.printHeader('Search Patients');

    try {
      final name = InputValidator.readString('Enter patient name to search');
      final patients = await patientRepository.searchPatientsByName(name);

      if (patients.isEmpty) {
        UIHelper.printWarning('No patients found matching "$name"');
        return;
      }

      final tableData = patients
          .map((patient) => [
                patient.patientID,
                patient.name,
                patient.tel,
                patient.medicalRecords.isNotEmpty ? patient.medicalRecords.last : 'N/A',
                patient.currentRoom != null ? 'Admitted' : 'Not Admitted',
              ])
          .toList();

      UIHelper.printTable(
        tableData,
        headers: ['ID', 'Name', 'Phone', 'Diagnosis', 'Status'],
      );

      UIHelper.printInfo('Found ${patients.length} patients');
    } catch (e) {
      UIHelper.printError('Failed to search patients: $e');
    }
  }

  Future<void> _searchDoctors() async {
    UIHelper.printHeader('Search Doctors');

    try {
      final name = InputValidator.readString('Enter doctor name to search');
      final doctors = await doctorRepository.searchDoctorsByName(name);

      if (doctors.isEmpty) {
        UIHelper.printWarning('No doctors found matching "$name"');
        return;
      }

      final tableData = doctors
          .map((doctor) => [
                doctor.staffID,
                doctor.name,
                doctor.specialization,
                doctor.tel,
                doctor.schedule.isNotEmpty ? 'Has Schedule' : 'No Schedule',
              ])
          .toList();

      UIHelper.printTable(
        tableData,
        headers: ['ID', 'Name', 'Specialization', 'Phone', 'Availability'],
      );

      UIHelper.printInfo('Found ${doctors.length} doctors');
    } catch (e) {
      UIHelper.printError('Failed to search doctors: $e');
    }
  }

  Future<void> _searchAppointments() async {
    UIHelper.printHeader('Search Appointments');

    try {
      UIHelper.printSubHeader('Search By:');
      print('1. Patient ID');
      print('2. Doctor ID');
      print('3. Date');

      final searchChoice = InputValidator.readChoice(3);
      if (searchChoice == 0) return;

      List appointments = [];

      switch (searchChoice) {
        case 1:
          final patientId = InputValidator.readId('Enter patient ID', 'P');
          appointments = await appointmentRepository.getAppointmentsByPatient(patientId);
          break;
        case 2:
          final doctorId = InputValidator.readId('Enter doctor ID', 'D');
          appointments = await appointmentRepository.getAppointmentsByDoctor(doctorId);
          break;
        case 3:
          final date = InputValidator.readDate('Enter date');
          appointments = await appointmentRepository.getAppointmentsByDate(date);
          break;
      }

      if (appointments.isEmpty) {
        UIHelper.printWarning('No appointments found');
        return;
      }

      final tableData = appointments
          .map((apt) => <String>[
                apt.id,
                apt.patient.name,
                apt.doctor.name,
                UIHelper.formatDateTime(apt.dateTime),
                apt.status.toString().split('.').last,
              ])
          .toList();

      UIHelper.printTable(
        tableData,
        headers: ['ID', 'Patient', 'Doctor', 'Date/Time', 'Status'],
      );

      UIHelper.printInfo('Found ${appointments.length} appointments');
    } catch (e) {
      UIHelper.printError('Failed to search appointments: $e');
    }
  }

  Future<void> _searchPrescriptions() async {
    UIHelper.printHeader('Search Prescriptions');

    try {
      UIHelper.printSubHeader('Search By:');
      print('1. Patient ID');
      print('2. Doctor ID');

      final searchChoice = InputValidator.readChoice(2);
      if (searchChoice == 0) return;

      List prescriptions = [];

      switch (searchChoice) {
        case 1:
          final patientId = InputValidator.readId('Enter patient ID', 'P');
          prescriptions = await prescriptionRepository.getPrescriptionsByPatient(patientId);
          break;
        case 2:
          final doctorId = InputValidator.readId('Enter doctor ID', 'D');
          prescriptions = await prescriptionRepository.getPrescriptionsByDoctor(doctorId);
          break;
      }

      if (prescriptions.isEmpty) {
        UIHelper.printWarning('No prescriptions found');
        return;
      }

      final tableData = prescriptions
          .map((rx) => <String>[
                rx.id,
                rx.prescribedTo.name,
                rx.prescribedBy.name,
                rx.formattedDate,
                rx.medicationCount.toString(),
              ])
          .toList();

      UIHelper.printTable(
        tableData,
        headers: ['ID', 'Patient', 'Doctor', 'Date', 'Medications'],
      );

      UIHelper.printInfo('Found ${prescriptions.length} prescriptions');
    } catch (e) {
      UIHelper.printError('Failed to search prescriptions: $e');
    }
  }

  Future<void> _searchRooms() async {
    UIHelper.printHeader('Search Rooms');

    try {
      final roomNumber = InputValidator.readString('Enter room number to search');
      
      try {
        final room = await roomRepository.getRoomByNumber(roomNumber);
        
        UIHelper.printSubHeader('Room Information');
        print('ID: ${room.roomId}');
        print('Number: ${room.number}');
        print('Type: ${room.roomType.toString().split('.').last}');
        print('Status: ${room.status.toString().split('.').last}');
        print('Total Beds: ${room.beds.length}');
        print('Available Beds: ${room.availableBedCount}');
        
        if (room.currentPatients.isNotEmpty) {
          print('\nCurrent Patients:');
          for (final patient in room.currentPatients) {
            print('  - ${patient.name} (${patient.patientID})');
          }
        }
      } catch (e) {
        UIHelper.printWarning('Room not found');
      }
    } catch (e) {
      UIHelper.printError('Failed to search rooms: $e');
    }
  }

  Future<void> _searchNurses() async {
    UIHelper.printHeader('Search Nurses');

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
}
