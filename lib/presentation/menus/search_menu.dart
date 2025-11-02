import 'package:hospital_management/domain/repositories/patient_repository.dart';
import 'package:hospital_management/domain/repositories/doctor_repository.dart';
import 'package:hospital_management/domain/repositories/room_repository.dart';
import 'package:hospital_management/domain/repositories/nurse_repository.dart';
import 'package:hospital_management/domain/repositories/prescription_repository.dart';
import 'package:hospital_management/domain/repositories/appointment_repository.dart';
import 'package:hospital_management/presentation/menus/base_menu.dart';
import 'package:hospital_management/presentation/utils/ui_helper.dart';

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
    UIHelper.printInfo('Search Patients - Coming Soon');
  }

  Future<void> _searchDoctors() async {
    UIHelper.printInfo('Search Doctors - Coming Soon');
  }

  Future<void> _searchAppointments() async {
    UIHelper.printInfo('Search Appointments - Coming Soon');
  }

  Future<void> _searchPrescriptions() async {
    UIHelper.printInfo('Search Prescriptions - Coming Soon');
  }

  Future<void> _searchRooms() async {
    UIHelper.printInfo('Search Rooms - Coming Soon');
  }

  Future<void> _searchNurses() async {
    UIHelper.printInfo('Search Nurses - Coming Soon');
  }
}
