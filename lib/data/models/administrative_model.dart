import '../../domain/entities/administrative.dart';

/// Data Transfer Object for Administrative entity
/// Handles JSON serialization and conversion to/from domain entity
class AdministrativeModel {
  final String staffID;
  final String name;
  final String dateOfBirth;
  final String address;
  final String tel;
  final String hireDate; // ISO 8601 string
  final double salary;
  final Map<String, Map<String, String>>
      schedule; // date -> {start: ISO time, end: ISO time}
  final String responsibility;

  AdministrativeModel({
    required this.staffID,
    required this.name,
    required this.dateOfBirth,
    required this.address,
    required this.tel,
    required this.hireDate,
    required this.salary,
    required this.schedule,
    required this.responsibility,
  });

  /// Convert from domain entity to model
  factory AdministrativeModel.fromEntity(Administrative administrative) {
    // Convert schedule from Map<String, List<DateTime>> to Map<String, Map<String, String>>
    final scheduleJson = <String, Map<String, String>>{};
    administrative.schedule.forEach((date, times) {
      if (times.isNotEmpty) {
        // Assume first time is start, last time is end (or same if only one)
        scheduleJson[date] = {
          'start': times.first.toIso8601String(),
          'end':
              (times.length > 1 ? times.last : times.first).toIso8601String(),
        };
      }
    });

    return AdministrativeModel(
      staffID: administrative.staffID,
      name: administrative.name,
      dateOfBirth: administrative.dateOfBirth,
      address: administrative.address,
      tel: administrative.tel,
      hireDate: administrative.hireDate.toIso8601String(),
      salary: administrative.salary,
      schedule: scheduleJson,
      responsibility: administrative.responsibility,
    );
  }

  /// Convert to domain entity
  Administrative toEntity() {
    // Convert schedule from Map<String, Map<String, String>> to Map<String, List<DateTime>>
    final scheduleEntity = <String, List<DateTime>>{};
    schedule.forEach((date, timeMap) {
      final startTime = DateTime.parse(timeMap['start']!);
      final endTime = DateTime.parse(timeMap['end']!);
      scheduleEntity[date] = [startTime, endTime];
    });

    return Administrative(
      name: name,
      dateOfBirth: dateOfBirth,
      address: address,
      tel: tel,
      staffID: staffID,
      hireDate: DateTime.parse(hireDate),
      salary: salary,
      schedule: scheduleEntity,
      responsibility: responsibility,
    );
  }

  /// Convert from JSON
  factory AdministrativeModel.fromJson(Map<String, dynamic> json) {
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

    return AdministrativeModel(
      staffID: json['staffID'] as String,
      name: json['name'] as String,
      dateOfBirth: json['dateOfBirth'] as String,
      address: json['address'] as String,
      tel: json['tel'] as String,
      hireDate: json['hireDate'] as String,
      salary: (json['salary'] as num).toDouble(),
      schedule: schedule,
      responsibility: json['responsibility'] as String,
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
      'responsibility': responsibility,
    };
  }

  /// Create a copy with updated fields
  AdministrativeModel copyWith({
    String? staffID,
    String? name,
    String? dateOfBirth,
    String? address,
    String? tel,
    String? hireDate,
    double? salary,
    Map<String, Map<String, String>>? schedule,
    String? responsibility,
  }) {
    return AdministrativeModel(
      staffID: staffID ?? this.staffID,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      tel: tel ?? this.tel,
      hireDate: hireDate ?? this.hireDate,
      salary: salary ?? this.salary,
      schedule: schedule ?? this.schedule,
      responsibility: responsibility ?? this.responsibility,
    );
  }
}
