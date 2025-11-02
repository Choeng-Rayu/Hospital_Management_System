import 'package:hospital_management/domain/entities/appointment.dart';
import 'package:hospital_management/domain/entities/enums/appointment_status.dart';
import 'package:hospital_management/domain/repositories/appointment_repository.dart';
import 'package:hospital_management/domain/repositories/doctor_repository.dart';
import 'package:hospital_management/domain/repositories/patient_repository.dart';
import 'package:hospital_management/domain/usecases/appointment/schedule_appointment.dart';
import 'package:hospital_management/domain/usecases/appointment/cancel_appointment.dart';
import 'package:hospital_management/domain/usecases/appointment/reschedule_appointment.dart';
import 'package:hospital_management/presentation/menus/base_menu.dart';
import 'package:hospital_management/presentation/utils/input_validator.dart';
import 'package:hospital_management/presentation/utils/ui_helper.dart';

class AppointmentMenu extends BaseMenu {
  final AppointmentRepository _appointmentRepository;
  final PatientRepository _patientRepository;
  final DoctorRepository _doctorRepository;

  AppointmentMenu({
    required AppointmentRepository appointmentRepository,
    required PatientRepository patientRepository,
    required DoctorRepository doctorRepository,
  })  : _appointmentRepository = appointmentRepository,
        _patientRepository = patientRepository,
        _doctorRepository = doctorRepository;

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
        'View Appointments by Date',
        'Update Appointment Status',
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
      case 9:
        await _viewAppointmentsByDate();
        break;
      case 10:
        await _updateAppointmentStatus();
        break;
    }
  }

  Future<void> _scheduleAppointment() async {
    UIHelper.printHeader('Schedule New Appointment');

    try {
      // Get patient ID
      final patientId = InputValidator.readId('Enter patient ID', 'P');
      final patient = await _patientRepository.getPatientById(patientId);
      UIHelper.printInfo('Patient: ${patient.name}');

      // Get doctor ID
      final doctorId = InputValidator.readId('Enter doctor ID', 'D');
      final doctor = await _doctorRepository.getDoctorById(doctorId);
      UIHelper.printInfo('Doctor: ${doctor.name} (${doctor.specialization})');

      // Get appointment date and time
      final date = InputValidator.readDate('Enter appointment date');
      final time = InputValidator.readTime('Enter appointment time');

      final timeComponents = time.split(':');
      final dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(timeComponents[0]),
        int.parse(timeComponents[1]),
      );

      // Get duration
      final duration = InputValidator.readInt('Enter duration in minutes',
          min: 15, max: 240);

      // Get reason
      final reason = InputValidator.readString('Enter reason for appointment');

      // Optional room
      UIHelper.printInfo('Room assignment (optional)');
      final assignRoom = InputValidator.readBoolean('Assign room?');
      String? roomId;
      if (assignRoom) {
        roomId = InputValidator.readString('Enter room ID');
      }

      // Optional notes
      final addNotes = InputValidator.readBoolean('Add notes?');
      String? notes;
      if (addNotes) {
        notes = InputValidator.readString('Enter notes');
      }

      // Generate appointment ID
      final appointmentId =
          'A${DateTime.now().millisecondsSinceEpoch % 100000}'.padLeft(6, '0');

      // Schedule appointment using use case
      final useCase = ScheduleAppointment(
        appointmentRepository: _appointmentRepository,
        patientRepository: _patientRepository,
        doctorRepository: _doctorRepository,
        roomRepository: _appointmentRepository
            as dynamic, // Need RoomRepository - will handle error
      );

      final appointment = await useCase.execute(
        appointmentId: appointmentId,
        patientId: patientId,
        doctorId: doctorId,
        dateTime: dateTime,
        duration: duration,
        reason: reason,
        roomId: roomId,
        notes: notes,
      );

      UIHelper.printSuccess(
          'Appointment scheduled successfully! ID: ${appointment.id}');
      UIHelper.printInfo('Date/Time: ${UIHelper.formatDateTime(dateTime)}');
      UIHelper.printInfo('Duration: $duration minutes');
    } catch (e) {
      UIHelper.printError('Failed to schedule appointment: $e');
    }
  }

  Future<void> _viewAllAppointments() async {
    UIHelper.printHeader('All Appointments');

    try {
      final appointments = await _appointmentRepository.getAllAppointments();
      if (appointments.isEmpty) {
        UIHelper.printWarning('No appointments found');
        return;
      }

      final tableData = appointments
          .map((apt) => [
                apt.id,
                apt.patient.name,
                apt.doctor.name,
                UIHelper.formatDateTime(apt.dateTime),
                '${apt.duration} min',
                apt.status.toString().split('.').last,
              ])
          .toList();

      UIHelper.printTable(
        tableData,
        headers: ['ID', 'Patient', 'Doctor', 'Date/Time', 'Duration', 'Status'],
      );
    } catch (e) {
      UIHelper.printError('Failed to load appointments: $e');
    }
  }

  Future<void> _viewUpcomingAppointments() async {
    UIHelper.printHeader('Upcoming Appointments');

    try {
      final appointments =
          await _appointmentRepository.getUpcomingAppointments();

      if (appointments.isEmpty) {
        UIHelper.printWarning('No upcoming appointments found');
        return;
      }

      UIHelper.printInfo('Found ${appointments.length} upcoming appointments');

      final tableData = appointments
          .map((apt) => [
                apt.id,
                apt.patient.name,
                apt.doctor.name,
                UIHelper.formatDateTime(apt.dateTime),
                apt.reason,
              ])
          .toList();

      UIHelper.printTable(
        tableData,
        headers: ['ID', 'Patient', 'Doctor', 'Date/Time', 'Reason'],
      );
    } catch (e) {
      UIHelper.printError('Failed to load upcoming appointments: $e');
    }
  }

  Future<void> _viewAppointmentDetails() async {
    UIHelper.printHeader('View Appointment Details');

    try {
      final appointmentId = InputValidator.readString('Enter appointment ID');
      final appointment =
          await _appointmentRepository.getAppointmentById(appointmentId);

      _displayAppointmentDetails(appointment);
    } catch (e) {
      UIHelper.printError('Failed to load appointment: $e');
    }
  }

  Future<void> _rescheduleAppointment() async {
    UIHelper.printHeader('Reschedule Appointment');

    try {
      final appointmentId = InputValidator.readString('Enter appointment ID');
      final appointment =
          await _appointmentRepository.getAppointmentById(appointmentId);

      UIHelper.printInfo('Current appointment details:');
      _displayAppointmentDetails(appointment);

      // Get new date and time
      final newDate = InputValidator.readDate('Enter new appointment date');
      final newTime = InputValidator.readTime('Enter new appointment time');

      final timeComponents = newTime.split(':');
      final newDateTime = DateTime(
        newDate.year,
        newDate.month,
        newDate.day,
        int.parse(timeComponents[0]),
        int.parse(timeComponents[1]),
      );

      // Get new duration if needed
      final changeDuration = InputValidator.readBoolean(
          'Change duration? (current: ${appointment.duration} min)');
      if (changeDuration) {
        InputValidator.readInt('Enter new duration in minutes',
            min: 15, max: 240);
      }

      // Reschedule using use case
      final useCase = RescheduleAppointment(
        appointmentRepository: _appointmentRepository,
        doctorRepository: _doctorRepository,
        patientRepository: _patientRepository,
      );

      final input = RescheduleAppointmentInput(
        appointmentId: appointmentId,
        newDateTime: newDateTime,
      );

      final result = await useCase.execute(input);

      UIHelper.printSuccess('Appointment rescheduled successfully!');
      UIHelper.printInfo('Confirmation: ${result.confirmationNumber}');
      UIHelper.printInfo(
          'New Date/Time: ${UIHelper.formatDateTime(newDateTime)}');
    } catch (e) {
      UIHelper.printError('Failed to reschedule appointment: $e');
    }
  }

  Future<void> _cancelAppointment() async {
    UIHelper.printHeader('Cancel Appointment');

    try {
      final appointmentId = InputValidator.readString('Enter appointment ID');
      final appointment =
          await _appointmentRepository.getAppointmentById(appointmentId);

      _displayAppointmentDetails(appointment);

      final confirm = InputValidator.readBoolean(
          'Are you sure you want to cancel this appointment?');

      if (!confirm) {
        UIHelper.printInfo('Cancellation aborted');
        return;
      }

      // Cancel using use case
      final useCase = CancelAppointment(
        appointmentRepository: _appointmentRepository,
      );
      await useCase.execute(appointmentId: appointmentId);

      UIHelper.printSuccess('Appointment cancelled successfully');
    } catch (e) {
      UIHelper.printError('Failed to cancel appointment: $e');
    }
  }

  Future<void> _viewPatientAppointments() async {
    UIHelper.printHeader('View Patient Appointments');

    try {
      final patientId = InputValidator.readId('Enter patient ID', 'P');
      final appointments =
          await _appointmentRepository.getAppointmentsByPatient(patientId);

      if (appointments.isEmpty) {
        UIHelper.printWarning('No appointments found for this patient');
        return;
      }

      final tableData = appointments
          .map((apt) => [
                apt.id,
                apt.doctor.name,
                UIHelper.formatDateTime(apt.dateTime),
                '${apt.duration} min',
                apt.status.toString().split('.').last,
                apt.reason,
              ])
          .toList();

      UIHelper.printTable(
        tableData,
        headers: ['ID', 'Doctor', 'Date/Time', 'Duration', 'Status', 'Reason'],
      );
    } catch (e) {
      UIHelper.printError('Failed to load patient appointments: $e');
    }
  }

  Future<void> _viewDoctorAppointments() async {
    UIHelper.printHeader('View Doctor Appointments');

    try {
      final doctorId = InputValidator.readId('Enter doctor ID', 'D');
      final appointments =
          await _appointmentRepository.getAppointmentsByDoctor(doctorId);

      if (appointments.isEmpty) {
        UIHelper.printWarning('No appointments found for this doctor');
        return;
      }

      final tableData = appointments
          .map((apt) => [
                apt.id,
                apt.patient.name,
                UIHelper.formatDateTime(apt.dateTime),
                '${apt.duration} min',
                apt.status.toString().split('.').last,
                apt.reason,
              ])
          .toList();

      UIHelper.printTable(
        tableData,
        headers: ['ID', 'Patient', 'Date/Time', 'Duration', 'Status', 'Reason'],
      );
    } catch (e) {
      UIHelper.printError('Failed to load doctor appointments: $e');
    }
  }

  Future<void> _viewAppointmentsByDate() async {
    UIHelper.printHeader('View Appointments by Date');

    try {
      final date = InputValidator.readDate('Enter date');
      final appointments =
          await _appointmentRepository.getAppointmentsByDate(date);

      if (appointments.isEmpty) {
        UIHelper.printWarning(
            'No appointments found for ${UIHelper.formatDate(date)}');
        return;
      }

      final tableData = appointments
          .map((apt) => [
                apt.id,
                UIHelper.formatTime(apt.dateTime),
                apt.patient.name,
                apt.doctor.name,
                '${apt.duration} min',
                apt.status.toString().split('.').last,
              ])
          .toList();

      UIHelper.printTable(
        tableData,
        headers: ['ID', 'Time', 'Patient', 'Doctor', 'Duration', 'Status'],
      );
    } catch (e) {
      UIHelper.printError('Failed to load appointments: $e');
    }
  }

  Future<void> _updateAppointmentStatus() async {
    UIHelper.printHeader('Update Appointment Status');

    try {
      final appointmentId = InputValidator.readString('Enter appointment ID');
      final appointment =
          await _appointmentRepository.getAppointmentById(appointmentId);

      _displayAppointmentDetails(appointment);

      UIHelper.printSubHeader('Available Status Options');
      print('1. SCHEDULED');
      print('2. COMPLETED');
      print('3. CANCELLED');
      print('4. NO_SHOW');

      final statusChoice = InputValidator.readChoice(4);
      if (statusChoice == 0) return;

      // Update the appointment status
      final statusMap = {
        1: AppointmentStatus.SCHEDULE,
        2: AppointmentStatus.COMPLETED,
        3: AppointmentStatus.CANCELLED,
        4: AppointmentStatus.NO_SHOW,
      };

      final newStatus = statusMap[statusChoice]!;
      appointment.updateStatus(newStatus);
      await _appointmentRepository.updateAppointment(appointment);

      UIHelper.printSuccess(
          'Appointment status updated to: ${newStatus.toString().split('.').last}');
    } catch (e) {
      UIHelper.printError('Failed to update appointment status: $e');
    }
  }

  void _displayAppointmentDetails(Appointment appointment) {
    UIHelper.printSubHeader('Appointment Information');
    print('ID: ${appointment.id}');
    print(
        'Patient: ${appointment.patient.name} (${appointment.patient.patientID})');
    print(
        'Doctor: ${appointment.doctor.name} (${appointment.doctor.specialization})');
    print('Date/Time: ${UIHelper.formatDateTime(appointment.dateTime)}');
    print('Duration: ${appointment.duration} minutes');
    print('Status: ${appointment.status.toString().split('.').last}');
    print('Reason: ${appointment.reason}');

    if (appointment.room != null) {
      print('Room: ${appointment.room!.number}');
    }

    if (appointment.notes != null && appointment.notes!.isNotEmpty) {
      UIHelper.printSubHeader('Notes');
      print(appointment.notes);
    }
  }
}
