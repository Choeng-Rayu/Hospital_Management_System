import '../../entities/appointment.dart';
import '../../entities/enums/appointment_status.dart';
import '../../repositories/appointment_repository.dart';
import '../../repositories/doctor_repository.dart';
import '../base/use_case.dart';

/// Input for getting doctor appointments
class GetAppointmentsByDoctorInput {
  final String doctorId;
  final DateTime? date; // Specific date, if null gets all
  final bool onlyToday;
  final bool includeCompleted;

  GetAppointmentsByDoctorInput({
    required this.doctorId,
    this.date,
    this.onlyToday = false,
    this.includeCompleted = true,
  });
}

/// Doctor's daily schedule slot
class ScheduleSlot {
  final Appointment? appointment;
  final DateTime startTime;
  final DateTime endTime;
  final bool isBooked;
  final bool isAvailable;

  ScheduleSlot({
    this.appointment,
    required this.startTime,
    required this.endTime,
    required this.isBooked,
    required this.isAvailable,
  });

  @override
  String toString() {
    final timeRange =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}-${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    if (isBooked && appointment != null) {
      return '🔴 $timeRange - Patient: ${appointment!.patient.patientID}';
    } else if (isAvailable) {
      return '🟢 $timeRange - Available';
    } else {
      return '⚪ $timeRange - Off hours';
    }
  }
}

/// Doctor appointments summary
class DoctorAppointmentsSummary {
  final String doctorId;
  final String doctorName;
  final String specialization;
  final List<Appointment> appointments;
  final List<ScheduleSlot> dailySchedule;
  final int totalAppointments;
  final int completedToday;
  final int upcomingToday;
  final int availableSlots;
  final DateTime? targetDate;

  DoctorAppointmentsSummary({
    required this.doctorId,
    required this.doctorName,
    required this.specialization,
    required this.appointments,
    required this.dailySchedule,
    required this.totalAppointments,
    required this.completedToday,
    required this.upcomingToday,
    required this.availableSlots,
    this.targetDate,
  });

  @override
  String toString() {
    final dateStr =
        targetDate != null ? targetDate!.toString().split(' ')[0] : 'All dates';
    return '''
👨‍⚕️ DOCTOR SCHEDULE
━━━━━━━━━━━━━━━━━━━━━━━━
Doctor: $doctorName ($specialization)
Date: $dateStr
Total Appointments: $totalAppointments
Completed: $completedToday
Upcoming: $upcomingToday
Available Slots: $availableSlots

${dailySchedule.isNotEmpty ? '📅 Schedule:\n${dailySchedule.map((s) => s.toString()).join('\n')}' : ''}

${appointments.isNotEmpty ? '\n📋 Appointments:\n${appointments.take(10).map((a) => '   • ${a.dateTime.toString().split('.')[0]} - ${a.patient.patientID} (${a.status})').join('\n')}' : ''}
''';
  }
}

/// Use case for getting all appointments for a specific doctor
/// Provides doctor's schedule view with availability
class GetAppointmentsByDoctor
    extends UseCase<GetAppointmentsByDoctorInput, DoctorAppointmentsSummary> {
  final AppointmentRepository appointmentRepository;
  final DoctorRepository doctorRepository;

  GetAppointmentsByDoctor({
    required this.appointmentRepository,
    required this.doctorRepository,
  });

  @override
  Future<bool> validate(GetAppointmentsByDoctorInput input) async {
    if (input.doctorId.trim().isEmpty) {
      throw UseCaseValidationException('Doctor ID is required');
    }
    return true;
  }

  @override
  Future<DoctorAppointmentsSummary> execute(
      GetAppointmentsByDoctorInput input) async {
    final doctor = await doctorRepository.getDoctorById(input.doctorId);
    final doctorName = doctor.name;

    final allAppointments = await appointmentRepository.getAllAppointments();
    List<Appointment> doctorAppointments = allAppointments
        .where((apt) => apt.doctor.staffID == input.doctorId)
        .toList();

    DateTime targetDate;
    if (input.onlyToday) {
      final now = DateTime.now();
      targetDate = DateTime(now.year, now.month, now.day);
    } else if (input.date != null) {
      targetDate =
          DateTime(input.date!.year, input.date!.month, input.date!.day);
    } else {
      targetDate = DateTime.now(); // Default to today for schedule
    }

    final dateAppointments = doctorAppointments.where((apt) {
      final aptDate =
          DateTime(apt.dateTime.year, apt.dateTime.month, apt.dateTime.day);
      return aptDate.isAtSameMomentAs(targetDate);
    }).toList();

    if (!input.includeCompleted) {
      doctorAppointments = doctorAppointments
          .where((apt) => apt.status != AppointmentStatus.COMPLETED)
          .toList();
    }

    doctorAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    final dailySchedule = <ScheduleSlot>[];
    final scheduleDate = targetDate;

    for (int hour = 8; hour < 18; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        final slotStart = DateTime(
          scheduleDate.year,
          scheduleDate.month,
          scheduleDate.day,
          hour,
          minute,
        );
        final slotEnd = slotStart.add(const Duration(minutes: 30));

        final slotAppointment =
            dateAppointments.cast<Appointment?>().firstWhere(
          (apt) {
            final aptTime = apt!.dateTime;
            return aptTime
                    .isAfter(slotStart.subtract(const Duration(minutes: 1))) &&
                aptTime.isBefore(slotEnd);
          },
          orElse: () => null,
        );

        final isBooked = slotAppointment != null;
        final isAvailable = !isBooked;

        dailySchedule.add(ScheduleSlot(
          appointment: isBooked ? slotAppointment : null,
          startTime: slotStart,
          endTime: slotEnd,
          isBooked: isBooked,
          isAvailable: isAvailable,
        ));
      }
    }

    final now = DateTime.now();
    final completedToday = dateAppointments
        .where((apt) =>
            apt.status == AppointmentStatus.COMPLETED ||
            apt.dateTime.isBefore(now))
        .length;
    final upcomingToday = dateAppointments
        .where((apt) =>
            apt.status != AppointmentStatus.COMPLETED &&
            apt.dateTime.isAfter(now))
        .length;
    final availableSlots =
        dailySchedule.where((slot) => slot.isAvailable).length;

    return DoctorAppointmentsSummary(
      doctorId: input.doctorId,
      doctorName: doctorName,
      specialization: doctor.specialization,
      appointments: doctorAppointments,
      dailySchedule: dailySchedule,
      totalAppointments: doctorAppointments.length,
      completedToday: completedToday,
      upcomingToday: upcomingToday,
      availableSlots: availableSlots,
      targetDate: input.date ?? (input.onlyToday ? targetDate : null),
    );
  }

  @override
  Future<void> onSuccess(DoctorAppointmentsSummary result,
      GetAppointmentsByDoctorInput input) async {
    print('📅 Doctor schedule loaded: ${result.doctorName}');
    print('   Total: ${result.totalAppointments} appointments');
    print('   Available slots: ${result.availableSlots}');
  }
}
