import 'package:hospital_management/domain/repositories/appointment_repository.dart';
import 'package:hospital_management/domain/repositories/doctor_repository.dart';
import 'package:hospital_management/domain/repositories/patient_repository.dart';
import 'package:hospital_management/presentation/menus/base_menu.dart';
import 'package:hospital_management/presentation/utils/ui_helper.dart';

class AppointmentMenu extends BaseMenu {
  final AppointmentRepository appointmentRepository;
  final PatientRepository patientRepository;
  final DoctorRepository doctorRepository;

  AppointmentMenu({
    required this.appointmentRepository,
    required this.patientRepository,
    required this.doctorRepository,
  });

  @override
  String get menuTitle => 'APPOINTMENT MANAGEMENT';

  @override
  List<String> get menuOptions => [
        'Schedule New Appointment',
        'View All Appointments',
        'View Upcoming Appointments',
        'View Appointment Details',
        'Reschedule Appointment',
        'Cancel Appointment',
        'View Patient Appointments',
        'View Doctor Appointments',
      ];

  @override
  Future<void> handleChoice(int choice) async {
    switch (choice) {
      case 1:
        await _scheduleAppointment();
        break;
      case 2:
        await _viewAllAppointments();
        break;
      case 3:
        await _viewUpcomingAppointments();
        break;
      case 4:
        await _viewAppointmentDetails();
        break;
      case 5:
        await _rescheduleAppointment();
        break;
      case 6:
        await _cancelAppointment();
        break;
      case 7:
        await _viewPatientAppointments();
        break;
      case 8:
        await _viewDoctorAppointments();
        break;
    }
  }

  Future<void> _scheduleAppointment() async {
    UIHelper.printInfo('Schedule New Appointment - Coming Soon');
  }

  Future<void> _viewAllAppointments() async {
    UIHelper.printInfo('View All Appointments - Coming Soon');
  }

  Future<void> _viewUpcomingAppointments() async {
    UIHelper.printInfo('View Upcoming Appointments - Coming Soon');
  }

  Future<void> _viewAppointmentDetails() async {
    UIHelper.printInfo('View Appointment Details - Coming Soon');
  }

  Future<void> _rescheduleAppointment() async {
    UIHelper.printInfo('Reschedule Appointment - Coming Soon');
  }

  Future<void> _cancelAppointment() async {
    UIHelper.printInfo('Cancel Appointment - Coming Soon');
  }

  Future<void> _viewPatientAppointments() async {
    UIHelper.printInfo('View Patient Appointments - Coming Soon');
  }

  Future<void> _viewDoctorAppointments() async {
    UIHelper.printInfo('View Doctor Appointments - Coming Soon');
  }
}
