import '../../domain/entities/medication.dart';

/// Data Transfer Object for Medication entity
/// Handles JSON serialization and conversion to/from domain entity
class MedicationModel {
  final String id;
  final String name;
  final String dosage;
  final String manufacturer;
  final List<String> sideEffects;

  MedicationModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.manufacturer,
    required this.sideEffects,
  });

  /// Convert from domain entity to model
  factory MedicationModel.fromEntity(Medication medication) {
    return MedicationModel(
      id: medication.id,
      name: medication.name,
      dosage: medication.dosage,
      manufacturer: medication.manufacturer,
      sideEffects: medication.sideEffects.toList(),
    );
  }

  /// Convert to domain entity
  Medication toEntity() {
    return Medication(
      id: id,
      name: name,
      dosage: dosage,
      manufacturer: manufacturer,
      sideEffects: sideEffects,
    );
  }

  /// Convert from JSON
  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      manufacturer: json['manufacturer'] as String,
      sideEffects: List<String>.from(json['sideEffects'] ?? []),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'manufacturer': manufacturer,
      'sideEffects': sideEffects,
    };
  }

  /// Create a copy with updated fields
  MedicationModel copyWith({
    String? id,
    String? name,
    String? dosage,
    String? manufacturer,
    List<String>? sideEffects,
  }) {
    return MedicationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      manufacturer: manufacturer ?? this.manufacturer,
      sideEffects: sideEffects ?? this.sideEffects,
    );
  }
}
