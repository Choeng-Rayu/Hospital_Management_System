import 'patient.dart';
import 'room.dart';
import 'doctor.dart';
import 'enums/appointment_status.dart';

class Appointment {
  final String _id;
  final DateTime _dateTime;
  final int _duration; // in minutes
  final Patient _patient;
  final Doctor _doctor;
  final Room? _room;
  AppointmentStatus _status;
  final String _reason;
  final String? _notes;

  String get id => _id;
  DateTime get dateTime => _dateTime;
  int get duration => _duration;
  Patient get patient => _patient;
  Doctor get doctor => _doctor;
  Room? get room => _room;
  AppointmentStatus get status => _status;
  String get reason => _reason;
  String? get notes => _notes;

  Appointment({
    required String id,
    required DateTime dateTime,
    required int duration,
    required Patient patient,
    required Doctor doctor,
    Room? room,
    AppointmentStatus status = AppointmentStatus.SCHEDULE,
    required String reason,
    String? notes,
  })  : _id = id,
        _dateTime = dateTime,
        _duration = duration,
        _patient = patient,
        _doctor = doctor,
        _room = room,
        _status = status,
        _reason = reason,
        _notes = notes {
    _validateAppointment();
  }

  void _validateAppointment() {
    if (_id.trim().isEmpty) {
      throw ArgumentError('Appointment ID cannot be empty');
    }
    if (_duration <= 0) {
      throw ArgumentError('Duration must be positive');
    }
    if (_reason.trim().isEmpty) {
      throw ArgumentError('Reason cannot be empty');
    }
  }

  // Update appointment status
  void updateStatus(AppointmentStatus newStatus) {
    _status = newStatus;
  }

  // Check if appointment is upcoming
  bool get isUpcoming => _dateTime.isAfter(DateTime.now());

  // Get formatted appointment date
  String get formattedDate =>
      '${_dateTime.year}-${_dateTime.month.toString().padLeft(2, '0')}-${_dateTime.day.toString().padLeft(2, '0')}';

  // Get formatted appointment time
  String get formattedTime =>
      '${_dateTime.hour.toString().padLeft(2, '0')}:${_dateTime.minute.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Appointment &&
          runtimeType == other.runtimeType &&
          _id == other._id;

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() =>
      'Appointment(id: $_id, patient: ${_patient.name}, doctor: ${_doctor.name}, date: $formattedDate)';
}
