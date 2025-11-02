import '../../domain/entities/patient.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/entities/nurse.dart';
import '../../domain/entities/prescription.dart';
import '../../domain/entities/room.dart';
import '../../domain/entities/bed.dart';

/// Data Transfer Object for Patient entity
/// Handles JSON serialization and conversion to/from domain entity
class PatientModel {
  final String patientID;
  final String name;
  final String dateOfBirth;
  final String address;
  final String tel;
  final String bloodType;
  final List<String> medicalRecords;
  final List<String> allergies;
  final String emergencyContact;
  final List<String> assignedDoctorIds;
  final List<String> assignedNurseIds;
  final List<String> prescriptionIds;
  final String? currentRoomId;
  final String? currentBedId;

  // Meeting fields
  final bool hasNextMeeting;
  final String? nextMeetingDate; // ISO 8601 string
  final String? nextMeetingDoctorId;

  PatientModel({
    required this.patientID,
    required this.name,
    required this.dateOfBirth,
    required this.address,
    required this.tel,
    required this.bloodType,
    required this.medicalRecords,
    required this.allergies,
    required this.emergencyContact,
    required this.assignedDoctorIds,
    required this.assignedNurseIds,
    required this.prescriptionIds,
    this.currentRoomId,
    this.currentBedId,
    required this.hasNextMeeting,
    this.nextMeetingDate,
    this.nextMeetingDoctorId,
  });

  /// Convert from domain entity to model
  factory PatientModel.fromEntity(
    Patient patient, {
    Room? currentRoom,
    Bed? currentBed,
    List<Prescription>? prescriptions,
  }) {
    return PatientModel(
      patientID: patient.patientID,
      name: patient.name,
      dateOfBirth: patient.dateOfBirth,
      address: patient.address,
      tel: patient.tel,
      bloodType: patient.bloodType,
      medicalRecords: patient.medicalRecords.toList(),
      allergies: patient.allergies.toList(),
      emergencyContact: patient.emergencyContact,
      assignedDoctorIds: patient.assignedDoctors.map((d) => d.staffID).toList(),
      assignedNurseIds: patient.assignedNurses.map((n) => n.staffID).toList(),
      prescriptionIds: prescriptions?.map((p) => p.id).toList() ??
          patient.prescriptions.map((p) => p.id).toList(),
      currentRoomId: currentRoom?.number ?? patient.currentRoom?.number,
      currentBedId: currentBed?.bedNumber ?? patient.currentBed?.bedNumber,
      hasNextMeeting: patient.hasNextMeeting,
      nextMeetingDate: patient.nextMeetingDate?.toIso8601String(),
      nextMeetingDoctorId: patient.nextMeetingDoctor?.staffID,
    );
  }

  /// Convert to domain entity
  /// Note: Requires fetching related entities (doctors, nurses, etc.)
  Patient toEntity({
    required List<Doctor> assignedDoctors,
    List<Nurse>? assignedNurses,
    List<Prescription>? prescriptions,
    Room? currentRoom,
    Bed? currentBed,
  }) {
    // Find the meeting doctor if there's a meeting scheduled
    Doctor? meetingDoctor;
    if (hasNextMeeting && nextMeetingDoctorId != null) {
      try {
        meetingDoctor = assignedDoctors.firstWhere(
          (d) => d.staffID == nextMeetingDoctorId,
        );
      } catch (e) {
        // Doctor not found in assigned doctors
        meetingDoctor = null;
      }
    }

    return Patient(
      name: name,
      dateOfBirth: dateOfBirth,
      address: address,
      tel: tel,
      patientID: patientID,
      bloodType: bloodType,
      medicalRecords: medicalRecords,
      allergies: allergies,
      emergencyContact: emergencyContact,
      assignedDoctors: assignedDoctors,
      assignedNurses: assignedNurses ?? [],
      prescriptions: prescriptions ?? [],
      currentRoom: currentRoom,
      currentBed: currentBed,
      hasNextMeeting: hasNextMeeting,
      nextMeetingDate:
          nextMeetingDate != null ? DateTime.parse(nextMeetingDate!) : null,
      nextMeetingDoctor: meetingDoctor,
    );
  }

  /// Convert from JSON
  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      patientID: json['patientID'] as String,
      name: json['name'] as String,
      dateOfBirth: json['dateOfBirth'] as String,
      address: json['address'] as String,
      tel: json['tel'] as String,
      bloodType: json['bloodType'] as String,
      medicalRecords: List<String>.from(json['medicalRecords'] ?? []),
      allergies: List<String>.from(json['allergies'] ?? []),
      emergencyContact: json['emergencyContact'] as String,
      assignedDoctorIds: List<String>.from(json['assignedDoctorIds'] ?? []),
      assignedNurseIds: List<String>.from(json['assignedNurseIds'] ?? []),
      prescriptionIds: List<String>.from(json['prescriptionIds'] ?? []),
      currentRoomId: json['currentRoomId'] as String?,
      currentBedId: json['currentBedId'] as String?,
      hasNextMeeting: json['hasNextMeeting'] as bool? ?? false,
      nextMeetingDate: json['nextMeetingDate'] as String?,
      nextMeetingDoctorId: json['nextMeetingDoctorId'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'patientID': patientID,
      'name': name,
      'dateOfBirth': dateOfBirth,
      'address': address,
      'tel': tel,
      'bloodType': bloodType,
      'medicalRecords': medicalRecords,
      'allergies': allergies,
      'emergencyContact': emergencyContact,
      'assignedDoctorIds': assignedDoctorIds,
      'assignedNurseIds': assignedNurseIds,
      'prescriptionIds': prescriptionIds,
      'currentRoomId': currentRoomId,
      'currentBedId': currentBedId,
      'hasNextMeeting': hasNextMeeting,
      'nextMeetingDate': nextMeetingDate,
      'nextMeetingDoctorId': nextMeetingDoctorId,
    };
  }

  /// Create a copy with updated fields
  PatientModel copyWith({
    String? patientID,
    String? name,
    String? dateOfBirth,
    String? address,
    String? tel,
    String? bloodType,
    List<String>? medicalRecords,
    List<String>? allergies,
    String? emergencyContact,
    List<String>? assignedDoctorIds,
    List<String>? assignedNurseIds,
    List<String>? prescriptionIds,
    String? currentRoomId,
    String? currentBedId,
    bool? hasNextMeeting,
    String? nextMeetingDate,
    String? nextMeetingDoctorId,
  }) {
    return PatientModel(
      patientID: patientID ?? this.patientID,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      tel: tel ?? this.tel,
      bloodType: bloodType ?? this.bloodType,
      medicalRecords: medicalRecords ?? this.medicalRecords,
      allergies: allergies ?? this.allergies,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      assignedDoctorIds: assignedDoctorIds ?? this.assignedDoctorIds,
      assignedNurseIds: assignedNurseIds ?? this.assignedNurseIds,
      prescriptionIds: prescriptionIds ?? this.prescriptionIds,
      currentRoomId: currentRoomId ?? this.currentRoomId,
      currentBedId: currentBedId ?? this.currentBedId,
      hasNextMeeting: hasNextMeeting ?? this.hasNextMeeting,
      nextMeetingDate: nextMeetingDate ?? this.nextMeetingDate,
      nextMeetingDoctorId: nextMeetingDoctorId ?? this.nextMeetingDoctorId,
    );
  }
}
