import '../../domain/entities/doctor.dart';
import '../../domain/entities/patient.dart';

/// Data Transfer Object for Doctor entity
/// Handles JSON serialization and conversion to/from domain entity
class DoctorModel {
  final String staffID;
  final String name;
  final String dateOfBirth;
  final String address;
  final String tel;
  final String hireDate; // ISO 8601 string
  final double salary;
  final Map<String, Map<String, String>>
      schedule; // date -> {start: ISO time, end: ISO time}
  final String specialization;
  final List<String> certifications;
  final List<String> currentPatientIds;

  DoctorModel({
    required this.staffID,
    required this.name,
    required this.dateOfBirth,
    required this.address,
    required this.tel,
    required this.hireDate,
    required this.salary,
    required this.schedule,
    required this.specialization,
    required this.certifications,
    required this.currentPatientIds,
  });

  /// Convert from domain entity to model
  factory DoctorModel.fromEntity(Doctor doctor, {List<Patient>? patients}) {
    // Use the working hours from the doctor entity as the schedule in JSON
    // The doctor.schedule field contains meetings, not working hours
    final scheduleJson =
        Map<String, Map<String, String>>.from(doctor.workingHours);

    return DoctorModel(
      staffID: doctor.staffID,
      name: doctor.name,
      dateOfBirth: doctor.dateOfBirth,
      address: doctor.address,
      tel: doctor.tel,
      hireDate: doctor.hireDate.toIso8601String(),
      salary: doctor.salary,
      schedule: scheduleJson, // Working hours from domain entity
      specialization: doctor.specialization,
      certifications: doctor.certifications.toList(),
      currentPatientIds: patients?.map((p) => p.patientID).toList() ??
          doctor.currentPatients.map((p) => p.patientID).toList(),
    );
  }

  /// Convert to domain entity
  /// Note: Requires fetching related entities (patients)
  Doctor toEntity({List<Patient>? currentPatients}) {
    // The schedule field from JSON represents working hours, not meetings
    // We keep meetings schedule empty initially and pass working hours separately
    final meetingSchedule = <String, List<DateTime>>{};

    return Doctor(
      name: name,
      dateOfBirth: dateOfBirth,
      address: address,
      tel: tel,
      staffID: staffID,
      hireDate: DateTime.parse(hireDate),
      salary: salary,
      schedule: meetingSchedule, // Empty initially - only for meetings
      specialization: specialization,
      certifications: certifications,
      currentPatients: currentPatients ?? [],
      workingHours: schedule, // Pass working hours from JSON
    );
  }

  /// Convert from JSON
  factory DoctorModel.fromJson(Map<String, dynamic> json) {
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

    return DoctorModel(
      staffID: json['staffID'] as String,
      name: json['name'] as String,
      dateOfBirth: json['dateOfBirth'] as String,
      address: json['address'] as String,
      tel: json['tel'] as String,
      hireDate: json['hireDate'] as String,
      salary: (json['salary'] as num).toDouble(),
      schedule: schedule,
      specialization: json['specialization'] as String,
      certifications: List<String>.from(json['certifications'] ?? []),
      currentPatientIds: List<String>.from(json['currentPatientIds'] ?? []),
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
      'specialization': specialization,
      'certifications': certifications,
      'currentPatientIds': currentPatientIds,
    };
  }

  /// Create a copy with updated fields
  DoctorModel copyWith({
    String? staffID,
    String? name,
    String? dateOfBirth,
    String? address,
    String? tel,
    String? hireDate,
    double? salary,
    Map<String, Map<String, String>>? schedule,
    String? specialization,
    List<String>? certifications,
    List<String>? currentPatientIds,
  }) {
    return DoctorModel(
      staffID: staffID ?? this.staffID,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      tel: tel ?? this.tel,
      hireDate: hireDate ?? this.hireDate,
      salary: salary ?? this.salary,
      schedule: schedule ?? this.schedule,
      specialization: specialization ?? this.specialization,
      certifications: certifications ?? this.certifications,
      currentPatientIds: currentPatientIds ?? this.currentPatientIds,
    );
  }
}
