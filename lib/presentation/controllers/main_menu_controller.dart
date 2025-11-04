/// Main menu controller for the hospital management system
import 'package:hospital_management/data/repositories/patient_repository_impl.dart';
import 'package:hospital_management/data/repositories/doctor_repository_impl.dart';
import 'package:hospital_management/data/repositories/room_repository_impl.dart';
import 'package:hospital_management/data/repositories/nurse_repository_impl.dart';
import 'package:hospital_management/data/repositories/prescription_repository_impl.dart';
import 'package:hospital_management/data/repositories/appointment_repository_impl.dart';
import 'package:hospital_management/data/datasources/patient_local_data_source.dart';
import 'package:hospital_management/data/datasources/doctor_local_data_source.dart';
import 'package:hospital_management/data/datasources/room_local_data_source.dart';
import 'package:hospital_management/data/datasources/bed_local_data_source.dart';
import 'package:hospital_management/data/datasources/nurse_local_data_source.dart';
import 'package:hospital_management/data/datasources/prescription_local_data_source.dart';
import 'package:hospital_management/data/datasources/appointment_local_data_source.dart';
import 'package:hospital_management/data/datasources/equipment_local_data_source.dart';
import 'package:hospital_management/data/datasources/medication_local_data_source.dart';
import 'package:hospital_management/domain/repositories/patient_repository.dart';
import 'package:hospital_management/domain/repositories/doctor_repository.dart';
import 'package:hospital_management/domain/repositories/room_repository.dart';
import 'package:hospital_management/domain/repositories/nurse_repository.dart';
import 'package:hospital_management/domain/repositories/prescription_repository.dart';
import 'package:hospital_management/domain/repositories/appointment_repository.dart';
import 'package:hospital_management/presentation/menus/patient_menu.dart';
import 'package:hospital_management/presentation/menus/doctor_menu.dart';
import 'package:hospital_management/presentation/menus/appointment_menu.dart';
import 'package:hospital_management/presentation/menus/prescription_menu.dart';
import 'package:hospital_management/presentation/menus/room_menu.dart';
import 'package:hospital_management/presentation/menus/nurse_menu.dart';
import 'package:hospital_management/presentation/menus/search_menu.dart';
import 'package:hospital_management/presentation/menus/emergency_menu.dart';
import 'package:hospital_management/presentation/utils/input_validator.dart';
import 'package:hospital_management/presentation/utils/ui_helper.dart';

class MainMenuController {
  // Data sources
  late final PatientLocalDataSource _patientLocalDataSource;
  late final DoctorLocalDataSource _doctorLocalDataSource;
  late final RoomLocalDataSource _roomLocalDataSource;
  late final BedLocalDataSource _bedLocalDataSource;
  late final NurseLocalDataSource _nurseLocalDataSource;
  late final PrescriptionLocalDataSource _prescriptionLocalDataSource;
  late final AppointmentLocalDataSource _appointmentLocalDataSource;
  late final EquipmentLocalDataSource _equipmentLocalDataSource;
  late final MedicationLocalDataSource _medicationLocalDataSource;

  // Repositories
  late final PatientRepository _patientRepository;
  late final DoctorRepository _doctorRepository;
  late final RoomRepository _roomRepository;
  late final NurseRepository _nurseRepository;
  late final PrescriptionRepository _prescriptionRepository;
  late final AppointmentRepository _appointmentRepository;

  MainMenuController({
    PatientRepository? patientRepository,
    DoctorRepository? doctorRepository,
    RoomRepository? roomRepository,
    NurseRepository? nurseRepository,
    PrescriptionRepository? prescriptionRepository,
    AppointmentRepository? appointmentRepository,
  }) {
    // Initialize data sources first
    _initializeDataSources();

    // Then initialize repositories with data sources
    _patientRepository = patientRepository ??
        PatientRepositoryImpl(
          patientDataSource: _patientLocalDataSource,
          doctorDataSource: _doctorLocalDataSource,
        );

    _doctorRepository = doctorRepository ??
        DoctorRepositoryImpl(
          doctorDataSource: _doctorLocalDataSource,
          patientDataSource: _patientLocalDataSource,
        );

    _roomRepository = roomRepository ??
        RoomRepositoryImpl(
          roomDataSource: _roomLocalDataSource,
          bedDataSource: _bedLocalDataSource,
          equipmentDataSource: _equipmentLocalDataSource,
          patientDataSource: _patientLocalDataSource,
        );

    _nurseRepository = nurseRepository ??
        NurseRepositoryImpl(
          nurseDataSource: _nurseLocalDataSource,
          patientDataSource: _patientLocalDataSource,
          roomDataSource: _roomLocalDataSource,
          bedDataSource: _bedLocalDataSource,
          equipmentDataSource: _equipmentLocalDataSource,
        );

    _prescriptionRepository = prescriptionRepository ??
        PrescriptionRepositoryImpl(
          prescriptionDataSource: _prescriptionLocalDataSource,
          doctorDataSource: _doctorLocalDataSource,
          patientDataSource: _patientLocalDataSource,
          medicationDataSource: _medicationLocalDataSource,
        );

    _appointmentRepository = appointmentRepository ??
        AppointmentRepositoryImpl(
          appointmentDataSource: _appointmentLocalDataSource,
          doctorDataSource: _doctorLocalDataSource,
          patientDataSource: _patientLocalDataSource,
        );
  }

  void _initializeDataSources() {
    _patientLocalDataSource = PatientLocalDataSource();
    _doctorLocalDataSource = DoctorLocalDataSource();
    _roomLocalDataSource = RoomLocalDataSource();
    _bedLocalDataSource = BedLocalDataSource();
    _nurseLocalDataSource = NurseLocalDataSource();
    _prescriptionLocalDataSource = PrescriptionLocalDataSource();
    _appointmentLocalDataSource = AppointmentLocalDataSource();
    _equipmentLocalDataSource = EquipmentLocalDataSource();
    _medicationLocalDataSource = MedicationLocalDataSource();
  }

  final List<String> _menuOptions = [
    'Patient Management',
    'Doctor Management',
    'Appointment Management',
    'Prescription Management',
    'Room Management',
    'Nurse Management',
    'Search Operations',
    'Emergency Operations',
  ];

  Future<void> run() async {
    bool isRunning = true;

    while (isRunning) {
      try {
        UIHelper.printApplicationHeader();
        UIHelper.printMenu('MAIN MENU', _menuOptions);

        final choice = InputValidator.readChoice(_menuOptions.length);

        switch (choice) {
          case 1:
            await PatientMenu(
              patientRepository: _patientRepository,
              doctorRepository: _doctorRepository,
              roomRepository: _roomRepository,
            ).show();
            break;
          case 2:
            await DoctorMenu(
              doctorRepository: _doctorRepository,
              patientRepository: _patientRepository,
            ).show();
            break;
          case 3:
            await AppointmentMenu(
              appointmentRepository: _appointmentRepository,
              patientRepository: _patientRepository,
              doctorRepository: _doctorRepository,
            ).show();
            break;
          case 4:
            await PrescriptionMenu(
              prescriptionRepository: _prescriptionRepository,
              patientRepository: _patientRepository,
              doctorRepository: _doctorRepository,
            ).show();
            break;
          case 5:
            await RoomMenu(
              roomRepository: _roomRepository,
              patientRepository: _patientRepository,
            ).show();
            break;
          case 6:
            await NurseMenu(
              nurseRepository: _nurseRepository,
              patientRepository: _patientRepository,
            ).show();
            break;
          case 7:
            await SearchMenu(
              patientRepository: _patientRepository,
              doctorRepository: _doctorRepository,
              roomRepository: _roomRepository,
              nurseRepository: _nurseRepository,
              prescriptionRepository: _prescriptionRepository,
              appointmentRepository: _appointmentRepository,
            ).show();
            break;
          case 8:
            await EmergencyMenu(
              patientRepository: _patientRepository,
              roomRepository: _roomRepository,
              doctorRepository: _doctorRepository,
              nurseRepository: _nurseRepository,
            ).show();
            break;
          case 0:
            isRunning = false;
            UIHelper.printGoodbye();
            break;
        }
      } catch (e) {
        UIHelper.printError('An error occurred: $e');
        UIHelper.pressEnterToContinue();
      }
    }
  }
}
