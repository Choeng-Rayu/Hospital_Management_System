import '../../domain/entities/bed.dart';
import '../../domain/entities/enums/bed_type.dart';

/// Data Transfer Object for Bed entity
/// Handles JSON serialization and conversion to/from domain entity
class BedModel {
  final String bedNumber;
  final String bedType; // Serialized enum
  final bool isOccupied;
  final String? currentPatientId; // Nullable reference to patient
  final List<String> features;

  BedModel({
    required this.bedNumber,
    required this.bedType,
    required this.isOccupied,
    this.currentPatientId,
    required this.features,
  });

  /// Convert from domain entity to model
  factory BedModel.fromEntity(Bed bed) {
    return BedModel(
      bedNumber: bed.bedNumber,
      bedType: bed.bedType.toString(),
      isOccupied: bed.isOccupied,
      currentPatientId: bed.currentPatient?.patientID,
      features: bed.features.toList(),
    );
  }

  /// Convert to domain entity
  /// Note: currentPatient must be resolved separately
  Bed toEntity() {
    // Parse enum
    BedType typeEnum = BedType.values.firstWhere(
      (e) => e.toString() == bedType,
      orElse: () => BedType.STANDARD,
    );

    return Bed(
      bedNumber: bedNumber,
      bedType: typeEnum,
      isOccupied: isOccupied,
      patient: null, // Will be set by repository
      features: features,
    );
  }

  /// Convert from JSON
  factory BedModel.fromJson(Map<String, dynamic> json) {
    return BedModel(
      bedNumber: json['bedNumber'] as String,
      bedType: json['bedType'] as String,
      isOccupied: json['isOccupied'] as bool,
      currentPatientId: json['currentPatientId'] as String?,
      features: List<String>.from(json['features'] ?? []),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'bedNumber': bedNumber,
      'bedType': bedType,
      'isOccupied': isOccupied,
      'currentPatientId': currentPatientId,
      'features': features,
    };
  }

  /// Create a copy with updated fields
  BedModel copyWith({
    String? bedNumber,
    String? bedType,
    bool? isOccupied,
    String? currentPatientId,
    List<String>? features,
  }) {
    return BedModel(
      bedNumber: bedNumber ?? this.bedNumber,
      bedType: bedType ?? this.bedType,
      isOccupied: isOccupied ?? this.isOccupied,
      currentPatientId: currentPatientId ?? this.currentPatientId,
      features: features ?? this.features,
    );
  }
}
