import '../../entities/doctor.dart';
import '../../repositories/nurse_repository.dart';
import '../../repositories/doctor_repository.dart';
import '../base/use_case.dart';

/// Input for notifying emergency staff
class NotifyEmergencyStaffInput {
  final String emergencyType;
  final String location;
  final String urgency; // 'CRITICAL', 'HIGH', 'MEDIUM'
  final String patientId;
  final String description;
  final List<String>? requiredSpecialties;

  NotifyEmergencyStaffInput({
    required this.emergencyType,
    required this.location,
    required this.urgency,
    required this.patientId,
    required this.description,
    this.requiredSpecialties,
  });
}

/// Staff notification result
class StaffNotificationResult {
  final List<String> notifiedDoctorIds;
  final List<String> notifiedNurseIds;
  final DateTime notificationTime;
  final int expectedResponseTime; // seconds
  final String alertCode;

  StaffNotificationResult({
    required this.notifiedDoctorIds,
    required this.notifiedNurseIds,
    required this.notificationTime,
    required this.expectedResponseTime,
    required this.alertCode,
  });

  @override
  String toString() {
    return '''
📢 EMERGENCY ALERT: $alertCode
━━━━━━━━━━━━━━━━━━━━━━━━
Doctors notified: ${notifiedDoctorIds.length}
Nurses notified: ${notifiedNurseIds.length}
Expected response: ${expectedResponseTime}s
Time: ${notificationTime.toString().split('.')[0]}
''';
  }
}

/// Use case for notifying emergency staff (doctors, nurses) about critical situations
/// Ensures rapid response by alerting on-call team
class NotifyEmergencyStaff
    extends UseCase<NotifyEmergencyStaffInput, StaffNotificationResult> {
  final DoctorRepository doctorRepository;
  final NurseRepository nurseRepository;

  NotifyEmergencyStaff({
    required this.doctorRepository,
    required this.nurseRepository,
  });

  @override
  Future<bool> validate(NotifyEmergencyStaffInput input) async {
    if (input.location.trim().isEmpty) {
      throw UseCaseValidationException('Location is required');
    }

    if (!['CRITICAL', 'HIGH', 'MEDIUM'].contains(input.urgency)) {
      throw UseCaseValidationException(
          'Urgency must be CRITICAL, HIGH, or MEDIUM');
    }
    return true;
  }

  @override
  Future<StaffNotificationResult> execute(
      NotifyEmergencyStaffInput input) async {
    final notificationTime = DateTime.now();

    final allDoctors = await doctorRepository.getAllDoctors();

    List<Doctor> targetDoctors = allDoctors;
    if (input.requiredSpecialties != null &&
        input.requiredSpecialties!.isNotEmpty) {
      targetDoctors = allDoctors
          .where((doc) => input.requiredSpecialties!.any((spec) =>
              doc.specialization.toLowerCase().contains(spec.toLowerCase())))
          .toList();
    }

    final availableDoctors = targetDoctors
        .where((doc) => doc.patientCount < 10) // Not overloaded (< 10 patients)
        .toList();

    final allNurses = await nurseRepository.getAllNurses();
    final availableNurses = allNurses
        .where((nurse) => nurse.patientCount < 5) // Not overloaded
        .toList();

    // Select staff based on urgency
    List<String> notifiedDoctorIds;
    List<String> notifiedNurseIds;
    int expectedResponseTime;

    switch (input.urgency) {
      case 'CRITICAL':
        // Notify ALL available staff
        notifiedDoctorIds =
            availableDoctors.map<String>((d) => d.staffID).toList();
        notifiedNurseIds =
            availableNurses.map<String>((n) => n.staffID).toList();
        expectedResponseTime = 60; // 1 minute
        break;

      case 'HIGH':
        // Notify senior staff + 2 nurses
        notifiedDoctorIds =
            availableDoctors.take(3).map<String>((d) => d.staffID).toList();
        notifiedNurseIds =
            availableNurses.take(2).map<String>((n) => n.staffID).toList();
        expectedResponseTime = 180; // 3 minutes
        break;

      case 'MEDIUM':
        // Notify on-call staff
        notifiedDoctorIds =
            availableDoctors.take(1).map<String>((d) => d.staffID).toList();
        notifiedNurseIds =
            availableNurses.take(1).map<String>((n) => n.staffID).toList();
        expectedResponseTime = 300; // 5 minutes
        break;

      default:
        notifiedDoctorIds = [];
        notifiedNurseIds = [];
        expectedResponseTime = 600;
    }

    final alertCode =
        '${input.urgency.substring(0, 3)}-${input.emergencyType.substring(0, 3).toUpperCase()}-${notificationTime.millisecondsSinceEpoch % 10000}';

    // TODO: Send actual notifications (SMS, pager, app push, etc.)
    // This would integrate with notification service in real implementation

    return StaffNotificationResult(
      notifiedDoctorIds: notifiedDoctorIds,
      notifiedNurseIds: notifiedNurseIds,
      notificationTime: notificationTime,
      expectedResponseTime: expectedResponseTime,
      alertCode: alertCode,
    );
  }

  @override
  Future<void> onSuccess(
      StaffNotificationResult result, NotifyEmergencyStaffInput input) async {
    print('📢 Emergency staff notified: ${result.alertCode}');
    print(
        '   ${result.notifiedDoctorIds.length} doctors, ${result.notifiedNurseIds.length} nurses');
    print('   Expected response: ${result.expectedResponseTime}s');
  }
}
