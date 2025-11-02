import '../base/use_case.dart';
import 'notify_emergency_staff.dart';

/// Input for initiating emergency protocol
class InitiateEmergencyProtocolInput {
  final String
      protocolType; // 'CODE_BLUE', 'CODE_RED', 'TRAUMA', 'STROKE', 'MI'
  final String location;
  final String patientId;
  final String description;
  final String reportedBy;

  InitiateEmergencyProtocolInput({
    required this.protocolType,
    required this.location,
    required this.patientId,
    required this.description,
    required this.reportedBy,
  });
}

/// Emergency protocol execution result
class EmergencyProtocolResult {
  final String protocolType;
  final String protocolId;
  final DateTime initiatedAt;
  final List<String> steps;
  final List<String> completedSteps;
  final StaffNotificationResult staffNotification;
  final String status; // 'INITIATED', 'IN_PROGRESS', 'COMPLETED'
  final int elapsedSeconds;

  EmergencyProtocolResult({
    required this.protocolType,
    required this.protocolId,
    required this.initiatedAt,
    required this.steps,
    required this.completedSteps,
    required this.staffNotification,
    required this.status,
    required this.elapsedSeconds,
  });

  @override
  String toString() {
    return '''
🚨 EMERGENCY PROTOCOL: $protocolType
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Protocol ID: $protocolId
Status: $status
Progress: ${completedSteps.length}/${steps.length} steps
Elapsed: ${elapsedSeconds}s
${staffNotification.toString()}
''';
  }
}

/// Use case for initiating standardized emergency protocols
/// Coordinates multiple emergency procedures automatically
class InitiateEmergencyProtocol
    extends UseCase<InitiateEmergencyProtocolInput, EmergencyProtocolResult> {
  final NotifyEmergencyStaff notifyStaffUseCase;

  InitiateEmergencyProtocol({
    required this.notifyStaffUseCase,
  });

  @override
  Future<bool> validate(InitiateEmergencyProtocolInput input) async {
    final validProtocols = [
      'CODE_BLUE', // Cardiac arrest
      'CODE_RED', // Fire
      'CODE_WHITE', // Pediatric emergency
      'CODE_YELLOW', // Bomb threat
      'TRAUMA', // Major trauma
      'STROKE', // Stroke alert
      'MI', // Myocardial infarction
      'SEPSIS', // Septic shock
    ];

    if (!validProtocols.contains(input.protocolType)) {
      throw UseCaseValidationException(
        'Invalid protocol type. Must be one of: ${validProtocols.join(", ")}',
      );
    }

    if (input.location.trim().isEmpty) {
      throw UseCaseValidationException('Location is required');
    }
    return true;
  }

  @override
  Future<EmergencyProtocolResult> execute(
      InitiateEmergencyProtocolInput input) async {
    final initiatedAt = DateTime.now();

    // Get protocol-specific steps
    final steps = _getProtocolSteps(input.protocolType);
    final completedSteps = <String>[];

    // Step 1: Notify emergency staff
    final staffNotification = await notifyStaffUseCase.call(
      NotifyEmergencyStaffInput(
        emergencyType: input.protocolType,
        location: input.location,
        urgency: _getProtocolUrgency(input.protocolType),
        patientId: input.patientId,
        description: input.description,
        requiredSpecialties: _getRequiredSpecialties(input.protocolType),
      ),
    );
    completedSteps.add('Staff notified');

    // Step 2: Prepare equipment (simulated)
    // In real implementation, this would integrate with equipment management
    completedSteps.add('Equipment prepared');

    // Step 3: Activate overhead announcement (simulated)
    // In real implementation, this would integrate with PA system
    completedSteps.add('Announcement activated');

    // Step 4: Log incident
    // In real implementation, this would create incident report
    completedSteps.add('Incident logged');

    // Generate protocol ID
    final protocolId =
        '${input.protocolType}-${initiatedAt.millisecondsSinceEpoch % 100000}';

    final elapsedSeconds = DateTime.now().difference(initiatedAt).inSeconds;

    return EmergencyProtocolResult(
      protocolType: input.protocolType,
      protocolId: protocolId,
      initiatedAt: initiatedAt,
      steps: steps,
      completedSteps: completedSteps,
      staffNotification: staffNotification,
      status:
          completedSteps.length == steps.length ? 'COMPLETED' : 'IN_PROGRESS',
      elapsedSeconds: elapsedSeconds,
    );
  }

  List<String> _getProtocolSteps(String protocolType) {
    switch (protocolType) {
      case 'CODE_BLUE':
        return [
          'Notify emergency team',
          'Bring crash cart',
          'Start CPR if needed',
          'Prepare defibrillator',
          'Establish IV access',
          'Administer medications per ACLS',
        ];
      case 'CODE_RED':
        return [
          'Activate fire alarm',
          'Notify security',
          'Evacuate patients',
          'Close fire doors',
          'Account for all personnel',
        ];
      case 'TRAUMA':
        return [
          'Notify trauma team',
          'Prepare trauma bay',
          'Alert blood bank',
          'Ready OR',
          'Contact radiology',
        ];
      case 'STROKE':
        return [
          'Notify stroke team',
          'Obtain CT scan',
          'Check tPA eligibility',
          'Prepare medications',
          'Contact neurology',
        ];
      case 'MI':
        return [
          'Obtain 12-lead ECG',
          'Notify cardiology',
          'Administer aspirin',
          'Prepare cath lab',
          'Monitor vital signs',
        ];
      default:
        return [
          'Assess situation',
          'Notify appropriate team',
          'Provide immediate care',
          'Document actions',
        ];
    }
  }

  String _getProtocolUrgency(String protocolType) {
    switch (protocolType) {
      case 'CODE_BLUE':
      case 'CODE_RED':
      case 'TRAUMA':
        return 'CRITICAL';
      case 'STROKE':
      case 'MI':
      case 'SEPSIS':
        return 'HIGH';
      default:
        return 'MEDIUM';
    }
  }

  List<String> _getRequiredSpecialties(String protocolType) {
    switch (protocolType) {
      case 'CODE_BLUE':
        return ['Emergency Medicine', 'Cardiology', 'Anesthesiology'];
      case 'TRAUMA':
        return ['Emergency Medicine', 'Surgery', 'Orthopedics'];
      case 'STROKE':
        return ['Neurology', 'Emergency Medicine', 'Radiology'];
      case 'MI':
        return ['Cardiology', 'Emergency Medicine'];
      case 'SEPSIS':
        return ['Internal Medicine', 'Infectious Disease'];
      default:
        return ['Emergency Medicine'];
    }
  }

  @override
  Future<void> onSuccess(EmergencyProtocolResult result,
      InitiateEmergencyProtocolInput input) async {
    print('🚨 Emergency protocol ${input.protocolType} initiated');
    print('   Protocol ID: ${result.protocolId}');
    print(
        '   Completed: ${result.completedSteps.length}/${result.steps.length} steps');
  }
}
