import 'package:hospital_management/domain/repositories/prescription_repository.dart';
import 'package:hospital_management/domain/repositories/doctor_repository.dart';
import 'package:hospital_management/domain/repositories/patient_repository.dart';
import 'package:hospital_management/domain/entities/prescription.dart';
import 'package:hospital_management/domain/entities/medication.dart';
import 'package:hospital_management/presentation/menus/base_menu.dart';
import 'package:hospital_management/presentation/utils/ui_helper.dart';
import 'package:hospital_management/presentation/utils/input_validator.dart';

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
    UIHelper.printHeader('Create New Prescription');

    try {
      // Get patient
      final patientId = InputValidator.readId('Enter patient ID', 'P');
      final patient = await patientRepository.getPatientById(patientId);

      // Get doctor
      final doctorId = InputValidator.readId('Enter doctor ID', 'D');
      final doctor = await doctorRepository.getDoctorById(doctorId);

      // Generate prescription ID
      final allPrescriptions =
          await prescriptionRepository.getAllPrescriptions();
      final prescriptionId =
          'RX${(allPrescriptions.length + 1).toString().padLeft(3, '0')}';

      // Get instructions
      final instructions =
          InputValidator.readString('Enter prescription instructions');

      // Add medications
      final medications = <Medication>[];
      var addMore = true;

      while (addMore) {
        UIHelper.printSubHeader('Add Medication ${medications.length + 1}');

        final medId = InputValidator.readId('Enter medication ID', 'M');
        final medName = InputValidator.readString('Enter medication name');
        final dosage =
            InputValidator.readString('Enter dosage (e.g., 500mg twice daily)');
        final manufacturer = InputValidator.readString('Enter manufacturer');

        // Get side effects
        final sideEffects = <String>[];
        var addSideEffect = InputValidator.readBoolean('Add side effects?');

        while (addSideEffect) {
          final sideEffect = InputValidator.readString('Enter side effect');
          sideEffects.add(sideEffect);
          addSideEffect =
              InputValidator.readBoolean('Add another side effect?');
        }

        final medication = Medication(
          id: medId,
          name: medName,
          dosage: dosage,
          manufacturer: manufacturer,
          sideEffects: sideEffects,
        );

        medications.add(medication);

        addMore = InputValidator.readBoolean('Add another medication?');
      }

      // Create prescription
      final prescription = Prescription(
        id: prescriptionId,
        time: DateTime.now(),
        medications: medications,
        instructions: instructions,
        prescribedBy: doctor,
        prescribedTo: patient,
      );

      await prescriptionRepository.savePrescription(prescription);

      UIHelper.printSuccess('Prescription created successfully!');
      UIHelper.printInfo('Prescription ID: $prescriptionId');
      UIHelper.printInfo('Patient: ${patient.name}');
      UIHelper.printInfo('Doctor: ${doctor.name}');
      UIHelper.printInfo('Medications: ${medications.length}');
    } catch (e) {
      UIHelper.printError('Failed to create prescription: $e');
    }
  }

  Future<void> _viewAllPrescriptions() async {
    UIHelper.printHeader('All Prescriptions');

    try {
      final prescriptions = await prescriptionRepository.getAllPrescriptions();

      if (prescriptions.isEmpty) {
        UIHelper.printWarning('No prescriptions found');
        return;
      }

      final tableData = prescriptions
          .map((rx) => [
                rx.id,
                rx.prescribedTo.name,
                rx.prescribedBy.name,
                rx.formattedDate,
                rx.medicationCount.toString(),
                rx.isRecent ? 'Recent' : 'Old',
              ])
          .toList();

      UIHelper.printTable(
        tableData,
        headers: ['ID', 'Patient', 'Doctor', 'Date', 'Medications', 'Status'],
      );

      UIHelper.printInfo('Total prescriptions: ${prescriptions.length}');
    } catch (e) {
      UIHelper.printError('Failed to retrieve prescriptions: $e');
    }
  }

  Future<void> _viewPrescriptionDetails() async {
    UIHelper.printHeader('Prescription Details');

    try {
      final prescriptionId = InputValidator.readString('Enter prescription ID');
      final prescription =
          await prescriptionRepository.getPrescriptionById(prescriptionId);

      _displayPrescriptionDetails(prescription);
    } catch (e) {
      UIHelper.printError('Failed to retrieve prescription details: $e');
    }
  }

  Future<void> _refillPrescription() async {
    UIHelper.printHeader('Refill Prescription');

    try {
      final prescriptionId = InputValidator.readString('Enter prescription ID');
      final prescription =
          await prescriptionRepository.getPrescriptionById(prescriptionId);

      _displayPrescriptionDetails(prescription);

      final confirm = InputValidator.readBoolean(
        'Create a refill for this prescription?',
      );

      if (!confirm) {
        UIHelper.printInfo('Refill cancelled');
        return;
      }

      // Generate new prescription ID
      final allPrescriptions =
          await prescriptionRepository.getAllPrescriptions();
      final newPrescriptionId =
          'RX${(allPrescriptions.length + 1).toString().padLeft(3, '0')}';

      // Create refill prescription with same details
      final refill = Prescription(
        id: newPrescriptionId,
        time: DateTime.now(),
        medications: prescription.medications.toList(),
        instructions: prescription.instructions,
        prescribedBy: prescription.prescribedBy,
        prescribedTo: prescription.prescribedTo,
      );

      await prescriptionRepository.savePrescription(refill);

      UIHelper.printSuccess('Prescription refilled successfully!');
      UIHelper.printInfo('New Prescription ID: $newPrescriptionId');
      UIHelper.printInfo('Original Prescription: $prescriptionId');
    } catch (e) {
      UIHelper.printError('Failed to refill prescription: $e');
    }
  }

  Future<void> _viewPatientPrescriptions() async {
    UIHelper.printHeader('Patient Prescriptions');

    try {
      final patientId = InputValidator.readId('Enter patient ID', 'P');
      final patient = await patientRepository.getPatientById(patientId);

      UIHelper.printInfo('Patient: ${patient.name}');

      final prescriptions =
          await prescriptionRepository.getPrescriptionsByPatient(patientId);

      if (prescriptions.isEmpty) {
        UIHelper.printWarning('No prescriptions found for this patient');
        return;
      }

      final tableData = prescriptions
          .map((rx) => [
                rx.id,
                rx.prescribedBy.name,
                rx.formattedDate,
                rx.medicationCount.toString(),
                rx.isRecent ? 'Recent' : 'Old',
              ])
          .toList();

      UIHelper.printTable(
        tableData,
        headers: ['ID', 'Doctor', 'Date', 'Medications', 'Status'],
      );

      UIHelper.printInfo('Total prescriptions: ${prescriptions.length}');
    } catch (e) {
      UIHelper.printError('Failed to retrieve patient prescriptions: $e');
    }
  }

  Future<void> _viewDoctorPrescriptions() async {
    UIHelper.printHeader('Doctor Prescriptions');

    try {
      final doctorId = InputValidator.readId('Enter doctor ID', 'D');
      final doctor = await doctorRepository.getDoctorById(doctorId);

      UIHelper.printInfo('Doctor: ${doctor.name} (${doctor.specialization})');

      final prescriptions =
          await prescriptionRepository.getPrescriptionsByDoctor(doctorId);

      if (prescriptions.isEmpty) {
        UIHelper.printWarning('No prescriptions found for this doctor');
        return;
      }

      final tableData = prescriptions
          .map((rx) => [
                rx.id,
                rx.prescribedTo.name,
                rx.formattedDate,
                rx.medicationCount.toString(),
                rx.isRecent ? 'Recent' : 'Old',
              ])
          .toList();

      UIHelper.printTable(
        tableData,
        headers: ['ID', 'Patient', 'Date', 'Medications', 'Status'],
      );

      UIHelper.printInfo('Total prescriptions: ${prescriptions.length}');
    } catch (e) {
      UIHelper.printError('Failed to retrieve doctor prescriptions: $e');
    }
  }

  Future<void> _checkDrugInteractions() async {
    UIHelper.printHeader('Check Drug Interactions');

    try {
      final prescriptionId = InputValidator.readString('Enter prescription ID');
      final prescription =
          await prescriptionRepository.getPrescriptionById(prescriptionId);

      _displayPrescriptionDetails(prescription);

      // Check for common side effects across medications
      UIHelper.printSubHeader('Potential Drug Interactions Analysis');

      final allSideEffects = <String, List<String>>{};

      for (final med in prescription.medications) {
        for (final sideEffect in med.sideEffects) {
          if (!allSideEffects.containsKey(sideEffect)) {
            allSideEffects[sideEffect] = [];
          }
          allSideEffects[sideEffect]!.add(med.name);
        }
      }

      // Find common side effects (potential interactions)
      final commonSideEffects = allSideEffects.entries
          .where((entry) => entry.value.length > 1)
          .toList();

      if (commonSideEffects.isEmpty) {
        UIHelper.printSuccess(
            'No common side effects found across medications');
      } else {
        UIHelper.printWarning('Common side effects detected:');
        for (final entry in commonSideEffects) {
          print('\n⚠ ${entry.key}');
          print('   Medications: ${entry.value.join(', ')}');
        }
        UIHelper.printInfo(
            '\nPlease consult with a pharmacist for detailed interaction analysis.');
      }
    } catch (e) {
      UIHelper.printError('Failed to check drug interactions: $e');
    }
  }

  void _displayPrescriptionDetails(Prescription prescription) {
    UIHelper.printSubHeader('Prescription Information');
    print('ID: ${prescription.id}');
    print('Date: ${prescription.formattedDate}');
    print(
        'Patient: ${prescription.prescribedTo.name} (${prescription.prescribedTo.patientID})');
    print(
        'Doctor: ${prescription.prescribedBy.name} (${prescription.prescribedBy.specialization})');
    print('Instructions: ${prescription.instructions}');
    print('Status: ${prescription.isRecent ? "Recent" : "Old"}');
    print('\nMedications (${prescription.medicationCount}):');

    var index = 1;
    for (final med in prescription.medications) {
      print('\n$index. ${med.name}');
      print('   ID: ${med.id}');
      print('   Dosage: ${med.dosage}');
      print('   Manufacturer: ${med.manufacturer}');
      if (med.sideEffects.isNotEmpty) {
        print('   Side Effects: ${med.sideEffects.join(', ')}');
      }
      index++;
    }
  }
}
