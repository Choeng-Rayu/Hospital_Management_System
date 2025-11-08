import '../../entities/appointment.dart';
import '../../entities/enums/appointment_status.dart';
import '../../repositories/appointment_repository.dart';
import '../base/use_case.dart';

/// Input for getting upcoming appointments
class GetUpcomingAppointmentsInput {
  final String? patientId;
  final String? doctorId;
  final int daysAhead; // Look ahead this many days
  final bool includeToday;

  GetUpcomingAppointmentsInput({
    this.patientId,
    this.doctorId,
    this.daysAhead = 30,
    this.includeToday = true,
  });
}

/// Upcoming appointment with countdown information
class UpcomingAppointmentInfo {
  final Appointment appointment;
  final int daysUntil;
  final int hoursUntil;
  final bool isToday;
  final bool isTomorrow;
  final bool isThisWeek;
  final String timeDescription;

  UpcomingAppointmentInfo({
    required this.appointment,
    required this.daysUntil,
    required this.hoursUntil,
    required this.isToday,
    required this.isTomorrow,
    required this.isThisWeek,
    required this.timeDescription,
  });

  @override
  String toString() {
    final urgencyEmoji = isToday
        ? '🔴'
        : isTomorrow
            ? '🟡'
            : isThisWeek
                ? '🟢'
                : '⚪';
    return '$urgencyEmoji $timeDescription - ${appointment.dateTime.toString().split('.')[0]}';
  }
}

/// Result containing upcoming appointments
class UpcomingAppointmentsResult {
  final List<UpcomingAppointmentInfo> appointments;
  final int todayCount;
  final int tomorrowCount;
  final int thisWeekCount;
  final int totalCount;
  final UpcomingAppointmentInfo? nextAppointment;

  UpcomingAppointmentsResult({
    required this.appointments,
    required this.todayCount,
    required this.tomorrowCount,
    required this.thisWeekCount,
    required this.totalCount,
    this.nextAppointment,
  });

  @override
  String toString() {
    return '''
📅 UPCOMING APPOINTMENTS
━━━━━━━━━━━━━━━━━━━━━━━━
Total: $totalCount
Today: $todayCount
Tomorrow: $tomorrowCount
This Week: $thisWeekCount

${nextAppointment != null ? '⏰ Next: ${nextAppointment!.timeDescription}\n\n' : ''}${appointments.map((e) => e.toString()).join('\n')}
''';
  }
}

/// Use case for getting upcoming appointments
/// Provides countdown and urgency information
class GetUpcomingAppointments
    extends UseCase<GetUpcomingAppointmentsInput, UpcomingAppointmentsResult> {
  final AppointmentRepository appointmentRepository;

  GetUpcomingAppointments({required this.appointmentRepository});

  @override
  Future<bool> validate(GetUpcomingAppointmentsInput input) async {
    // Must provide either patientId or doctorId
    if (input.patientId == null && input.doctorId == null) {
      throw UseCaseValidationException(
        'Must provide either patientId or doctorId',
      );
    }

    // Validate daysAhead
    if (input.daysAhead < 1 || input.daysAhead > 365) {
      throw UseCaseValidationException(
        'Days ahead must be between 1 and 365',
      );
    }
    return true;
  }

  @override
  Future<UpcomingAppointmentsResult> execute(
      GetUpcomingAppointmentsInput input) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final weekEnd = today.add(const Duration(days: 7));
    final futureLimit = now.add(Duration(days: input.daysAhead));

    // Get all appointments
    final allAppointments = await appointmentRepository.getAllAppointments();

    // Filter by patient or doctor
    List<Appointment> filteredAppointments = allAppointments;

    if (input.patientId != null) {
      filteredAppointments = filteredAppointments
          .where((apt) => apt.patient.patientID == input.patientId)
          .toList();
    }

    if (input.doctorId != null) {
      filteredAppointments = filteredAppointments
          .where((apt) => apt.doctor.staffID == input.doctorId)
          .toList();
    }

    // Filter for upcoming appointments
    filteredAppointments = filteredAppointments.where((apt) {
      final aptDate = apt.dateTime;

      if (input.includeToday) {
        return aptDate.isAfter(now) && aptDate.isBefore(futureLimit);
      } else {
        return aptDate.isAfter(futureLimit);
      }
    }).toList();

    // Filter out cancelled appointments
    filteredAppointments = filteredAppointments
        .where((apt) => apt.status != AppointmentStatus.CANCELLED)
        .toList(); // Sort by date (soonest first)
    filteredAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    // Create appointment info objects
    int todayCount = 0;
    int tomorrowCount = 0;
    int thisWeekCount = 0;

    final appointmentInfos = filteredAppointments.map((apt) {
      final aptDate =
          DateTime(apt.dateTime.year, apt.dateTime.month, apt.dateTime.day);
      final daysUntil = aptDate.difference(today).inDays;
      final hoursUntil = apt.dateTime.difference(now).inHours;

      final isToday = aptDate.isAtSameMomentAs(today);
      final isTomorrow = aptDate.isAtSameMomentAs(tomorrow);
      final isThisWeek = apt.dateTime.isBefore(weekEnd);

      if (isToday) todayCount++;
      if (isTomorrow) tomorrowCount++;
      if (isThisWeek) thisWeekCount++;

      String timeDescription;
      if (isToday) {
        if (hoursUntil < 1) {
          final minutesUntil = apt.dateTime.difference(now).inMinutes;
          timeDescription = 'In $minutesUntil minutes';
        } else {
          timeDescription = 'Today in $hoursUntil hours';
        }
      } else if (isTomorrow) {
        timeDescription = 'Tomorrow';
      } else if (daysUntil < 7) {
        final weekdayNames = [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday'
        ];
        timeDescription = weekdayNames[apt.dateTime.weekday - 1];
      } else {
        timeDescription = 'In $daysUntil days';
      }

      return UpcomingAppointmentInfo(
        appointment: apt,
        daysUntil: daysUntil,
        hoursUntil: hoursUntil,
        isToday: isToday,
        isTomorrow: isTomorrow,
        isThisWeek: isThisWeek,
        timeDescription: timeDescription,
      );
    }).toList();

    return UpcomingAppointmentsResult(
      appointments: appointmentInfos,
      todayCount: todayCount,
      tomorrowCount: tomorrowCount,
      thisWeekCount: thisWeekCount,
      totalCount: appointmentInfos.length,
      nextAppointment:
          appointmentInfos.isNotEmpty ? appointmentInfos.first : null,
    );
  }

  @override
  Future<void> onSuccess(UpcomingAppointmentsResult result,
      GetUpcomingAppointmentsInput input) async {
    if (result.todayCount > 0) {
      print('⏰ ${result.todayCount} appointment(s) today');
    }

    if (result.nextAppointment != null) {
      print('📅 Next appointment: ${result.nextAppointment!.timeDescription}');
    }
  }
}
