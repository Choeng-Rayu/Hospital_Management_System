import 'dart:collection';
import 'person.dart';
import 'doctor.dart';
import 'nurse.dart';
import 'prescription.dart';
import 'room.dart';
import 'bed.dart';

class Patient extends Person {
  final String _patientID;
  final String _bloodType;
  final List<String> _medicalRecords;
  final List<String> _allergies;
  final String _emergencyContact;

  // Relationships
  final List<Doctor> _assignedDoctors;
  final List<Nurse> _assignedNurses;
  final List<Prescription> _prescriptions;
  Room? _currentRoom;
  Bed? _currentBed;

  // Next doctor meeting scheduling
  bool _hasNextMeeting;
  DateTime? _nextMeetingDate;
  Doctor? _nextMeetingDoctor;

  String get patientID => _patientID;
  String get bloodType => _bloodType;
  UnmodifiableListView<String> get medicalRecords =>
      UnmodifiableListView(_medicalRecords);
  UnmodifiableListView<String> get allergies =>
      UnmodifiableListView(_allergies);
  String get emergencyContact => _emergencyContact;

  // Relationship getters
  UnmodifiableListView<Doctor> get assignedDoctors =>
      UnmodifiableListView(_assignedDoctors);
  UnmodifiableListView<Nurse> get assignedNurses =>
      UnmodifiableListView(_assignedNurses);
  UnmodifiableListView<Prescription> get prescriptions =>
      UnmodifiableListView(_prescriptions);
  Room? get currentRoom => _currentRoom;
  Bed? get currentBed => _currentBed;

  // Next meeting getters
  bool get hasNextMeeting => _hasNextMeeting;
  DateTime? get nextMeetingDate => _nextMeetingDate;
  Doctor? get nextMeetingDoctor => _nextMeetingDoctor;

  Patient({
    required String name,
    required String dateOfBirth,
    required String address,
    required String tel,
    required String patientID,
    required String bloodType,
    required List<String> medicalRecords,
    required List<String> allergies,
    required String emergencyContact,
    List<Doctor>? assignedDoctors,
    List<Nurse>? assignedNurses,
    List<Prescription>? prescriptions,
    Room? currentRoom,
    Bed? currentBed,
    bool hasNextMeeting = false,
    DateTime? nextMeetingDate,
    Doctor? nextMeetingDoctor,
  })  : _patientID = patientID,
        _bloodType = bloodType,
        _medicalRecords = List.from(medicalRecords),
        _allergies = List.from(allergies),
        _emergencyContact = emergencyContact,
        _assignedDoctors = List.from(assignedDoctors ?? []),
        _assignedNurses = List.from(assignedNurses ?? []),
        _prescriptions = List.from(prescriptions ?? []),
        _currentRoom = currentRoom,
        _currentBed = currentBed,
        _hasNextMeeting = hasNextMeeting,
        _nextMeetingDate = nextMeetingDate,
        _nextMeetingDoctor = nextMeetingDoctor,
        super(
          name: name,
          dateOfBirth: dateOfBirth,
          address: address,
          tel: tel,
        ) {
    _validatePatient();
  }

  // Doctor relationship methods
  void assignDoctor(Doctor doctor) {
    if (!_assignedDoctors.contains(doctor)) {
      _assignedDoctors.add(doctor);
      doctor.addPatient(this);
    }
  }

  void removeDoctor(Doctor doctor) {
    if (_assignedDoctors.remove(doctor)) {
      doctor.removePatient(this);
    }
  }

  // Nurse relationship methods
  void assignNurse(Nurse nurse) {
    if (!_assignedNurses.contains(nurse)) {
      _assignedNurses.add(nurse);
      nurse.assignPatient(this);
    }
  }

  void removeNurse(Nurse nurse) {
    if (_assignedNurses.remove(nurse)) {
      nurse.removePatient(this);
    }
  }

  // Room and bed assignment methods
  void assignToBed(Room room, Bed bed) {
    if (bed.isAvailable && room.beds.contains(bed)) {
      // Discharge from current bed if any
      discharge();

      _currentRoom = room;
      _currentBed = bed;
      bed.assignPatient(this);
    } else {
      throw ArgumentError('Bed is not available or not in the specified room');
    }
  }

  void discharge() {
    if (_currentBed != null) {
      _currentBed!.removePatient();
      _currentBed = null;
      _currentRoom = null;
    }
  }

  // Prescription methods
  void addPrescription(Prescription prescription) {
    if (prescription.prescribedTo == this &&
        !_prescriptions.contains(prescription)) {
      _prescriptions.add(prescription);
    }
  }

  UnmodifiableListView<Prescription> get activePrescriptions =>
      UnmodifiableListView(_prescriptions.where((p) => p.isRecent));

  // Next meeting management methods
  /// Schedule the next meeting with a doctor
  void scheduleNextMeeting({
    required Doctor doctor,
    required DateTime meetingDate,
    int durationMinutes = 30, // Default meeting duration
  }) {
    if (meetingDate.isBefore(DateTime.now())) {
      throw ArgumentError('Meeting date must be in the future');
    }

    if (!_assignedDoctors.contains(doctor)) {
      throw ArgumentError(
        'Cannot schedule meeting with unassigned doctor. '
        'Doctor ${doctor.name} is not assigned to patient $_patientID',
      );
    }

    if (!_isDoctorAvailable(doctor, meetingDate, durationMinutes)) {
      throw ArgumentError(
        'Doctor ${doctor.name} is not available at ${_formatDateTime(meetingDate)}. '
        'Please choose a different time.',
      );
    }

    // If rescheduling, remove old meeting from doctor's schedule
    if (_hasNextMeeting &&
        _nextMeetingDoctor != null &&
        _nextMeetingDate != null) {
      _removeMeetingFromDoctorSchedule(_nextMeetingDoctor!, _nextMeetingDate!);
    }

    _hasNextMeeting = true;
    _nextMeetingDate = meetingDate;
    _nextMeetingDoctor = doctor;

    _addMeetingToDoctorSchedule(doctor, meetingDate);
  }

  /// Cancel the next scheduled meeting
  void cancelNextMeeting() {
    if (_hasNextMeeting &&
        _nextMeetingDoctor != null &&
        _nextMeetingDate != null) {
      _removeMeetingFromDoctorSchedule(_nextMeetingDoctor!, _nextMeetingDate!);
    }

    _hasNextMeeting = false;
    _nextMeetingDate = null;
    _nextMeetingDoctor = null;
  }

  /// Reschedule the next meeting to a new date
  void rescheduleNextMeeting(
    DateTime newMeetingDate, {
    int durationMinutes = 30,
  }) {
    if (!_hasNextMeeting) {
      throw StateError('No meeting scheduled to reschedule');
    }

    if (newMeetingDate.isBefore(DateTime.now())) {
      throw ArgumentError('Meeting date must be in the future');
    }

    if (_nextMeetingDoctor == null) {
      throw StateError('Meeting doctor information is missing');
    }

    if (!_isDoctorAvailable(
        _nextMeetingDoctor!, newMeetingDate, durationMinutes)) {
      throw ArgumentError(
        'Doctor ${_nextMeetingDoctor!.name} is not available at ${_formatDateTime(newMeetingDate)}. '
        'Please choose a different time.',
      );
    }

    if (_nextMeetingDate != null) {
      _removeMeetingFromDoctorSchedule(_nextMeetingDoctor!, _nextMeetingDate!);
    }

    _nextMeetingDate = newMeetingDate;

    _addMeetingToDoctorSchedule(_nextMeetingDoctor!, newMeetingDate);
  }

  /// Public method to check if a doctor is available at a specific time
  /// Useful for UI to validate before attempting to schedule
  bool isDoctorAvailableAt({
    required Doctor doctor,
    required DateTime dateTime,
    int durationMinutes = 30,
  }) {
    return _isDoctorAvailable(doctor, dateTime, durationMinutes);
  }

  /// Get all scheduled times for a doctor on a specific date
  /// Returns empty list if doctor has no schedule that day
  List<DateTime> getDoctorScheduleForDate({
    required Doctor doctor,
    required DateTime date,
  }) {
    final String scheduleKey = _getScheduleKey(date);
    return doctor.getScheduleFor(scheduleKey);
  }

  /// Get suggested available time slots for a doctor on a specific date
  /// Returns list of available DateTime slots during working hours (8 AM - 5 PM)
  List<DateTime> getSuggestedAvailableSlots({
    required Doctor doctor,
    required DateTime date,
    int durationMinutes = 30,
    int startHour = 8,
    int endHour = 17,
  }) {
    final List<DateTime> availableSlots = [];
    final DateTime startOfDay =
        DateTime(date.year, date.month, date.day, startHour);

    DateTime currentSlot = startOfDay;
    final DateTime endOfDay =
        DateTime(date.year, date.month, date.day, endHour);

    while (currentSlot.isBefore(endOfDay)) {
      if (_isDoctorAvailable(doctor, currentSlot, durationMinutes) &&
          currentSlot.isAfter(DateTime.now())) {
        availableSlots.add(currentSlot);
      }
      // Move to next slot (every 30 minutes)
      currentSlot = currentSlot.add(const Duration(minutes: 30));
    }

    return availableSlots;
  }

  // Helper methods for meeting schedule management

  /// Check if doctor is available at the specified time
  bool _isDoctorAvailable(
    Doctor doctor,
    DateTime requestedTime,
    int durationMinutes,
  ) {
    // Step 1: Check if the doctor is working during this time
    if (!doctor.isWorkingDuring(requestedTime, durationMinutes)) {
      return false; // Outside working hours
    }

    // Step 2: Check for conflicts with existing meetings
    final String scheduleKey = _getScheduleKey(requestedTime);
    final List<DateTime> doctorSchedule = doctor.getScheduleFor(scheduleKey);

    final DateTime requestedEnd =
        requestedTime.add(Duration(minutes: durationMinutes));

    for (final scheduledTime in doctorSchedule) {
      // Assume each scheduled item takes 30 minutes by default
      final DateTime scheduledEnd =
          scheduledTime.add(const Duration(minutes: 30));

      bool hasConflict = (requestedTime.isBefore(scheduledEnd) &&
          requestedEnd.isAfter(scheduledTime));

      if (hasConflict) {
        return false; // Meeting conflict
      }
    }

    // Note: This method only checks working hours and nextMeeting conflicts
    // For full availability checking including Appointment entities,
    // use DoctorRepository.isDoctorFullyAvailable() instead
    return true; // Available for meetings
  }

  /// Add meeting to doctor's schedule
  void _addMeetingToDoctorSchedule(Doctor doctor, DateTime meetingDate) {
    final String scheduleKey = _getScheduleKey(meetingDate);
    doctor.addScheduleEntry(scheduleKey, meetingDate);
  }

  /// Remove meeting from doctor's schedule
  void _removeMeetingFromDoctorSchedule(Doctor doctor, DateTime meetingDate) {
    final String scheduleKey = _getScheduleKey(meetingDate);
    doctor.removeScheduleEntry(scheduleKey, meetingDate);
  }

  /// Generate schedule key from date (format: YYYY-MM-DD)
  String _getScheduleKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Format DateTime for display
  String _formatDateTime(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Check if the next meeting is upcoming (within next 7 days)
  bool get isNextMeetingSoon {
    if (!_hasNextMeeting || _nextMeetingDate == null) {
      return false;
    }

    final now = DateTime.now();
    final daysUntilMeeting = _nextMeetingDate!.difference(now).inDays;
    return daysUntilMeeting >= 0 && daysUntilMeeting <= 7;
  }

  /// Check if the next meeting is overdue
  bool get isNextMeetingOverdue {
    if (!_hasNextMeeting || _nextMeetingDate == null) {
      return false;
    }

    return _nextMeetingDate!.isBefore(DateTime.now());
  }

  /// Get formatted next meeting information
  String? get nextMeetingInfo {
    if (!_hasNextMeeting) {
      return null;
    }

    if (_nextMeetingDate == null || _nextMeetingDoctor == null) {
      return 'Meeting scheduled but details incomplete';
    }

    final dateStr = '${_nextMeetingDate!.year}-'
        '${_nextMeetingDate!.month.toString().padLeft(2, '0')}-'
        '${_nextMeetingDate!.day.toString().padLeft(2, '0')} '
        '${_nextMeetingDate!.hour.toString().padLeft(2, '0')}:'
        '${_nextMeetingDate!.minute.toString().padLeft(2, '0')}';

    return 'Next meeting with Dr. ${_nextMeetingDoctor!.name} on $dateStr';
  }

  void _validatePatient() {
    if (_patientID.trim().isEmpty) {
      throw ArgumentError('Patient ID cannot be empty');
    }
    if (_bloodType.trim().isEmpty) {
      throw ArgumentError('Blood type cannot be empty');
    }
    if (_emergencyContact.trim().isEmpty) {
      throw ArgumentError('Emergency contact cannot be empty');
    }

    if (_hasNextMeeting) {
      if (_nextMeetingDate == null) {
        throw ArgumentError(
          'Next meeting date must be provided when hasNextMeeting is true',
        );
      }
      if (_nextMeetingDoctor == null) {
        throw ArgumentError(
          'Next meeting doctor must be provided when hasNextMeeting is true',
        );
      }
    }
  }

  void addMedicalRecord(String record) {
    if (record.trim().isNotEmpty) {
      _medicalRecords.add(record);
    }
  }

  void addAllergy(String allergy) {
    if (allergy.trim().isNotEmpty && !_allergies.contains(allergy)) {
      _allergies.add(allergy);
    }
  }

  void removeAllergy(String allergy) {
    _allergies.remove(allergy);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is Patient &&
          runtimeType == other.runtimeType &&
          _patientID == other._patientID;

  @override
  int get hashCode => super.hashCode ^ _patientID.hashCode;

  @override
  String toString() {
    final meetingStatus = _hasNextMeeting
        ? ', nextMeeting: ${_nextMeetingDate?.toString() ?? "TBD"}'
        : ', no scheduled meeting';
    return 'Patient(patientID: $_patientID, name: $name, bloodType: $_bloodType$meetingStatus)';
  }
}
