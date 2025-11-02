import 'package:hospital_management/domain/repositories/nurse_repository.dart';
import 'package:hospital_management/domain/repositories/patient_repository.dart';
import 'package:hospital_management/presentation/menus/base_menu.dart';
import 'package:hospital_management/presentation/utils/ui_helper.dart';

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
    UIHelper.printInfo('Add New Nurse - Coming Soon');
  }

  Future<void> _viewAllNurses() async {
    UIHelper.printInfo('View All Nurses - Coming Soon');
  }

  Future<void> _searchNurse() async {
    UIHelper.printInfo('Search Nurse - Coming Soon');
  }

  Future<void> _viewNurseDetails() async {
    UIHelper.printInfo('View Nurse Details - Coming Soon');
  }

  Future<void> _updateNurse() async {
    UIHelper.printInfo('Update Nurse - Coming Soon');
  }

  Future<void> _deleteNurse() async {
    UIHelper.printInfo('Delete Nurse - Coming Soon');
  }

  Future<void> _viewNurseSchedule() async {
    UIHelper.printInfo('View Nurse Schedule - Coming Soon');
  }

  Future<void> _assignNurseToPatient() async {
    UIHelper.printInfo('Assign Nurse to Patient - Coming Soon');
  }
}
