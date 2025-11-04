import '../../domain/entities/prescription.dart';

/// Data Transfer Object for Prescription entity
/// Handles JSON serialization and conversion to/from domain entity
class PrescriptionModel {
  final String id;
  final String time; // ISO 8601 string
  final String patientId; // Reference to patient
  final String doctorId; // Reference to doctor
  final List<String> medicationIds; // References to medications
  final String instructions;

  PrescriptionModel({
    required this.id,
    required this.time,
    required this.patientId,
    required this.doctorId,
    required this.medicationIds,
    required this.instructions,
  });

  /// Convert from domain entity to model
  factory PrescriptionModel.fromEntity(Prescription prescription) {
    return PrescriptionModel(
      id: prescription.id,
      time: prescription.time.toIso8601String(),
      patientId: prescription.prescribedTo.patientID,
      doctorId: prescription.prescribedBy.staffID,
      medicationIds: prescription.medications.map((m) => m.id).toList(),
      instructions: prescription.instructions,
    );
  }

  /// Convert to domain entity
  /// Note: Requires fetching related entities (patient, doctor, medications)
  /// This will be done by the repository
  Prescription toEntity({
    required dynamic patient,
    required dynamic doctor,
    required List<dynamic> medications,
  }) {
    return Prescription(
      id: id,
      time: DateTime.parse(time),
      prescribedTo: patient,
      prescribedBy: doctor,
      medications: List.from(medications),
      instructions: instructions,
    );
  }

  /// Convert from JSON
  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionModel(
      id: json['id'] as String,
      time: json['time'] as String,
      patientId: json['patientId'] as String,
      doctorId: json['doctorId'] as String,
      medicationIds: List<String>.from(json['medicationIds'] ?? []),
      instructions: json['instructions'] as String,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time,
      'patientId': patientId,
      'doctorId': doctorId,
      'medicationIds': medicationIds,
      'instructions': instructions,
    };
  }

  /// Create a copy with updated fields
  PrescriptionModel copyWith({
    String? id,
    String? time,
    String? patientId,
    String? doctorId,
    List<String>? medicationIds,
    String? instructions,
  }) {
    return PrescriptionModel(
      id: id ?? this.id,
      time: time ?? this.time,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      medicationIds: medicationIds ?? this.medicationIds,
      instructions: instructions ?? this.instructions,
    );
  }
}
