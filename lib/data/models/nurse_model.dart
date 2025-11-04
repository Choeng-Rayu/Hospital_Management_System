import '../../domain/entities/nurse.dart';
import '../../domain/entities/patient.dart';
import '../../domain/entities/room.dart';

/// Data Transfer Object for Nurse entity
/// Handles JSON serialization and conversion to/from domain entity
class NurseModel {
  final String staffID;
  final String name;
  final String dateOfBirth;
  final String address;
  final String tel;
  final String hireDate; // ISO 8601 string
  final double salary;
  final Map<String, Map<String, String>>
      schedule; // date -> {start: ISO time, end: ISO time}
  final List<String> assignedRoomIds;
  final List<String> assignedPatientIds;

  NurseModel({
    required this.staffID,
    required this.name,
    required this.dateOfBirth,
    required this.address,
    required this.tel,
    required this.hireDate,
    required this.salary,
    required this.schedule,
    required this.assignedRoomIds,
    required this.assignedPatientIds,
  });

  /// Convert from domain entity to model
  factory NurseModel.fromEntity(Nurse nurse,
      {List<Room>? rooms, List<Patient>? patients}) {
    // Convert schedule from Map<String, List<DateTime>> to Map<String, Map<String, String>>
    final scheduleJson = <String, Map<String, String>>{};
    nurse.schedule.forEach((date, times) {
      if (times.isNotEmpty) {
        // Assume first time is start, last time is end (or same if only one)
        scheduleJson[date] = {
          'start': times.first.toIso8601String(),
          'end':
              (times.length > 1 ? times.last : times.first).toIso8601String(),
        };
      }
    });

    return NurseModel(
      staffID: nurse.staffID,
      name: nurse.name,
      dateOfBirth: nurse.dateOfBirth,
      address: nurse.address,
      tel: nurse.tel,
      hireDate: nurse.hireDate.toIso8601String(),
      salary: nurse.salary,
      schedule: scheduleJson,
      assignedRoomIds: rooms?.map((r) => r.number).toList() ??
          nurse.assignedRooms.map((r) => r.number).toList(),
      assignedPatientIds: patients?.map((p) => p.patientID).toList() ??
          nurse.assignedPatients.map((p) => p.patientID).toList(),
    );
  }

  /// Convert to domain entity
  /// Note: Requires fetching related entities (rooms and patients)
  Nurse toEntity({List<Room>? assignedRooms, List<Patient>? assignedPatients}) {
    // Convert schedule from Map<String, Map<String, String>> to Map<String, List<DateTime>>
    final scheduleEntity = <String, List<DateTime>>{};
    schedule.forEach((date, timeMap) {
      final startTime = DateTime.parse(timeMap['start']!);
      final endTime = DateTime.parse(timeMap['end']!);
      scheduleEntity[date] = [startTime, endTime];
    });

    return Nurse(
      name: name,
      dateOfBirth: dateOfBirth,
      address: address,
      tel: tel,
      staffID: staffID,
      hireDate: DateTime.parse(hireDate),
      salary: salary,
      schedule: scheduleEntity,
      assignedRooms: assignedRooms ?? [],
      assignedPatients: assignedPatients ?? [],
    );
  }

  /// Convert from JSON
  factory NurseModel.fromJson(Map<String, dynamic> json) {
    // Parse schedule - handle new {start, end} format
    final scheduleJson = json['schedule'] as Map<String, dynamic>? ?? {};
    final schedule = <String, Map<String, String>>{};
    scheduleJson.forEach((date, timeObj) {
      if (timeObj is Map<String, dynamic>) {
        schedule[date] = {
          'start': timeObj['start'] as String,
          'end': timeObj['end'] as String,
        };
      }
    });

    return NurseModel(
      staffID: json['staffID'] as String,
      name: json['name'] as String,
      dateOfBirth: json['dateOfBirth'] as String,
      address: json['address'] as String,
      tel: json['tel'] as String,
      hireDate: json['hireDate'] as String,
      salary: (json['salary'] as num).toDouble(),
      schedule: schedule,
      assignedRoomIds: List<String>.from(json['assignedRoomIds'] ?? []),
      assignedPatientIds: List<String>.from(json['assignedPatientIds'] ?? []),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'staffID': staffID,
      'name': name,
      'dateOfBirth': dateOfBirth,
      'address': address,
      'tel': tel,
      'hireDate': hireDate,
      'salary': salary,
      'schedule': schedule,
      'assignedRoomIds': assignedRoomIds,
      'assignedPatientIds': assignedPatientIds,
    };
  }

  /// Create a copy with updated fields
  NurseModel copyWith({
    String? staffID,
    String? name,
    String? dateOfBirth,
    String? address,
    String? tel,
    String? hireDate,
    double? salary,
    Map<String, Map<String, String>>? schedule,
    List<String>? assignedRoomIds,
    List<String>? assignedPatientIds,
  }) {
    return NurseModel(
      staffID: staffID ?? this.staffID,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      tel: tel ?? this.tel,
      hireDate: hireDate ?? this.hireDate,
      salary: salary ?? this.salary,
      schedule: schedule ?? this.schedule,
      assignedRoomIds: assignedRoomIds ?? this.assignedRoomIds,
      assignedPatientIds: assignedPatientIds ?? this.assignedPatientIds,
    );
  }
}
