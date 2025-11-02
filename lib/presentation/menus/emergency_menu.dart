import 'package:hospital_management/domain/repositories/patient_repository.dart';
import 'package:hospital_management/domain/repositories/doctor_repository.dart';
import 'package:hospital_management/domain/repositories/room_repository.dart';
import 'package:hospital_management/domain/repositories/nurse_repository.dart';
import 'package:hospital_management/presentation/menus/base_menu.dart';
import 'package:hospital_management/presentation/utils/ui_helper.dart';

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
    UIHelper.printInfo('Register Emergency Patient - Coming Soon');
  }

  Future<void> _findEmergencyRoom() async {
    UIHelper.printInfo('Find Available Emergency Room - Coming Soon');
  }

  Future<void> _assignEmergencyDoctor() async {
    UIHelper.printInfo('Assign Emergency Doctor - Coming Soon');
  }

  Future<void> _assignEmergencyBed() async {
    UIHelper.printInfo('Emergency Bed Assignment - Coming Soon');
  }

  Future<void> _viewEmergencyStatus() async {
    UIHelper.printInfo('View Emergency Status - Coming Soon');
  }
}
