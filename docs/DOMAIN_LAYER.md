# 🎯 Domain Layer - Complete Guide

<div align="center">

**The Heart of Clean Architecture**

*Pure Business Logic | Zero Dependencies | Framework Agnostic*

[![Domain Layer](https://img.shields.io/badge/Layer-Domain-blue?style=for-the-badge)]()
[![Entities](https://img.shields.io/badge/Entities-12-success?style=for-the-badge)]()
[![Use Cases](https://img.shields.io/badge/Use%20Cases-50+-orange?style=for-the-badge)]()
[![Repositories](https://img.shields.io/badge/Repositories-8-purple?style=for-the-badge)]()

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Architecture Philosophy](#-architecture-philosophy)
- [Directory Structure](#-directory-structure)
- [Entities](#-entities)
- [Repositories](#-repositories)
- [Use Cases](#-use-cases)
- [Enumerations](#-enumerations)
- [Design Patterns](#-design-patterns)
- [Best Practices](#-best-practices)

---

## 🌟 Overview

The **Domain Layer** is the core of our Hospital Management System, containing all business logic, rules, and entities. It represents the problem domain and is completely independent of any external frameworks, databases, or UI implementations.

### Key Principles

```
┌─────────────────────────────────────────────────────────┐
│                    DOMAIN LAYER                         │
│                                                         │
│  ✓ Pure Dart - No Flutter dependencies                 │
│  ✓ Business Logic Only - No UI or database code        │
│  ✓ Framework Independent - Can work anywhere           │
│  ✓ Testable - Easy to unit test                        │
│  ✓ Stable - Changes rarely                             │
│                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐   │
│  │  Entities   │  │ Use Cases   │  │ Repositories│   │
│  │  (What)     │  │   (How)     │  │ (Interface) │   │
│  └─────────────┘  └─────────────┘  └─────────────┘   │
└─────────────────────────────────────────────────────────┘
```

### 📊 Statistics

| Component | Count | Status |
|-----------|-------|--------|
| **Entities** | 12 | ✅ Complete |
| **Base Entities** | 2 (Person, Staff) | ✅ Complete |
| **Repositories** | 8 | ✅ Complete |
| **Use Cases** | 50+ | ✅ Complete |
| **Enumerations** | 6 | ✅ Complete |
| **Exception Types** | 6 | ✅ Complete |

---

## 🏛️ Architecture Philosophy

### The Dependency Rule

> **Inner layers don't depend on outer layers**

```
                    ┌─────────────┐
                    │     UI      │
                    │(Presentation)│
                    └──────┬──────┘
                           │ depends on
                    ┌──────▼──────┐
                    │    Data     │
                    │(Repositories)│
                    └──────┬──────┘
                           │ implements
                    ┌──────▼──────┐
                    │   DOMAIN    │ ◄── No dependencies!
                    │  (This!)    │     Pure business logic
                    └─────────────┘
```

### Why Domain-First?

1. **Business Focus** - Code reflects real-world hospital operations
2. **Testability** - Pure functions, easy to test
3. **Flexibility** - Change UI or database without touching business logic
4. **Maintainability** - Clear separation of concerns
5. **Reusability** - Same domain logic across multiple platforms

---

## 📁 Directory Structure

```
lib/domain/
│
├── entities/                          # 🏗️ Core Business Objects (12)
│   ├── enums/                         # Type-safe state machines
│   │   ├── appointment_status.dart    # Appointment lifecycle
│   │   ├── bed_type.dart              # Bed classifications
│   │   ├── emergency_level.dart       # Emergency priorities
│   │   ├── equipment_status.dart      # Equipment states
│   │   ├── room_status.dart           # Room availability
│   │   └── room_type.dart             # Room classifications
│   │
│   ├── person.dart                    # 👤 Base: All people
│   ├── staff.dart                     # 👔 Base: Hospital staff
│   ├── patient.dart                   # 🏥 Patients with medical data
│   ├── doctor.dart                    # 👨‍⚕️ Doctors with specializations
│   ├── nurse.dart                     # 👩‍⚕️ Nurses with shifts
│   ├── administrative.dart            # 📋 Admin staff
│   ├── appointment.dart               # 📅 Appointment bookings
│   ├── prescription.dart              # 💊 Medication prescriptions
│   ├── medication.dart                # 💉 Medication catalog
│   ├── room.dart                      # 🏠 Hospital rooms
│   ├── bed.dart                       # 🛏️ Hospital beds
│   └── equipment.dart                 # 🔧 Medical equipment
│
├── repositories/                      # 📦 Data Access Contracts (8)
│   ├── patient_repository.dart        # Patient CRUD + queries
│   ├── doctor_repository.dart         # Doctor CRUD + scheduling
│   ├── nurse_repository.dart          # Nurse CRUD + workload
│   ├── appointment_repository.dart    # Appointment management
│   ├── prescription_repository.dart   # Prescription tracking
│   ├── room_repository.dart           # Room & bed management
│   ├── equipment_repository.dart      # Equipment tracking
│   └── administrative_repository.dart # Admin staff management
│
└── usecases/                          # ⚡ Business Operations (50+)
    ├── base/
    │   └── use_case.dart              # Abstract base class
    │
    ├── patient/                       # 👥 Patient Operations (7)
    │   ├── admit_patient.dart
    │   ├── discharge_patient.dart
    │   ├── assign_doctor_to_patient.dart
    │   ├── schedule_patient_meeting.dart
    │   ├── reschedule_patient_meeting.dart
    │   ├── cancel_patient_meeting.dart
    │   └── get_meeting_reminders.dart
    │
    ├── doctor/                        # 👨‍⚕️ Doctor Operations (1)
    │   └── get_doctor_schedule.dart
    │
    ├── nurse/                         # 👩‍⚕️ Nurse Operations (6)
    │   ├── assign_nurse_to_patient.dart
    │   ├── assign_nurse_to_room.dart
    │   ├── remove_nurse_assignment.dart
    │   ├── transfer_nurse_between_rooms.dart
    │   ├── get_nurse_workload.dart
    │   └── get_available_nurses.dart
    │
    ├── appointment/                   # 📅 Appointment Operations (8)
    │   ├── schedule_appointment.dart
    │   ├── get_appointment_history.dart
    │   ├── get_appointments_by_doctor.dart
    │   ├── get_appointments_by_patient.dart
    │   ├── get_upcoming_appointments.dart
    │   ├── reschedule_appointment.dart
    │   ├── update_appointment_status.dart
    │   └── cancel_appointment.dart
    │
    ├── prescription/                  # 💊 Prescription Operations (7)
    │   ├── prescribe_medication.dart
    │   ├── check_drug_interactions.dart
    │   ├── get_prescription_history.dart
    │   ├── get_medication_schedule.dart
    │   ├── get_active_prescriptions.dart
    │   ├── refill_prescription.dart
    │   └── discontinue_prescription.dart
    │
    ├── room/                          # 🏥 Room Operations (6)
    │   ├── search_available_rooms.dart
    │   ├── search_available_beds.dart
    │   ├── get_available_icu_beds.dart
    │   ├── reserve_bed.dart
    │   ├── transfer_patient.dart
    │   └── get_room_occupancy.dart
    │
    ├── equipment/                     # 🔧 Equipment Operations (6)
    │   ├── assign_equipment_to_room.dart
    │   ├── transfer_equipment_between_rooms.dart
    │   ├── get_equipment_status.dart
    │   ├── get_maintenance_due_equipment.dart
    │   ├── schedule_equipment_maintenance.dart
    │   └── report_equipment_issue.dart
    │
    ├── emergency/                     # 🚨 Emergency Operations (5)
    │   ├── admit_emergency_patient.dart
    │   ├── find_emergency_bed.dart
    │   ├── get_available_icu_capacity.dart
    │   ├── initiate_emergency_protocol.dart
    │   └── notify_emergency_staff.dart
    │
    └── search/                        # 🔍 Search Operations (6)
        ├── search_patients.dart
        ├── search_doctors.dart
        ├── search_appointments.dart
        ├── search_prescriptions.dart
        ├── search_rooms.dart
        └── search_medical_records.dart
```

---

## 🏗️ Entities

Entities are **pure business objects** representing real-world concepts in the hospital domain. They contain data and behavior but no persistence logic.

### Entity Hierarchy

```
Person (Abstract Base)
  │
  ├── Patient
  │
  └── Staff (Abstract Base)
        ├── Doctor
        ├── Nurse
        └── Administrative
```

### Design Principles

✅ **Immutability** - Entities are immutable by default  
✅ **Encapsulation** - Private fields with public getters  
✅ **Rich Behavior** - Methods for business operations  
✅ **Validation** - Built-in validation logic  
✅ **Relationships** - Bidirectional entity relationships  

---

### 👤 Person (Base Entity)

**Purpose**: Base class for all people in the system

**Location**: `lib/domain/entities/person.dart`

<details>
<summary><b>📝 View Complete Implementation</b></summary>

```dart
abstract class Person {
  final String name;
  final String dateOfBirth;
  final String address;
  final String tel;

  Person({
    required this.name,
    required this.dateOfBirth,
    required this.address,
    required this.tel,
  });

  // Calculate age from date of birth
  int get age {
    final dob = DateTime.parse(dateOfBirth);
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || 
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  // Format phone number
  String get formattedPhone {
    // Khmer format: 012-XXX-XXXX
    if (tel.length == 10) {
      return '${tel.substring(0, 3)}-${tel.substring(3, 6)}-${tel.substring(6)}';
    }
    return tel;
  }
}
```

**Fields**:
- `name`: Full name (Khmer or English)
- `dateOfBirth`: Date in YYYY-MM-DD format
- `address`: Physical address
- `tel`: Phone number (012XXXXXXX format)

**Computed Properties**:
- `age`: Calculated from dateOfBirth
- `formattedPhone`: Formatted phone display

</details>

---

### 👔 Staff (Base Entity)

**Purpose**: Base class for all hospital staff members

**Location**: `lib/domain/entities/staff.dart`

<details>
<summary><b>📝 View Complete Implementation</b></summary>

```dart
abstract class Staff extends Person {
  final String staffID;
  final String department;
  final DateTime hireDate;
  final String licenseNumber;

  Staff({
    required this.staffID,
    required this.department,
    required this.hireDate,
    required this.licenseNumber,
    required String name,
    required String dateOfBirth,
    required String address,
    required String tel,
  }) : super(
          name: name,
          dateOfBirth: dateOfBirth,
          address: address,
          tel: tel,
        );

  // Calculate years of service
  int get yearsOfService {
    final now = DateTime.now();
    int years = now.year - hireDate.year;
    if (now.month < hireDate.month ||
        (now.month == hireDate.month && now.day < hireDate.day)) {
      years--;
    }
    return years;
  }

  // Check if license is valid
  bool get isLicenseValid => licenseNumber.isNotEmpty;
}
```

**Additional Fields**:
- `staffID`: Unique staff identifier (D001, N001, etc.)
- `department`: Hospital department
- `hireDate`: Employment start date
- `licenseNumber`: Professional license number

**Computed Properties**:
- `yearsOfService`: Calculated work experience
- `isLicenseValid`: License validation check

</details>

---

### 🏥 Patient Entity

**Purpose**: Represents hospital patients with complete medical information

**Location**: `lib/domain/entities/patient.dart`

<details>
<summary><b>📝 View Complete Fields & Methods</b></summary>

#### Core Fields

```dart
class Patient extends Person {
  final String _patientID;                    // P001-P999
  final String _bloodType;                    // A+, B+, O+, AB+, etc.
  final List<String> _medicalRecords;         // Medical history
  final List<String> _allergies;              // Known allergies
  final String _emergencyContact;             // Emergency phone number
  
  // Relationships
  final List<Doctor> _assignedDoctors;        // Assigned doctors
  final List<Nurse> _assignedNurses;          // Assigned nurses
  final List<Prescription> _prescriptions;    // Active prescriptions
  Room? _currentRoom;                         // Current room (if admitted)
  Bed? _currentBed;                           // Current bed (if admitted)
  
  // Meeting Scheduling
  bool _hasNextMeeting;                       // Meeting scheduled?
  DateTime? _nextMeetingDate;                 // Next appointment date
  Doctor? _nextMeetingDoctor;                 // Meeting with doctor
}
```

#### Public Getters

```dart
String get patientID => _patientID;
String get bloodType => _bloodType;
UnmodifiableListView<String> get medicalRecords => 
    UnmodifiableListView(_medicalRecords);
UnmodifiableListView<String> get allergies => 
    UnmodifiableListView(_allergies);
String get emergencyContact => _emergencyContact;

// Relationships (Immutable views)
UnmodifiableListView<Doctor> get assignedDoctors => 
    UnmodifiableListView(_assignedDoctors);
UnmodifiableListView<Nurse> get assignedNurses => 
    UnmodifiableListView(_assignedNurses);
UnmodifiableListView<Prescription> get prescriptions => 
    UnmodifiableListView(_prescriptions);
Room? get currentRoom => _currentRoom;
Bed? get currentBed => _currentBed;

// Meeting properties
bool get hasNextMeeting => _hasNextMeeting;
DateTime? get nextMeetingDate => _nextMeetingDate;
Doctor? get nextMeetingDoctor => _nextMeetingDoctor;
```

#### Business Methods

```dart
/// Schedule next doctor meeting
void scheduleNextMeeting(Doctor doctor, DateTime dateTime) {
  if (dateTime.isBefore(DateTime.now())) {
    throw ArgumentError('Meeting date must be in the future');
  }
  _nextMeetingDoctor = doctor;
  _nextMeetingDate = dateTime;
  _hasNextMeeting = true;
}

/// Cancel scheduled meeting
void cancelNextMeeting() {
  _nextMeetingDoctor = null;
  _nextMeetingDate = null;
  _hasNextMeeting = false;
}

/// Reschedule existing meeting
void rescheduleNextMeeting(DateTime newDateTime) {
  if (!_hasNextMeeting) {
    throw StateError('No meeting scheduled to reschedule');
  }
  if (newDateTime.isBefore(DateTime.now())) {
    throw ArgumentError('Meeting date must be in the future');
  }
  _nextMeetingDate = newDateTime;
}

/// Assign doctor to patient
void assignDoctor(Doctor doctor) {
  if (_assignedDoctors.contains(doctor)) {
    throw StateError('Doctor already assigned');
  }
  _assignedDoctors.add(doctor);
}

/// Remove doctor assignment
void removeDoctor(Doctor doctor) {
  _assignedDoctors.remove(doctor);
}

/// Assign nurse to patient
void assignNurse(Nurse nurse) {
  if (!_assignedNurses.contains(nurse)) {
    _assignedNurses.add(nurse);
  }
}

/// Admit patient to room and bed
void admit(Room room, Bed bed) {
  _currentRoom = room;
  _currentBed = bed;
}

/// Discharge patient from hospital
void discharge() {
  _currentRoom = null;
  _currentBed = null;
}

/// Check if patient is admitted
bool get isAdmitted => _currentRoom != null && _currentBed != null;

/// Add medical record entry
void addMedicalRecord(String record) {
  _medicalRecords.add(record);
}

/// Add allergy information
void addAllergy(String allergy) {
  if (!_allergies.contains(allergy)) {
    _allergies.add(allergy);
  }
}

/// Add prescription
void addPrescription(Prescription prescription) {
  _prescriptions.add(prescription);
}

/// Get active prescriptions only
List<Prescription> get activePrescriptions {
  return _prescriptions.where((p) => p.isActive).toList();
}
```

#### Validation Rules

- ✅ Patient ID must be unique and match P### pattern
- ✅ Blood type must be valid (A+, A-, B+, B-, AB+, AB-, O+, O-)
- ✅ Emergency contact must be valid phone number
- ✅ Meeting date must be in the future
- ✅ Cannot have duplicate doctor assignments
- ✅ Medical records are append-only (audit trail)

</details>

---

### 👨‍⚕️ Doctor Entity

**Purpose**: Represents medical doctors with specializations and schedules

**Location**: `lib/domain/entities/doctor.dart`

<details>
<summary><b>📝 View Complete Fields & Methods</b></summary>

#### Core Fields

```dart
class Doctor extends Staff {
  final String _specialization;               // Medical specialty
  final Map<String, Map<String, String>> _workingHours; // Weekly schedule
  final List<String> _patientIds;             // Assigned patient IDs
  final double _consultationFee;              // Consultation fee
  final int _yearsOfExperience;               // Practice experience
}
```

#### Specializations

```dart
// Supported Medical Specializations
static const List<String> validSpecializations = [
  'Cardiology',           // Heart specialist
  'Neurology',            // Brain & nervous system
  'Orthopedics',          // Bones & joints
  'Pediatrics',           // Children
  'Dermatology',          // Skin
  'Psychiatry',           // Mental health
  'Radiology',            // Imaging
  'Anesthesiology',       // Anesthesia
  'Surgery',              // General surgery
  'Internal Medicine',    // General medicine
  'Obstetrics',           // Pregnancy & childbirth
  'Ophthalmology',        // Eyes
  'ENT',                  // Ear, Nose, Throat
  'Urology',              // Urinary system
  'Emergency Medicine',   // Emergency care
];
```

#### Working Hours Structure

```dart
// Example working schedule
Map<String, Map<String, String>> workingHours = {
  'Monday': {
    'start': '08:00',
    'end': '17:00',
    'break_start': '12:00',
    'break_end': '13:00',
  },
  'Tuesday': {
    'start': '08:00',
    'end': '17:00',
    'break_start': '12:00',
    'break_end': '13:00',
  },
  // ... other days
};
```

#### Business Methods

```dart
/// Check if doctor is available on specific date/time
bool isAvailableAt(DateTime dateTime) {
  final dayName = _getDayName(dateTime.weekday);
  
  if (!_workingHours.containsKey(dayName)) {
    return false; // Not working on this day
  }
  
  final schedule = _workingHours[dayName]!;
  final startTime = _parseTime(schedule['start']!);
  final endTime = _parseTime(schedule['end']!);
  final breakStart = _parseTime(schedule['break_start']!);
  final breakEnd = _parseTime(schedule['break_end']!);
  
  final checkTime = TimeOfDay.fromDateTime(dateTime);
  
  // Check if within working hours
  if (!_isTimeBetween(checkTime, startTime, endTime)) {
    return false;
  }
  
  // Check if not during break
  if (_isTimeBetween(checkTime, breakStart, breakEnd)) {
    return false;
  }
  
  return true;
}

/// Get available time slots for a specific date
List<TimeSlot> getAvailableSlots(DateTime date, int slotDuration) {
  // Returns list of available appointment slots
  // Each slot is {slotDuration} minutes long
}

/// Assign patient to doctor
void assignPatient(String patientId) {
  if (!_patientIds.contains(patientId)) {
    _patientIds.add(patientId);
  }
}

/// Remove patient assignment
void removePatient(String patientId) {
  _patientIds.remove(patientId);
}

/// Get patient workload
int get patientCount => _patientIds.length;

/// Check if doctor is overloaded
bool get isOverloaded => _patientIds.length > 30;

/// Get working days
List<String> get workingDays => _workingHours.keys.toList();

/// Calculate total working hours per week
double get weeklyWorkingHours {
  double total = 0;
  for (var schedule in _workingHours.values) {
    final start = _parseTime(schedule['start']!);
    final end = _parseTime(schedule['end']!);
    final breakStart = _parseTime(schedule['break_start']!);
    final breakEnd = _parseTime(schedule['break_end']!);
    
    total += _hoursBetween(start, end);
    total -= _hoursBetween(breakStart, breakEnd);
  }
  return total;
}
```

#### Validation Rules

- ✅ Staff ID must match D### pattern
- ✅ Specialization must be from valid list
- ✅ Consultation fee must be positive
- ✅ Working hours must be valid time ranges
- ✅ Cannot exceed maximum patient load (30)
- ✅ Years of experience must be non-negative

</details>

---

### 👩‍⚕️ Nurse Entity

**Purpose**: Represents nursing staff with shift schedules and assignments

**Location**: `lib/domain/entities/nurse.dart`

<details>
<summary><b>📝 View Complete Fields & Methods</b></summary>

#### Core Fields

```dart
class Nurse extends Staff {
  final NurseShift _shift;                    // MORNING, AFTERNOON, NIGHT
  final List<String> _assignedPatientIds;     // Assigned patients
  final List<String> _assignedRoomIds;        // Assigned rooms
  final Map<String, List<DateTime>> _schedule; // Work schedule
  final List<String> _specializations;        // Nursing specializations
}
```

#### Nurse Shifts

```dart
enum NurseShift {
  MORNING,    // 06:00 - 14:00 (8 hours)
  AFTERNOON,  // 14:00 - 22:00 (8 hours)
  NIGHT,      // 22:00 - 06:00 (8 hours)
}

extension NurseShiftExtension on NurseShift {
  String get displayName {
    switch (this) {
      case NurseShift.MORNING:
        return 'Morning (6AM-2PM)';
      case NurseShift.AFTERNOON:
        return 'Afternoon (2PM-10PM)';
      case NurseShift.NIGHT:
        return 'Night (10PM-6AM)';
    }
  }
  
  TimeRange get timeRange {
    switch (this) {
      case NurseShift.MORNING:
        return TimeRange(start: '06:00', end: '14:00');
      case NurseShift.AFTERNOON:
        return TimeRange(start: '14:00', end: '22:00');
      case NurseShift.NIGHT:
        return TimeRange(start: '22:00', end: '06:00');
    }
  }
}
```

#### Nursing Specializations

```dart
static const List<String> validSpecializations = [
  'Critical Care',        // ICU nursing
  'Emergency',            // ER nursing
  'Pediatric',            // Children's nursing
  'Surgical',             // Operating room
  'Psychiatric',          // Mental health
  'Obstetric',            // Maternity nursing
  'Geriatric',            // Elderly care
  'Oncology',             // Cancer care
  'Cardiology',           // Heart care
  'General',              // General nursing
];
```

#### Business Methods

```dart
/// Assign patient to nurse
void assignPatient(String patientId) {
  if (_assignedPatientIds.length >= 5) {
    throw StateError('Nurse already has maximum patient load (5)');
  }
  if (!_assignedPatientIds.contains(patientId)) {
    _assignedPatientIds.add(patientId);
  }
}

/// Remove patient assignment
void removePatient(String patientId) {
  _assignedPatientIds.remove(patientId);
}

/// Assign room to nurse
void assignRoom(String roomId) {
  if (_assignedRoomIds.length >= 4) {
    throw StateError('Nurse already has maximum room load (4)');
  }
  if (!_assignedRoomIds.contains(roomId)) {
    _assignedRoomIds.add(roomId);
  }
}

/// Remove room assignment
void removeRoom(String roomId) {
  _assignedRoomIds.remove(roomId);
}

/// Calculate workload (weighted: 70% patients, 30% rooms)
double get workload {
  const maxPatients = 5;
  const maxRooms = 4;
  
  final patientLoad = (_assignedPatientIds.length / maxPatients) * 0.7;
  final roomLoad = (_assignedRoomIds.length / maxRooms) * 0.3;
  
  return (patientLoad + roomLoad) * 100; // Return as percentage
}

/// Check if nurse is available for more assignments
bool get isAvailable => workload < 80; // Available if < 80% loaded

/// Check if nurse is overloaded
bool get isOverloaded => workload >= 100;

/// Get patient count
int get patientCount => _assignedPatientIds.length;

/// Get room count
int get roomCount => _assignedRoomIds.length;

/// Add work schedule entry
void addScheduleEntry(String date, DateTime time) {
  if (!_schedule.containsKey(date)) {
    _schedule[date] = [];
  }
  _schedule[date]!.add(time);
}

/// Get schedule for specific date
List<DateTime> getScheduleForDate(String date) {
  return _schedule[date] ?? [];
}

/// Check if working on specific date
bool isWorkingOn(DateTime date) {
  final dateStr = date.toIso8601String().split('T')[0];
  return _schedule.containsKey(dateStr);
}

/// Get total scheduled hours for month
int getTotalHoursForMonth(int year, int month) {
  int hours = 0;
  for (var entry in _schedule.entries) {
    final date = DateTime.parse(entry.key);
    if (date.year == year && date.month == month) {
      hours += entry.value.length * 8; // 8-hour shifts
    }
  }
  return hours;
}
```

#### Validation Rules

- ✅ Staff ID must match N### pattern
- ✅ Maximum 5 patients per nurse
- ✅ Maximum 4 rooms per nurse
- ✅ Shift must be valid enum value
- ✅ Specializations must be from valid list
- ✅ Workload calculated automatically
- ✅ Cannot exceed capacity limits

</details>

---

### 📅 Appointment Entity

**Purpose**: Represents scheduled medical appointments

**Location**: `lib/domain/entities/appointment.dart`

<details>
<summary><b>📝 View Complete Fields & Methods</b></summary>

#### Core Fields

```dart
class Appointment {
  final String _id;                          // A001-A999
  final DateTime _dateTime;                  // Appointment date/time
  final int _duration;                       // Duration in minutes
  final Patient _patient;                    // Patient object
  final Doctor _doctor;                      // Doctor object
  Room? _room;                               // Optional room
  AppointmentStatus _status;                 // Current status
  final String _reason;                      // Appointment reason
  String? _notes;                            // Additional notes
  DateTime? _completedAt;                    // Completion timestamp
  String? _cancellationReason;               // Cancellation reason
}
```

#### Appointment Status Lifecycle

```dart
enum AppointmentStatus {
  SCHEDULE,      // Initial state - newly scheduled
  IN_PROGRESS,   // Appointment currently happening
  COMPLETED,     // Successfully completed
  CANCELLED,     // Cancelled by patient/doctor
  NO_SHOW,       // Patient didn't show up
}

// Status Transitions (allowed state changes)
SCHEDULE     → IN_PROGRESS  ✅
SCHEDULE     → CANCELLED    ✅
SCHEDULE     → NO_SHOW      ✅
IN_PROGRESS  → COMPLETED    ✅
IN_PROGRESS  → CANCELLED    ✅
COMPLETED    → (no change)  ❌
CANCELLED    → (no change)  ❌
NO_SHOW      → (no change)  ❌
```

#### Business Methods

```dart
/// Start appointment (change to IN_PROGRESS)
void start() {
  if (_status != AppointmentStatus.SCHEDULE) {
    throw StateError('Can only start scheduled appointments');
  }
  
  final now = DateTime.now();
  if (now.isBefore(_dateTime.subtract(Duration(minutes: 15)))) {
    throw StateError('Cannot start appointment more than 15 minutes early');
  }
  
  _status = AppointmentStatus.IN_PROGRESS;
}

/// Complete appointment
void complete({String? notes}) {
  if (_status != AppointmentStatus.IN_PROGRESS) {
    throw StateError('Can only complete in-progress appointments');
  }
  
  _status = AppointmentStatus.COMPLETED;
  _completedAt = DateTime.now();
  if (notes != null) {
    _notes = notes;
  }
}

/// Cancel appointment
void cancel(String reason) {
  if (_status == AppointmentStatus.COMPLETED || 
      _status == AppointmentStatus.CANCELLED ||
      _status == AppointmentStatus.NO_SHOW) {
    throw StateError('Cannot cancel ${_status.name} appointment');
  }
  
  _status = AppointmentStatus.CANCELLED;
  _cancellationReason = reason;
}

/// Mark as no-show
void markAsNoShow() {
  if (_status != AppointmentStatus.SCHEDULE) {
    throw StateError('Can only mark scheduled appointments as no-show');
  }
  
  // Can only mark as no-show if appointment time has passed
  if (DateTime.now().isBefore(_dateTime)) {
    throw StateError('Cannot mark future appointment as no-show');
  }
  
  _status = AppointmentStatus.NO_SHOW;
}

/// Reschedule appointment
Appointment reschedule(DateTime newDateTime) {
  if (_status != AppointmentStatus.SCHEDULE) {
    throw StateError('Can only reschedule scheduled appointments');
  }
  
  if (newDateTime.isBefore(DateTime.now())) {
    throw ArgumentError('New date must be in the future');
  }
  
  return Appointment(
    id: _id,
    dateTime: newDateTime,
    duration: _duration,
    patient: _patient,
    doctor: _doctor,
    room: _room,
    status: AppointmentStatus.SCHEDULE,
    reason: _reason,
  );
}

/// Assign room to appointment
void assignRoom(Room room) {
  if (_status == AppointmentStatus.COMPLETED ||
      _status == AppointmentStatus.CANCELLED) {
    throw StateError('Cannot assign room to ${_status.name} appointment');
  }
  _room = room;
}

/// Update notes
void updateNotes(String notes) {
  _notes = notes;
}

/// Check if appointment is upcoming
bool get isUpcoming {
  return _status == AppointmentStatus.SCHEDULE && 
         _dateTime.isAfter(DateTime.now());
}

/// Check if appointment is overdue
bool get isOverdue {
  return _status == AppointmentStatus.SCHEDULE &&
         DateTime.now().isAfter(_dateTime.add(Duration(minutes: _duration)));
}

/// Get end time
DateTime get endTime => _dateTime.add(Duration(minutes: _duration));

/// Check if appointment conflicts with another
bool conflictsWith(Appointment other) {
  // Check if same doctor
  if (_doctor.staffID != other._doctor.staffID) {
    return false;
  }
  
  // Check time overlap
  return !(_dateTime.isAfter(other.endTime) || 
           endTime.isBefore(other._dateTime));
}

/// Get time until appointment (in hours)
double? get hoursUntil {
  if (_status != AppointmentStatus.SCHEDULE) {
    return null;
  }
  final diff = _dateTime.difference(DateTime.now());
  return diff.inMinutes / 60.0;
}
```

#### Validation Rules

- ✅ Appointment ID must be unique
- ✅ Duration must be between 15-240 minutes
- ✅ DateTime must be in the future (for new appointments)
- ✅ Patient and Doctor must exist
- ✅ Doctor must be available at the time
- ✅ Status transitions must follow lifecycle rules
- ✅ Cancellation requires reason
- ✅ Cannot modify completed/cancelled appointments

</details>

---

## 📦 Repositories

Repositories define **contracts for data access** without specifying implementation details. They allow the domain layer to request data without knowing where it comes from (database, API, file, etc.).

### Repository Pattern Benefits

```
Domain Layer            Data Layer
     │                       │
     │  Interface            │  Implementation
     ▼                       ▼
┌──────────────┐      ┌──────────────┐
│ PatientRepo  │◄─────│ PatientRepo  │
│ (interface)  │      │   Impl       │
└──────────────┘      └──────┬───────┘
                             │
                             ▼
                      ┌──────────────┐
                      │ JSON Storage │
                      └──────────────┘

✅ Domain doesn't know about JSON
✅ Easy to swap JSON → SQL → API
✅ Easy to mock for testing
```

---

### 🔍 Patient Repository

**Purpose**: CRUD operations and queries for patients

**Location**: `lib/domain/repositories/patient_repository.dart`

<details>
<summary><b>📋 View All Methods (25+)</b></summary>

```dart
abstract class PatientRepository {
  // ========== CRUD Operations ==========
  
  /// Get patient by ID
  /// Throws: EntityNotFoundException if not found
  Future<Patient> getById(String id);
  
  /// Get all patients
  /// Returns: Complete list of all patients in system
  Future<List<Patient>> getAll();
  
  /// Save new patient
  /// Generates ID automatically if not provided
  /// Throws: EntityConflictException if ID already exists
  Future<void> save(Patient patient);
  
  /// Update existing patient
  /// Throws: EntityNotFoundException if patient doesn't exist
  Future<void> update(Patient patient);
  
  /// Delete patient by ID
  /// Throws: EntityNotFoundException if patient doesn't exist
  Future<void> delete(String id);
  
  /// Check if patient exists
  Future<bool> exists(String id);
  
  // ========== Query Operations ==========
  
  /// Search patients by name (partial match, case-insensitive)
  Future<List<Patient>> searchByName(String name);
  
  /// Get patients by blood type
  Future<List<Patient>> getByBloodType(String bloodType);
  
  /// Get patients by assigned doctor
  Future<List<Patient>> getByDoctor(String doctorId);
  
  /// Get patients by assigned nurse
  Future<List<Patient>> getByNurse(String nurseId);
  
  /// Get currently admitted patients
  Future<List<Patient>> getAdmittedPatients();
  
  /// Get patients in specific room
  Future<List<Patient>> getByRoom(String roomId);
  
  /// Get patients with specific allergy
  Future<List<Patient>> getByAllergy(String allergy);
  
  // ========== Meeting Management ==========
  
  /// Get patients with upcoming meetings
  Future<List<Patient>> getPatientsWithUpcomingMeetings();
  
  /// Get patients with overdue meetings
  Future<List<Patient>> getPatientsWithOverdueMeetings();
  
  /// Get patients with meetings today
  Future<List<Patient>> getPatientsWithMeetingsToday();
  
  /// Get patients with meetings on specific date
  Future<List<Patient>> getPatientsWithMeetingsOnDate(DateTime date);
  
  /// Get patients by doctor meetings
  Future<List<Patient>> getPatientsByDoctorMeetings(String doctorId);
  
  // ========== Statistics ==========
  
  /// Get total patient count
  Future<int> getCount();
  
  /// Get admitted patient count
  Future<int> getAdmittedCount();
  
  /// Get patients by age range
  Future<List<Patient>> getByAgeRange(int minAge, int maxAge);
  
  /// Get critical patients (ICU or multiple medications)
  Future<List<Patient>> getCriticalPatients();
  
  // ========== Complex Queries ==========
  
  /// Advanced search with multiple criteria
  Future<List<Patient>> advancedSearch({
    String? name,
    String? bloodType,
    String? doctorId,
    String? nurseId,
    bool? isAdmitted,
    String? roomId,
    int? minAge,
    int? maxAge,
  });
}
```

**Usage Examples**:

```dart
// Get patient by ID
final patient = await patientRepository.getById('P001');

// Search by name
final results = await patientRepository.searchByName('Sokha');

// Get admitted patients
final admitted = await patientRepository.getAdmittedPatients();

// Advanced search
final patients = await patientRepository.advancedSearch(
  bloodType: 'O+',
  isAdmitted: true,
  minAge: 18,
  maxAge: 65,
);
```

</details>

---

### 👨‍⚕️ Doctor Repository

**Purpose**: CRUD operations and scheduling queries for doctors

**Location**: `lib/domain/repositories/doctor_repository.dart`

<details>
<summary><b>📋 View All Methods (20+)</b></summary>

```dart
abstract class DoctorRepository {
  // ========== CRUD Operations ==========
  
  Future<Doctor> getById(String id);
  Future<List<Doctor>> getAll();
  Future<void> save(Doctor doctor);
  Future<void> update(Doctor doctor);
  Future<void> delete(String id);
  Future<bool> exists(String id);
  
  // ========== Query Operations ==========
  
  /// Get doctors by specialization
  Future<List<Doctor>> getBySpecialization(String specialization);
  
  /// Get doctors by department
  Future<List<Doctor>> getByDepartment(String department);
  
  /// Search doctors by name
  Future<List<Doctor>> searchByName(String name);
  
  /// Get doctors with patients
  Future<List<Doctor>> getDoctorsWithPatients();
  
  /// Get doctors with specific patient count range
  Future<List<Doctor>> getByPatientCountRange(int min, int max);
  
  // ========== Availability Queries ==========
  
  /// Check if doctor is available at specific time
  Future<bool> isAvailableAt(String doctorId, DateTime dateTime);
  
  /// Get doctors available at specific time
  Future<List<Doctor>> getAvailableAt(DateTime dateTime);
  
  /// Get doctor's schedule for specific date
  Future<Map<String, dynamic>> getScheduleForDate(
    String doctorId, 
    DateTime date
  );
  
  /// Get available time slots for doctor on date
  Future<List<TimeSlot>> getAvailableSlots(
    String doctorId,
    DateTime date,
    int slotDuration,
  );
  
  // ========== Workload Management ==========
  
  /// Get doctors by workload (patient count)
  Future<List<Doctor>> getByWorkload({
    int? maxPatients,
    bool? isOverloaded,
  });
  
  /// Get doctor patient count
  Future<int> getPatientCount(String doctorId);
  
  /// Get doctors working on specific day
  Future<List<Doctor>> getWorkingOnDay(String dayName);
  
  // ========== Statistics ==========
  
  Future<int> getCount();
  Future<List<String>> getAllSpecializations();
  Future<Map<String, int>> getSpecializationDistribution();
}
```

</details>

---

## ⚡ Use Cases

Use cases represent **single business operations**. They orchestrate entities and repositories to perform specific tasks.

### UseCase Base Class

**Location**: `lib/domain/usecases/base/use_case.dart`

<details>
<summary><b>📋 View Complete Implementation</b></summary>

```dart
/// Base interface for all use cases
/// 
/// Provides consistent structure with lifecycle hooks:
/// 1. validate() - Validate input before execution
/// 2. execute() - Perform the business operation
/// 3. onSuccess() - Hook after successful execution
/// 4. onError() - Hook when error occurs
abstract class UseCase<Input, Output> {
  /// Execute the use case with the given input
  /// Override this method with your business logic
  Future<Output> execute(Input input);

  /// Validate input before execution (optional)
  /// Return false to prevent execution
  Future<bool> validate(Input input) async => true;

  /// Hook called when execution succeeds (optional)
  /// Useful for logging, analytics, notifications
  Future<void> onSuccess(Output result, Input input) async {}

  /// Hook called when execution fails (optional)
  /// Useful for error logging, cleanup, fallback
  Future<void> onError(Exception error, Input input) async {}

  /// Execute with full lifecycle
  /// This is the main entry point - call this method
  Future<Output> call(Input input) async {
    try {
      // 1. Validate input
      final isValid = await validate(input);
      if (!isValid) {
        throw UseCaseValidationException('Input validation failed');
      }

      // 2. Execute business logic
      final result = await execute(input);

      // 3. Success hook
      await onSuccess(result, input);

      return result;
    } on UseCaseException {
      // Re-throw use case exceptions
      rethrow;
    } catch (e) {
      // Convert other exceptions
      final exception = e is Exception ? e : Exception(e.toString());
      
      // 4. Error hook
      await onError(exception, input);
      
      rethrow;
    }
  }
}

/// Use case with no input required
abstract class NoInputUseCase<Output> {
  Future<Output> execute();
  Future<Output> call() async => await execute();
}

/// Use case with no output returned
abstract class NoOutputUseCase<Input> {
  Future<void> execute(Input input);
  Future<void> call(Input input) async => await execute(input);
}
```

**Exception Hierarchy**:

```dart
UseCaseException (Base)
    ├── UseCaseValidationException     // Input validation failed
    ├── EntityNotFoundException        // Entity not found
    ├── EntityConflictException        // Duplicate or conflict
    ├── UnauthorizedException          // Permission denied
    └── BusinessRuleViolationException // Business rule broken
```

</details>

### Use Case Example: Schedule Appointment

<details>
<summary><b>📋 View Complete Implementation</b></summary>

```dart
class ScheduleAppointment extends UseCase<AppointmentInput, Appointment> {
  final AppointmentRepository _appointmentRepository;
  final PatientRepository _patientRepository;
  final DoctorRepository _doctorRepository;

  ScheduleAppointment({
    required AppointmentRepository appointmentRepository,
    required PatientRepository patientRepository,
    required DoctorRepository doctorRepository,
  })  : _appointmentRepository = appointmentRepository,
        _patientRepository = patientRepository,
        _doctorRepository = doctorRepository;

  @override
  Future<bool> validate(AppointmentInput input) async {
    // 1. Check patient exists
    if (!await _patientRepository.exists(input.patientId)) {
      throw EntityNotFoundException('Patient', input.patientId);
    }

    // 2. Check doctor exists
    if (!await _doctorRepository.exists(input.doctorId)) {
      throw EntityNotFoundException('Doctor', input.doctorId);
    }

    // 3. Check future date
    if (input.dateTime.isBefore(DateTime.now())) {
      throw UseCaseValidationException(
        'Appointment date must be in the future'
      );
    }

    // 4. Check valid duration
    if (input.duration < 15 || input.duration > 240) {
      throw UseCaseValidationException(
        'Duration must be between 15-240 minutes'
      );
    }

    // 5. Check doctor availability
    final isAvailable = await _doctorRepository.isAvailableAt(
      input.doctorId,
      input.dateTime,
    );
    
    if (!isAvailable) {
      throw BusinessRuleViolationException(
        'doctor_unavailable',
        'Doctor is not available at the requested time',
      );
    }

    // 6. Check for conflicts
    final doctorAppointments = await _appointmentRepository
        .getByDoctorAndDate(input.doctorId, input.dateTime);
    
    for (var existing in doctorAppointments) {
      if (_hasTimeConflict(existing, input)) {
        throw EntityConflictException(
          'Doctor already has appointment at this time',
          details: {'conflictingAppointmentId': existing.id},
        );
      }
    }

    return true;
  }

  @override
  Future<Appointment> execute(AppointmentInput input) async {
    // Load full entities
    final patient = await _patientRepository.getById(input.patientId);
    final doctor = await _doctorRepository.getById(input.doctorId);

    // Create appointment
    final appointment = Appointment(
      id: 'AUTO', // Will be generated
      dateTime: input.dateTime,
      duration: input.duration,
      patient: patient,
      doctor: doctor,
      status: AppointmentStatus.SCHEDULE,
      reason: input.reason,
    );

    // Save to repository
    await _appointmentRepository.save(appointment);

    return appointment;
  }

  @override
  Future<void> onSuccess(Appointment result, AppointmentInput input) async {
    print('✅ Appointment ${result.id} scheduled successfully');
    // Could send confirmation email/SMS here
    // await notificationService.sendAppointmentConfirmation(result);
  }

  @override
  Future<void> onError(Exception error, AppointmentInput input) async {
    print('❌ Failed to schedule appointment: $error');
    // Could log to monitoring service
    // await errorLogger.log(error, input);
  }

  bool _hasTimeConflict(Appointment existing, AppointmentInput input) {
    final inputEnd = input.dateTime.add(Duration(minutes: input.duration));
    return !(input.dateTime.isAfter(existing.endTime) ||
        inputEnd.isBefore(existing.dateTime));
  }
}

// Input data class
class AppointmentInput {
  final String patientId;
  final String doctorId;
  final DateTime dateTime;
  final int duration;
  final String reason;
  final String? roomId;
  final String? notes;

  AppointmentInput({
    required this.patientId,
    required this.doctorId,
    required this.dateTime,
    required this.duration,
    required this.reason,
    this.roomId,
    this.notes,
  });
}
```

**Usage**:

```dart
// Create use case instance
final scheduleAppointment = ScheduleAppointment(
  appointmentRepository: appointmentRepo,
  patientRepository: patientRepo,
  doctorRepository: doctorRepo,
);

// Create input
final input = AppointmentInput(
  patientId: 'P001',
  doctorId: 'D005',
  dateTime: DateTime(2025, 11, 15, 10, 0),
  duration: 30,
  reason: 'Regular checkup',
);

// Execute use case
try {
  final appointment = await scheduleAppointment(input);
  print('Appointment created: ${appointment.id}');
} on EntityNotFoundException catch (e) {
  print('Entity not found: ${e.entityType} ${e.entityId}');
} on BusinessRuleViolationException catch (e) {
  print('Business rule violation: ${e.rule}');
} on EntityConflictException catch (e) {
  print('Conflict: ${e.message}');
}
```

</details>

---

## 🎨 Design Patterns

### 1. Repository Pattern

**Purpose**: Abstract data access

```dart
// Domain defines what it needs
abstract class PatientRepository {
  Future<Patient> getById(String id);
}

// Data layer implements how
class PatientRepositoryImpl implements PatientRepository {
  @override
  Future<Patient> getById(String id) async {
    // Implementation with JSON/SQL/API
  }
}
```

### 2. Use Case Pattern

**Purpose**: Single Responsibility for business operations

```dart
// Each business operation is its own class
class AdmitPatient extends UseCase<AdmitInput, bool> { }
class DischargePatient extends UseCase<String, bool> { }
class TransferPatient extends UseCase<TransferInput, bool> { }
```

### 3. Entity Pattern

**Purpose**: Rich domain models with behavior

```dart
// Not just data holders - has business logic
class Patient extends Person {
  void admit(Room room, Bed bed) { }
  void discharge() { }
  void scheduleNextMeeting(Doctor doctor, DateTime time) { }
}
```

### 4. Value Object Pattern

**Purpose**: Immutable objects representing values

```dart
class TimeSlot {
  final TimeOfDay start;
  final TimeOfDay end;
  final bool isAvailable;
  
  // Immutable - no setters
  TimeSlot({required this.start, required this.end, required this.isAvailable});
}
```

---

## ✅ Best Practices

### 1. Keep Domain Pure

```dart
// ✅ GOOD - Pure domain logic
class Patient {
  void addMedicalRecord(String record) {
    _medicalRecords.add(record);
  }
}

// ❌ BAD - Has database knowledge
class Patient {
  void addMedicalRecord(String record) {
    _medicalRecords.add(record);
    database.save(this); // NO! Domain shouldn't know about database
  }
}
```

### 2. Use Immutability

```dart
// ✅ GOOD - Immutable collections
class Patient {
  final List<String> _medicalRecords;
  UnmodifiableListView<String> get medicalRecords => 
      UnmodifiableListView(_medicalRecords);
}

// ❌ BAD - Mutable public field
class Patient {
  List<String> medicalRecords; // Anyone can modify!
}
```

### 3. Validate in Constructors

```dart
// ✅ GOOD - Validate on creation
class Appointment {
  Appointment({required this.duration}) {
    if (duration < 15 || duration > 240) {
      throw ArgumentError('Duration must be 15-240 minutes');
    }
  }
}
```

### 4. Use Meaningful Names

```dart
// ✅ GOOD - Clear intent
class ScheduleAppointment { }
class CancelAppointment { }
class RescheduleAppointment { }

// ❌ BAD - Vague names
class AppointmentManager { }
class AppointmentService { }
```

### 5. Single Responsibility

```dart
// ✅ GOOD - One responsibility
class AdmitPatient extends UseCase { }
class DischargePatient extends UseCase { }

// ❌ BAD - Multiple responsibilities
class PatientManagement {
  void admit() { }
  void discharge() { }
  void transfer() { }
  // ... many more
}
```

---

## 📚 Further Reading

- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Domain-Driven Design by Eric Evans](https://www.domainlanguage.com/ddd/)
- [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)
- [Repository Pattern](https://martinfowler.com/eaaCatalog/repository.html)

---

<div align="center">

**[⬆ Back to Top](#-domain-layer---complete-guide)**

Made with ❤️ for Hospital Management System

</div>
