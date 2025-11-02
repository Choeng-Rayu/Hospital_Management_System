import 'package:hospital_management/domain/entities/doctor.dart';
import 'package:hospital_management/domain/repositories/doctor_repository.dart';
import 'package:hospital_management/domain/repositories/patient_repository.dart';
import 'package:hospital_management/presentation/menus/base_menu.dart';
import 'package:hospital_management/presentation/utils/input_validator.dart';
import 'package:hospital_management/presentation/utils/ui_helper.dart';

class DoctorMenu extends BaseMenu {
  final DoctorRepository _doctorRepository;
  final PatientRepository _patientRepository;

  DoctorMenu({
    required DoctorRepository doctorRepository,
    required PatientRepository patientRepository,
  })  : _doctorRepository = doctorRepository,
        _patientRepository = patientRepository;

  @override
  String get menuTitle => 'DOCTOR MANAGEMENT';

  @override
  List<String> get menuOptions => [
        'View All Doctors',
        'Search Doctor by Name',
        'Search Doctor by ID',
        'View Doctor Details',
        'View Doctor Schedule',
        'View Doctor Patients',
        'View Doctors by Specialization',
        'View Available Doctors',
        'Get Available Time Slots',
      ];

  @override
  Future<void> handleChoice(int choice) async {
    switch (choice) {
      case 1:
        await _viewAllDoctors();
        break;
      case 2:
        await _searchDoctorByName();
        break;
      case 3:
        await _searchDoctorById();
        break;
      case 4:
        await _viewDoctorDetails();
        break;
      case 5:
        await _viewDoctorSchedule();
        break;
      case 6:
        await _viewDoctorPatients();
        break;
      case 7:
        await _viewDoctorsBySpecialization();
        break;
      case 8:
        await _viewAvailableDoctors();
        break;
      case 9:
        await _getAvailableTimeSlots();
        break;
    }
  }

  Future<void> _viewAllDoctors() async {
    UIHelper.printHeader('All Doctors');

    final doctors = await _doctorRepository.getAllDoctors();
    if (doctors.isEmpty) {
      UIHelper.printWarning('No doctors found');
      return;
    }

    final tableData = doctors
        .map((doctor) => [
              doctor.staffID,
              doctor.name,
              doctor.specialization,
              doctor.tel,
              doctor.patientCount.toString(),
            ])
        .toList();

    UIHelper.printTable(
      tableData,
      headers: ['ID', 'Name', 'Specialization', 'Phone', 'Patients'],
    );
  }

  Future<void> _searchDoctorByName() async {
    UIHelper.printHeader('Search Doctor by Name');

    final name = InputValidator.readString('Enter doctor name (partial match)');
    final doctors = await _doctorRepository.searchDoctorsByName(name);

    if (doctors.isEmpty) {
      UIHelper.printWarning('No doctors found with name containing "$name"');
      return;
    }

    final tableData = doctors
        .map((doctor) => [
              doctor.staffID,
              doctor.name,
              doctor.specialization,
              doctor.certifications.join(', '),
            ])
        .toList();

    UIHelper.printTable(
      tableData,
      headers: ['ID', 'Name', 'Specialization', 'Certifications'],
    );
  }

  Future<void> _searchDoctorById() async {
    UIHelper.printHeader('Search Doctor by ID');

    final doctorId = InputValidator.readId('Enter doctor ID', 'D');
    final doctor = await _doctorRepository.getDoctorById(doctorId);

    _displayDoctorDetails(doctor);
  }

  Future<void> _viewDoctorDetails() async {
    UIHelper.printHeader('View Doctor Details');

    final doctorId = InputValidator.readId('Enter doctor ID', 'D');
    final doctor = await _doctorRepository.getDoctorById(doctorId);

    _displayDoctorDetails(doctor);
  }

  Future<void> _viewDoctorSchedule() async {
    UIHelper.printHeader('View Doctor Schedule');

    final doctorId = InputValidator.readId('Enter doctor ID', 'D');
    final date = InputValidator.readDate('Enter date');

    final schedule = await _doctorRepository.getDoctorScheduleForDate(doctorId, date);

    if (schedule.isEmpty) {
      UIHelper.printWarning('No schedule found for this date');
      return;
    }

    UIHelper.printSubHeader('Schedule for ${UIHelper.formatDate(date)}');
    for (final meeting in schedule) {
      print('• ${UIHelper.formatDateTime(meeting)}');
    }
  }

  Future<void> _viewDoctorPatients() async {
    UIHelper.printHeader('View Doctor Patients');

    final doctorId = InputValidator.readId('Enter doctor ID', 'D');
    final patients = await _doctorRepository.getDoctorPatients(doctorId);

    if (patients.isEmpty) {
      UIHelper.printWarning('No patients found for this doctor');
      return;
    }

    final tableData = patients
        .map((patient) => [
              patient.patientID,
              patient.name,
              patient.bloodType,
              patient.tel,
            ])
        .toList();

    UIHelper.printTable(
      tableData,
      headers: ['ID', 'Name', 'Blood Type', 'Phone'],
    );
  }

  Future<void> _viewDoctorsBySpecialization() async {
    UIHelper.printHeader('View Doctors by Specialization');

    final specialization = InputValidator.readString('Enter specialization');
    final doctors = await _doctorRepository.getDoctorsBySpecialization(specialization);

    if (doctors.isEmpty) {
      UIHelper.printWarning('No doctors found with specialization: $specialization');
      return;
    }

    final tableData = doctors
        .map((doctor) => [
              doctor.staffID,
              doctor.name,
              doctor.tel,
              doctor.patientCount.toString(),
            ])
        .toList();

    UIHelper.printTable(
      tableData,
      headers: ['ID', 'Name', 'Phone', 'Patients'],
    );
  }

  Future<void> _viewAvailableDoctors() async {
    UIHelper.printHeader('View Available Doctors');

    final date = InputValidator.readDate('Enter date');
    final doctors = await _doctorRepository.getAvailableDoctors(date);

    if (doctors.isEmpty) {
      UIHelper.printWarning('No doctors available on this date');
      return;
    }

    final tableData = doctors
        .map((doctor) => [
              doctor.staffID,
              doctor.name,
              doctor.specialization,
            ])
        .toList();

    UIHelper.printTable(
      tableData,
      headers: ['ID', 'Name', 'Specialization'],
    );
  }

  Future<void> _getAvailableTimeSlots() async {
    UIHelper.printHeader('Get Available Time Slots');

    final doctorId = InputValidator.readId('Enter doctor ID', 'D');
    final date = InputValidator.readDate('Enter date');
    
    final duration = InputValidator.readInt('Enter duration in minutes', min: 15, max: 240);

    final slots = await _doctorRepository.getAvailableTimeSlots(
      doctorId,
      date,
      durationMinutes: duration,
    );

    if (slots.isEmpty) {
      UIHelper.printWarning('No available time slots for this date');
      return;
    }

    UIHelper.printSubHeader('Available Time Slots');
    for (final slot in slots) {
      print('• ${UIHelper.formatDateTime(slot)}');
    }
  }

  void _displayDoctorDetails(Doctor doctor) {
    UIHelper.printSubHeader('Doctor Information');
    print('ID: ${doctor.staffID}');
    print('Name: ${doctor.name}');
    print('Specialization: ${doctor.specialization}');
    print('Phone: ${doctor.tel}');
    print('Address: ${doctor.address}');
    print('Date of Birth: ${UIHelper.formatDate(DateTime.parse(doctor.dateOfBirth))}');
    print('Hire Date: ${UIHelper.formatDate(doctor.hireDate)}');
    print('Salary: \$${doctor.salary.toStringAsFixed(2)}');
    print('Current Patients: ${doctor.patientCount}');

    if (doctor.certifications.isNotEmpty) {
      UIHelper.printSubHeader('Certifications');
      for (final cert in doctor.certifications) {
        print('• $cert');
      }
    }

    if (doctor.workingHours.isNotEmpty) {
      UIHelper.printSubHeader('Working Hours');
      final entries = doctor.workingHours.entries.take(5);
      for (final entry in entries) {
        final start = entry.value['start'];
        final end = entry.value['end'];
        print('${entry.key}: $start - $end');
      }
      if (doctor.workingHours.length > 5) {
        print('... and ${doctor.workingHours.length - 5} more entries');
      }
    }
  }
}
