import '../../entities/enums/equipment_status.dart';
import '../../repositories/room_repository.dart';
import '../base/use_case.dart';

/// Input for reporting equipment issue
class ReportEquipmentIssueInput {
  final String equipmentId;
  final String issueDescription;
  final String severity; // 'CRITICAL', 'HIGH', 'MEDIUM', 'LOW'
  final String reportedBy;
  final DateTime reportedAt;
  final bool affectsPatientCare;

  ReportEquipmentIssueInput({
    required this.equipmentId,
    required this.issueDescription,
    required this.severity,
    required this.reportedBy,
    DateTime? reportedAt,
    this.affectsPatientCare = false,
  }) : reportedAt = reportedAt ?? DateTime.now();
}

/// Result of issue reporting
class EquipmentIssueReport {
  final String issueId;
  final String equipmentId;
  final String equipmentName;
  final String roomNumber;
  final String severity;
  final DateTime reportedAt;
  final String status; // 'REPORTED', 'IN_PROGRESS', 'RESOLVED'
  final int priorityScore;
  final String? recommendedAction;

  EquipmentIssueReport({
    required this.issueId,
    required this.equipmentId,
    required this.equipmentName,
    required this.roomNumber,
    required this.severity,
    required this.reportedAt,
    required this.status,
    required this.priorityScore,
    this.recommendedAction,
  });

  @override
  String toString() {
    return '''
⚠️ EQUIPMENT ISSUE: $issueId
━━━━━━━━━━━━━━━━━━━━━━━━
Equipment: $equipmentName
Location: Room $roomNumber
Severity: $severity (Priority: $priorityScore/100)
Status: $status
Reported: ${reportedAt.toString().split('.')[0]}
${recommendedAction != null ? '\n📋 Action: $recommendedAction' : ''}
''';
  }
}

/// Use case for reporting equipment malfunctions or issues
/// Creates work orders and alerts maintenance team
class ReportEquipmentIssue
    extends UseCase<ReportEquipmentIssueInput, EquipmentIssueReport> {
  final RoomRepository roomRepository;

  ReportEquipmentIssue({required this.roomRepository});

  @override
  Future<bool> validate(ReportEquipmentIssueInput input) async {
    final validSeverities = ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW'];
    if (!validSeverities.contains(input.severity)) {
      throw UseCaseValidationException(
        'Invalid severity. Must be one of: ${validSeverities.join(", ")}',
      );
    }

    if (input.issueDescription.trim().length < 10) {
      throw UseCaseValidationException(
        'Issue description must be at least 10 characters',
      );
    }

    if (input.reportedBy.trim().isEmpty) {
      throw UseCaseValidationException(
        'Reporter name/ID is required',
      );
    }
    return true;
  }

  @override
  Future<EquipmentIssueReport> execute(ReportEquipmentIssueInput input) async {
    // Find the equipment and its location
    final allRooms = await roomRepository.getAllRooms();
    String? equipmentName;
    String? roomNumber;

    for (final room in allRooms) {
      final equipment = room.equipment.firstWhere(
        (eq) => eq.equipmentId == input.equipmentId,
        orElse: () => throw EntityNotFoundException(
          'Equipment',
          input.equipmentId,
        ),
      );

      if (equipment.equipmentId == input.equipmentId) {
        equipmentName = equipment.name;
        roomNumber = room.number;

        // Update equipment status to reflect the issue
        final newStatus = input.severity == 'CRITICAL'
            ? EquipmentStatus.OUT_OF_SERVICE
            : EquipmentStatus.IN_MAINTENANCE;

        // Update equipment status
        equipment.updateStatus(newStatus);

        // Update room (equipment is already modified in-place)
        await roomRepository.updateRoom(room);
        break;
      }
    }

    if (equipmentName == null || roomNumber == null) {
      throw EntityNotFoundException(
        'Equipment',
        input.equipmentId,
      );
    }

    // Calculate priority score (1-100)
    int priorityScore = _calculatePriorityScore(
      input.severity,
      input.affectsPatientCare,
    );

    // Generate issue ID
    final issueId =
        'ISS-${input.severity.substring(0, 3)}-${input.reportedAt.millisecondsSinceEpoch % 100000}';

    // Determine recommended action
    final recommendedAction = _getRecommendedAction(
      input.severity,
      input.affectsPatientCare,
    );

    return EquipmentIssueReport(
      issueId: issueId,
      equipmentId: input.equipmentId,
      equipmentName: equipmentName,
      roomNumber: roomNumber,
      severity: input.severity,
      reportedAt: input.reportedAt,
      status: 'REPORTED',
      priorityScore: priorityScore,
      recommendedAction: recommendedAction,
    );
  }

  int _calculatePriorityScore(String severity, bool affectsPatientCare) {
    int baseScore;
    switch (severity) {
      case 'CRITICAL':
        baseScore = 90;
        break;
      case 'HIGH':
        baseScore = 70;
        break;
      case 'MEDIUM':
        baseScore = 50;
        break;
      case 'LOW':
        baseScore = 30;
        break;
      default:
        baseScore = 40;
    }

    // Add 10 points if affects patient care
    if (affectsPatientCare) {
      baseScore += 10;
    }

    return baseScore.clamp(0, 100);
  }

  String _getRecommendedAction(String severity, bool affectsPatientCare) {
    if (severity == 'CRITICAL') {
      if (affectsPatientCare) {
        return 'IMMEDIATE: Relocate patient and dispatch emergency maintenance';
      }
      return 'URGENT: Dispatch maintenance team within 1 hour';
    } else if (severity == 'HIGH') {
      return 'Schedule repair within 4 hours';
    } else if (severity == 'MEDIUM') {
      return 'Schedule repair within 24 hours';
    } else {
      return 'Add to routine maintenance queue';
    }
  }

  @override
  Future<void> onSuccess(
      EquipmentIssueReport result, ReportEquipmentIssueInput input) async {
    print('⚠️ Equipment issue reported: ${result.issueId}');
    print('   Severity: ${input.severity}');
    print('   Priority: ${result.priorityScore}/100');

    if (input.affectsPatientCare) {
      print('   🚨 AFFECTS PATIENT CARE - Immediate attention required');
    }
  }
}
