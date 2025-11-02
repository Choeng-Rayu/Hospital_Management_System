import 'package:hospital_management/domain/repositories/prescription_repository.dart';
import 'package:hospital_management/domain/repositories/doctor_repository.dart';
import 'package:hospital_management/domain/repositories/patient_repository.dart';
import 'package:hospital_management/presentation/menus/base_menu.dart';
import 'package:hospital_management/presentation/utils/ui_helper.dart';

class PrescriptionMenu extends BaseMenu {
  final PrescriptionRepository prescriptionRepository;
  final PatientRepository patientRepository;
  final DoctorRepository doctorRepository;

  PrescriptionMenu({
    required this.prescriptionRepository,
    required this.patientRepository,
    required this.doctorRepository,
  });

  @override
  String get menuTitle => 'PRESCRIPTION MANAGEMENT';

  @override
  List<String> get menuOptions => [
        'Create New Prescription',
        'View All Prescriptions',
        'View Prescription Details',
        'Refill Prescription',
        'View Patient Prescriptions',
        'View Doctor Prescriptions',
        'Check Drug Interactions',
      ];

  @override
  Future<void> handleChoice(int choice) async {
    switch (choice) {
      case 1:
        await _createPrescription();
        break;
      case 2:
        await _viewAllPrescriptions();
        break;
      case 3:
        await _viewPrescriptionDetails();
        break;
      case 4:
        await _refillPrescription();
        break;
      case 5:
        await _viewPatientPrescriptions();
        break;
      case 6:
        await _viewDoctorPrescriptions();
        break;
      case 7:
        await _checkDrugInteractions();
        break;
    }
  }

  Future<void> _createPrescription() async {
    UIHelper.printInfo('Create New Prescription - Coming Soon');
  }

  Future<void> _viewAllPrescriptions() async {
    UIHelper.printInfo('View All Prescriptions - Coming Soon');
  }

  Future<void> _viewPrescriptionDetails() async {
    UIHelper.printInfo('View Prescription Details - Coming Soon');
  }

  Future<void> _refillPrescription() async {
    UIHelper.printInfo('Refill Prescription - Coming Soon');
  }

  Future<void> _viewPatientPrescriptions() async {
    UIHelper.printInfo('View Patient Prescriptions - Coming Soon');
  }

  Future<void> _viewDoctorPrescriptions() async {
    UIHelper.printInfo('View Doctor Prescriptions - Coming Soon');
  }

  Future<void> _checkDrugInteractions() async {
    UIHelper.printInfo('Check Drug Interactions - Coming Soon');
  }
}
