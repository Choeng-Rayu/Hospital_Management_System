import '../../domain/entities/room.dart';
import '../../domain/entities/bed.dart';
import '../../domain/entities/equipment.dart';
import '../../domain/entities/enums/room_type.dart';
import '../../domain/entities/enums/room_status.dart';

/// Data Transfer Object for Room entity
/// Handles JSON serialization and conversion to/from domain entity
class RoomModel {
  final String roomId;
  final String number;
  final String roomType; // Serialized enum
  final String status; // Serialized enum
  final List<String> equipmentIds; // References to equipment IDs
  final List<String> bedIds; // References to bed numbers

  RoomModel({
    required this.roomId,
    required this.number,
    required this.roomType,
    required this.status,
    required this.equipmentIds,
    required this.bedIds,
  });

  /// Convert from domain entity to model
  factory RoomModel.fromEntity(Room room,
      {List<Equipment>? equipment, List<Bed>? beds}) {
    return RoomModel(
      roomId: room.roomId,
      number: room.number,
      roomType: room.roomType.toString(),
      status: room.status.toString(),
      equipmentIds: equipment?.map((e) => e.equipmentId).toList() ??
          room.equipment.map((e) => e.equipmentId).toList(),
      bedIds: beds?.map((b) => b.bedNumber).toList() ??
          room.beds.map((b) => b.bedNumber).toList(),
    );
  }

  /// Convert to domain entity
  /// Note: Requires fetching related entities (equipment, beds)
  Room toEntity({List<Equipment>? equipment, List<Bed>? beds}) {
    // Parse enums
    RoomType typeEnum = RoomType.values.firstWhere(
      (e) => e.toString() == roomType,
      orElse: () => RoomType.GENERAL_WARD,
    );

    RoomStatus statusEnum = RoomStatus.values.firstWhere(
      (e) => e.toString() == status,
      orElse: () => RoomStatus.AVAILABLE,
    );

    return Room(
      roomId: roomId,
      number: number,
      roomType: typeEnum,
      status: statusEnum,
      equipment: equipment ?? [],
      beds: beds ?? [],
    );
  }

  /// Convert from JSON
  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      roomId: json['roomId'] as String,
      number: json['number'] as String,
      roomType: json['roomType'] as String,
      status: json['status'] as String,
      equipmentIds: List<String>.from(json['equipmentIds'] ?? []),
      bedIds: List<String>.from(json['bedIds'] ?? []),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'number': number,
      'roomType': roomType,
      'status': status,
      'equipmentIds': equipmentIds,
      'bedIds': bedIds,
    };
  }

  /// Create a copy with updated fields
  RoomModel copyWith({
    String? roomId,
    String? number,
    String? roomType,
    String? status,
    List<String>? equipmentIds,
    List<String>? bedIds,
  }) {
    return RoomModel(
      roomId: roomId ?? this.roomId,
      number: number ?? this.number,
      roomType: roomType ?? this.roomType,
      status: status ?? this.status,
      equipmentIds: equipmentIds ?? this.equipmentIds,
      bedIds: bedIds ?? this.bedIds,
    );
  }
}
