import '../../entities/patient.dart';
import '../../entities/room.dart';
import '../../entities/enums/emergency_level.dart';
import '../../repositories/patient_repository.dart';
import '../../repositories/room_repository.dart';
import '../base/use_case.dart';

import 'find_emergency_bed.dart';

/// Input for emergency patient admission
class AdmitEmergencyPatientInput {
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String gender;
  final String phone;
  final String emergencyContact;
  final EmergencyLevel emergencyLevel;
  final String chiefComplaint;
  final List<String> symptoms;
  final String? allergies;
  final String? currentMedications;
  final bool requiresICU;
  final String? triageNotes;

  AdmitEmergencyPatientInput({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.phone,
    required this.emergencyContact,
    required this.emergencyLevel,
    required this.chiefComplaint,
    required this.symptoms,
    this.allergies,
    this.currentMedications,
    this.requiresICU = false,
    this.triageNotes,
  });
}

/// Result of emergency admission
class EmergencyAdmissionResult {
  final Patient patient;
  final EmergencyBedAssignment bedAssignment;
  final DateTime admissionTime;
  final String trackingNumber;
  final int priorityScore; // 1-100, higher = more critical

  EmergencyAdmissionResult({
    required this.patient,
    required this.bedAssignment,
    required this.admissionTime,
    required this.trackingNumber,
    required this.priorityScore,
  });

  @override
  String toString() {
    return '''
🚨 EMERGENCY ADMISSION
━━━━━━━━━━━━━━━━━━━━━
Patient: ${patient.name}
Tracking: $trackingNumber
Priority: $priorityScore/100
Bed: ${bedAssignment.roomNumber} - ${bedAssignment.bedNumber}
Time: ${admissionTime.toString().split('.')[0]}
''';
  }
}

/// Use case for fast-track emergency patient admission
/// Bypasses standard admission workflow for critical cases
class AdmitEmergencyPatient
    extends UseCase<AdmitEmergencyPatientInput, EmergencyAdmissionResult> {
  final PatientRepository patientRepository;
  final RoomRepository roomRepository;

  AdmitEmergencyPatient({
    required this.patientRepository,
    required this.roomRepository,
  });

  @override
  Future<bool> validate(AdmitEmergencyPatientInput input) async {
    // Validate age is reasonable
    final age = DateTime.now().difference(input.dateOfBirth).inDays ~/ 365;
    if (age < 0 || age > 120) {
      throw UseCaseValidationException('Invalid date of birth');
    }

    // Validate required emergency information
    if (input.symptoms.isEmpty) {
      throw UseCaseValidationException('At least one symptom is required');
    }

    if (input.chiefComplaint.trim().isEmpty) {
      throw UseCaseValidationException('Chief complaint is required');
    }

    // Validate emergency contact
    if (input.emergencyContact.trim().isEmpty) {
      throw UseCaseValidationException('Emergency contact is required');
    }
    return true;
  }

  @override
  Future<EmergencyAdmissionResult> execute(
      AdmitEmergencyPatientInput input) async {
    final admissionTime = DateTime.now();

    // Calculate priority score based on emergency level
    final priorityScore = _calculatePriorityScore(input.emergencyLevel);

    // Find appropriate bed
    final findBedUseCase = FindEmergencyBed(roomRepository: roomRepository);
    final bedAssignment = await findBedUseCase.call(FindEmergencyBedInput(
      emergencyLevel: input.emergencyLevel,
      requiresICU: input.requiresICU,
      requiredFeatures: _getRequiredFeatures(input),
    ));

    // Create patient record with emergency flag
    final patient = Patient(
      patientID: 'PAT-EMG-${admissionTime.millisecondsSinceEpoch}',
      name: '${input.firstName} ${input.lastName}',
      dateOfBirth: input.dateOfBirth.toString().split(' ')[0],
      tel: input.phone,
      address: 'EMERGENCY - TO BE UPDATED',
      bloodType: 'Unknown',
      allergies: input.allergies != null ? [input.allergies!] : [],
      medicalRecords: [
        '🚨 EMERGENCY ADMISSION',
        'Chief Complaint: ${input.chiefComplaint}',
        'Symptoms: ${input.symptoms.join(", ")}',
        'Emergency Level: ${input.emergencyLevel}',
        if (input.triageNotes != null) 'Triage Notes: ${input.triageNotes}',
        if (input.currentMedications != null)
          'Current Medications: ${input.currentMedications}',
      ],
      emergencyContact: input.emergencyContact,
    );

    // Save patient
    await patientRepository.savePatient(patient);

    // Assign bed to patient
    final room = await roomRepository.getRoomById(bedAssignment.roomId);
    final updatedBeds = room.beds.map((bed) {
      if (bed.bedNumber == bedAssignment.bedNumber) {
        bed.assignPatient(patient);
      }
      return bed;
    }).toList();

    // Create new room instance
    final updatedRoom = Room(
      roomId: room.roomId,
      number: room.number,
      roomType: room.roomType,
      status: room.status,
      equipment: room.equipment.toList(),
      beds: updatedBeds,
    );
    await roomRepository.updateRoom(updatedRoom);

    // Generate tracking number
    final trackingNumber =
        'EMG-${input.emergencyLevel.toString().split('.').last.substring(0, 3)}-${admissionTime.millisecondsSinceEpoch % 100000}';

    return EmergencyAdmissionResult(
      patient: patient,
      bedAssignment: bedAssignment,
      admissionTime: admissionTime,
      trackingNumber: trackingNumber,
      priorityScore: priorityScore,
    );
  }

  int _calculatePriorityScore(EmergencyLevel level) {
    switch (level) {
      case EmergencyLevel.CRITICAL:
        return 95;
      case EmergencyLevel.HIGH:
        return 80;
      case EmergencyLevel.MEDIUM:
        return 60;
      case EmergencyLevel.LOW:
        return 40;
    }
  }

  List<String> _getRequiredFeatures(AdmitEmergencyPatientInput input) {
    final features = <String>[];

    if (input.requiresICU) {
      features.addAll(['Ventilator', 'Cardiac Monitor', 'IV Pump']);
    }

    if (input.emergencyLevel == EmergencyLevel.CRITICAL) {
      features.addAll(['Defibrillator', 'Oxygen Supply']);
    }

    return features;
  }

  @override
  @override
  Future<void> onSuccess(
      EmergencyAdmissionResult result, AdmitEmergencyPatientInput input) async {
    print('🚨 Emergency patient admitted: ${result.trackingNumber}');
    print('   Priority: ${result.priorityScore}/100');
    print('   Bed: ${result.bedAssignment.roomNumber}');
  }
}
