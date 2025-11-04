import '../../domain/entities/appointment.dart';
import '../../domain/entities/enums/appointment_status.dart';

/// Data Transfer Object for Appointment entity
/// Handles JSON serialization and conversion to/from domain entity
class AppointmentModel {
  final String id;
  final String patientId; // Reference to patient
  final String doctorId; // Reference to doctor
  final String? roomId; // Optional reference to room
  final String dateTime; // ISO 8601 string
  final int duration; // in minutes
  final String reason;
  final String status; // Serialized AppointmentStatus enum
  final String? notes;

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    this.roomId,
    required this.dateTime,
    required this.duration,
    required this.reason,
    required this.status,
    this.notes,
  });

  /// Convert from domain entity to model
  factory AppointmentModel.fromEntity(Appointment appointment) {
    return AppointmentModel(
      id: appointment.id,
      patientId: appointment.patient.patientID,
      doctorId: appointment.doctor.staffID,
      roomId: appointment.room?.number,
      dateTime: appointment.dateTime.toIso8601String(),
      duration: appointment.duration,
      reason: appointment.reason,
      status: appointment.status.toString(), // Convert enum to string
      notes: appointment.notes,
    );
  }

  /// Convert to domain entity
  /// Note: Requires fetching related entities (patient, doctor, optionally room)
  /// This will be done by the repository
  Appointment toEntity({
    required dynamic patient,
    required dynamic doctor,
    dynamic room,
  }) {
    // Parse status string back to enum
    AppointmentStatus statusEnum;
    if (status.contains('SCHEDULE')) {
      statusEnum = AppointmentStatus.SCHEDULE;
    } else if (status.contains('IN_PROGRESS')) {
      statusEnum = AppointmentStatus.IN_PROGRESS;
    } else if (status.contains('COMPLETED')) {
      statusEnum = AppointmentStatus.COMPLETED;
    } else if (status.contains('CANCELLED')) {
      statusEnum = AppointmentStatus.CANCELLED;
    } else if (status.contains('NO_SHOW')) {
      statusEnum = AppointmentStatus.NO_SHOW;
    } else {
      statusEnum = AppointmentStatus.SCHEDULE; // Default
    }

    return Appointment(
      id: id,
      patient: patient,
      doctor: doctor,
      room: room,
      dateTime: DateTime.parse(dateTime),
      duration: duration,
      reason: reason,
      status: statusEnum,
      notes: notes,
    );
  }

  /// Convert from JSON
  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      doctorId: json['doctorId'] as String,
      roomId: json['roomId'] as String?,
      dateTime: json['dateTime'] as String,
      duration: json['duration'] as int,
      reason: json['reason'] as String,
      status: json['status'] as String,
      notes: json['notes'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'roomId': roomId,
      'dateTime': dateTime,
      'duration': duration,
      'reason': reason,
      'status': status,
      'notes': notes,
    };
  }

  /// Create a copy with updated fields
  AppointmentModel copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    String? roomId,
    String? dateTime,
    int? duration,
    String? reason,
    String? status,
    String? notes,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      roomId: roomId ?? this.roomId,
      dateTime: dateTime ?? this.dateTime,
      duration: duration ?? this.duration,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}
