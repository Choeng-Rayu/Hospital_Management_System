import 'package:hospital_management/domain/repositories/doctor_repository.dart';
import 'package:hospital_management/domain/repositories/patient_repository.dart';
import 'package:hospital_management/presentation/menus/base_menu.dart';
import 'package:hospital_management/presentation/utils/ui_helper.dart';

class DoctorMenu extends BaseMenu {
  final DoctorRepository doctorRepository;
  final PatientRepository patientRepository;

  DoctorMenu({
    required this.doctorRepository,
    required this.patientRepository,
  });

  @override
  String get menuTitle => 'DOCTOR MANAGEMENT';

  @override
  List<String> get menuOptions => [
        'Add New Doctor',
        'View All Doctors',
        'Search Doctor',
        'View Doctor Details',
        'Update Doctor',
        'Delete Doctor',
        'View Doctor Schedule',
        'View Doctor Patients',
      ];

  @override
  Future<void> handleChoice(int choice) async {
    switch (choice) {
      case 1:
        await _addDoctor();
        break;
      case 2:
        await _viewAllDoctors();
        break;
      case 3:
        await _searchDoctor();
        break;
      case 4:
        await _viewDoctorDetails();
        break;
      case 5:
        await _updateDoctor();
        break;
      case 6:
        await _deleteDoctor();
        break;
      case 7:
        await _viewDoctorSchedule();
        break;
      case 8:
        await _viewDoctorPatients();
        break;
    }
  }

  Future<void> _addDoctor() async {
    UIHelper.printInfo('Add New Doctor - Coming Soon');
  }

  Future<void> _viewAllDoctors() async {
    UIHelper.printInfo('View All Doctors - Coming Soon');
  }

  Future<void> _searchDoctor() async {
    UIHelper.printInfo('Search Doctor - Coming Soon');
  }

  Future<void> _viewDoctorDetails() async {
    UIHelper.printInfo('View Doctor Details - Coming Soon');
  }

  Future<void> _updateDoctor() async {
    UIHelper.printInfo('Update Doctor - Coming Soon');
  }

  Future<void> _deleteDoctor() async {
    UIHelper.printInfo('Delete Doctor - Coming Soon');
  }

  Future<void> _viewDoctorSchedule() async {
    UIHelper.printInfo('View Doctor Schedule - Coming Soon');
  }

  Future<void> _viewDoctorPatients() async {
    UIHelper.printInfo('View Doctor Patients - Coming Soon');
  }
}
