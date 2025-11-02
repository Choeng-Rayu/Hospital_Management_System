import '../../domain/entities/equipment.dart';
import '../../domain/entities/enums/equipment_status.dart';

/// Data Transfer Object for Equipment entity
/// Handles JSON serialization and conversion to/from domain entity
class EquipmentModel {
  final String equipmentId;
  final String name;
  final String type;
  final String serialNumber;
  final String status; // Serialized enum
  final String lastServiceDate; // ISO 8601 string
  final String nextServiceDate; // ISO 8601 string

  EquipmentModel({
    required this.equipmentId,
    required this.name,
    required this.type,
    required this.serialNumber,
    required this.status,
    required this.lastServiceDate,
    required this.nextServiceDate,
  });

  /// Convert from domain entity to model
  factory EquipmentModel.fromEntity(Equipment equipment) {
    return EquipmentModel(
      equipmentId: equipment.equipmentId,
      name: equipment.name,
      type: equipment.type,
      serialNumber: equipment.serialNumber,
      status: equipment.status.toString(),
      lastServiceDate: equipment.lastServiceDate.toIso8601String(),
      nextServiceDate: equipment.nextServiceDate.toIso8601String(),
    );
  }

  /// Convert to domain entity
  Equipment toEntity() {
    // Parse enum
    EquipmentStatus statusEnum = EquipmentStatus.values.firstWhere(
      (e) => e.toString() == status,
      orElse: () => EquipmentStatus.OPERATIONAL,
    );

    return Equipment(
      equipmentId: equipmentId,
      name: name,
      type: type,
      serialNumber: serialNumber,
      status: statusEnum,
      lastServiceDate: DateTime.parse(lastServiceDate),
      nextServiceDate: DateTime.parse(nextServiceDate),
    );
  }

  /// Convert from JSON
  factory EquipmentModel.fromJson(Map<String, dynamic> json) {
    return EquipmentModel(
      equipmentId: json['equipmentId'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      serialNumber: json['serialNumber'] as String,
      status: json['status'] as String,
      lastServiceDate: json['lastServiceDate'] as String,
      nextServiceDate: json['nextServiceDate'] as String,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'equipmentId': equipmentId,
      'name': name,
      'type': type,
      'serialNumber': serialNumber,
      'status': status,
      'lastServiceDate': lastServiceDate,
      'nextServiceDate': nextServiceDate,
    };
  }

  /// Create a copy with updated fields
  EquipmentModel copyWith({
    String? equipmentId,
    String? name,
    String? type,
    String? serialNumber,
    String? status,
    String? lastServiceDate,
    String? nextServiceDate,
  }) {
    return EquipmentModel(
      equipmentId: equipmentId ?? this.equipmentId,
      name: name ?? this.name,
      type: type ?? this.type,
      serialNumber: serialNumber ?? this.serialNumber,
      status: status ?? this.status,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
      nextServiceDate: nextServiceDate ?? this.nextServiceDate,
    );
  }
}
