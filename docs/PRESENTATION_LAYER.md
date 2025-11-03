# 🖥️ Presentation Layer - Complete Guide

<div align="center">

**The User Interface Layer**

*Console UI | Menu System | Input Validation | User Interaction*

[![Presentation Layer](https://img.shields.io/badge/Layer-Presentation-red?style=for-the-badge)]()
[![Menus](https://img.shields.io/badge/Menus-8-success?style=for-the-badge)]()
[![Controllers](https://img.shields.io/badge/Controllers-1-purple?style=for-the-badge)]()
[![Utils](https://img.shields.io/badge/Utils-2-orange?style=for-the-badge)]()

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Architecture](#-architecture)
- [Directory Structure](#-directory-structure)
- [Menu System](#-menu-system)
- [Base Menu Pattern](#-base-menu-pattern)
- [All Menus](#-all-menus)
- [Controllers](#-controllers)
- [Utilities](#-utilities)
- [User Flow](#-user-flow)
- [Best Practices](#-best-practices)

---

## 🌟 Overview

The **Presentation Layer** handles all user interactions through a console-based menu system. It's the outermost layer that depends on all other layers but is depended on by none.

### Key Responsibilities

```
┌─────────────────────────────────────────────────────────┐
│                 PRESENTATION LAYER                      │
│                                                         │
│  ✓ Display Information to User                         │
│  ✓ Capture User Input                                  │
│  ✓ Validate Input Format                               │
│  ✓ Navigate Between Menus                              │
│  ✓ Call Use Cases with Validated Data                  │
│  ✓ Display Results and Errors                          │
│  ✓ Format Output for Readability                       │
│                                                         │
│  ┌──────────┐  ┌───────────┐  ┌──────────────┐       │
│  │  Menus   │  │Controllers│  │   Utilities  │       │
│  │  (UI)    │  │  (Setup)  │  │  (Helpers)   │       │
│  └──────────┘  └───────────┘  └──────────────┘       │
└─────────────────────────────────────────────────────────┘
                       │ uses
                       ▼
            ┌──────────────────────┐
            │    DOMAIN LAYER      │
            │    (Use Cases)       │
            └──────────────────────┘
```

### 📊 Statistics

| Component | Count | Purpose |
|-----------|-------|---------|
| **Menus** | 8 | User interface screens |
| **Base Menu** | 1 | Abstract menu template |
| **Controllers** | 1 | Main application controller |
| **Utility Classes** | 2 | Input validation & UI helpers |
| **Total Operations** | 50+ | Available user actions |

---

## 🏛️ Architecture

### Dependency Direction

```
┌─────────────────────────────────────────────────────────┐
│                  PRESENTATION LAYER                     │
│                                                         │
│  MainMenuController                                     │
│         │                                               │
│         ├─→ PatientMenu      ─────┐                    │
│         ├─→ DoctorMenu       ─────┤                    │
│         ├─→ AppointmentMenu  ─────┤                    │
│         ├─→ PrescriptionMenu ─────┤ All extend         │
│         ├─→ RoomMenu         ─────┤ BaseMenu          │
│         ├─→ NurseMenu        ─────┤                    │
│         ├─→ SearchMenu       ─────┤                    │
│         └─→ EmergencyMenu    ─────┘                    │
│                                                         │
│  Each menu uses:                                        │
│    - InputValidator (validation)                        │
│    - UIHelper (formatting)                              │
│    - Repositories (data access)                         │
└─────────────────────────────────────────────────────────┘
                       │ depends on
                       ▼
┌─────────────────────────────────────────────────────────┐
│                   DOMAIN LAYER                          │
│   Repositories (interfaces) + Use Cases                 │
└─────────────────────────────────────────────────────────┘
```

### Clean Architecture Compliance

✅ **Presentation depends on Domain** - Can call use cases and repositories  
✅ **Domain independent** - Domain knows nothing about menus  
✅ **Dependency Injection** - Repositories injected into menus  
✅ **Single Responsibility** - Each menu handles one domain area  

---

## 📁 Directory Structure

```
lib/presentation/
│
├── controllers/                    # 🎮 Application Controllers
│   └── main_menu_controller.dart   # Main application controller
│                                   # - Initializes data sources
│                                   # - Creates repositories
│                                   # - Manages main menu loop
│                                   # - Routes to sub-menus
│
├── menus/                          # 📋 User Interface Menus
│   ├── base_menu.dart              # Abstract base class
│   │                               # - Menu display loop
│   │                               # - Choice handling template
│   │                               # - Error handling
│   │
│   ├── patient_menu.dart           # 👥 Patient Management (8 options)
│   │                               # - Register patient
│   │                               # - View patient details
│   │                               # - Admit/discharge patient
│   │                               # - Assign doctor
│   │                               # - Schedule meeting
│   │
│   ├── doctor_menu.dart            # 👨‍⚕️ Doctor Management (5 options)
│   │                               # - Add doctor
│   │                               # - View doctor details
│   │                               # - View schedule
│   │                               # - View patient list
│   │
│   ├── nurse_menu.dart             # 👩‍⚕️ Nurse Management (7 options)
│   │                               # - Add nurse
│   │                               # - Assign to patient/room
│   │                               # - View workload
│   │                               # - Transfer assignments
│   │
│   ├── appointment_menu.dart       # 📅 Appointment Management (6 options)
│   │                               # - Schedule appointment
│   │                               # - View appointments
│   │                               # - Reschedule/cancel
│   │                               # - Update status
│   │
│   ├── prescription_menu.dart      # 💊 Prescription Management (6 options)
│   │                               # - Create prescription
│   │                               # - View prescriptions
│   │                               # - Check interactions
│   │                               # - Refill prescription
│   │
│   ├── room_menu.dart              # 🏥 Room & Bed Management (6 options)
│   │                               # - Search available rooms
│   │                               # - Reserve bed
│   │                               # - Transfer patient
│   │                               # - View occupancy
│   │
│   ├── search_menu.dart            # 🔍 Search Operations (6 options)
│   │                               # - Search patients
│   │                               # - Search doctors
│   │                               # - Search appointments
│   │                               # - Search prescriptions
│   │
│   └── emergency_menu.dart         # 🚨 Emergency Operations (4 options)
│                                   # - Admit emergency patient
│                                   # - Find emergency bed
│                                   # - ICU capacity check
│                                   # - Notify emergency staff
│
└── utils/                          # 🛠️ Utility Classes
    ├── input_validator.dart        # Input Validation Utilities
    │                               # - Read/validate strings
    │                               # - Read/validate numbers
    │                               # - Read/validate dates
    │                               # - Read/validate IDs
    │                               # - Read/validate blood type
    │                               # - Read/validate phone/email
    │
    └── ui_helper.dart              # UI Formatting Utilities
                                    # - Clear screen
                                    # - Print headers
                                    # - Print menus
                                    # - Print success/error messages
                                    # - Format tables
                                    # - Press enter to continue
```

---

## 🎮 Menu System

### Menu Hierarchy

```
┌─────────────────────────────────────────────────────────┐
│                     MAIN MENU                           │
│                                                         │
│  1. Patient Management      ──→ PatientMenu            │
│  2. Doctor Management       ──→ DoctorMenu             │
│  3. Appointment Management  ──→ AppointmentMenu        │
│  4. Prescription Management ──→ PrescriptionMenu       │
│  5. Room Management         ──→ RoomMenu               │
│  6. Nurse Management        ──→ NurseMenu              │
│  7. Search Operations       ──→ SearchMenu             │
│  8. Emergency Operations    ──→ EmergencyMenu          │
│  0. Exit                                               │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Menu Flow Pattern

```
┌──────────────────────────────────────────────────────────┐
│  1. Display Menu                                         │
│     - Clear screen                                       │
│     - Show title and options                            │
│                                                          │
│  2. Get User Choice                                      │
│     - Read input                                         │
│     - Validate choice (0-N)                             │
│                                                          │
│  3. Handle Choice                                        │
│     - Route to appropriate handler                      │
│     - Execute business logic                            │
│                                                          │
│  4. Display Result                                       │
│     - Show success message                              │
│     - Show error message                                │
│                                                          │
│  5. Press Enter to Continue                              │
│     - Pause for user to read                            │
│                                                          │
│  6. Loop Back to Step 1                                  │
│     (unless user chose Exit)                            │
└──────────────────────────────────────────────────────────┘
```

---

## 📐 Base Menu Pattern

All menus extend the abstract `BaseMenu` class, providing consistent behavior.

**Location**: `lib/presentation/menus/base_menu.dart`

<details>
<summary><b>📝 View Complete Implementation</b></summary>

```dart
abstract class BaseMenu {
  /// Menu title (e.g., "PATIENT MANAGEMENT")
  String get menuTitle;
  
  /// List of menu options
  List<String> get menuOptions;

  /// Main menu display loop
  Future<void> show() async {
    bool isRunning = true;

    while (isRunning) {
      try {
        // 1. Clear screen
        UIHelper.clearScreen();
        
        // 2. Display menu
        UIHelper.printMenu(menuTitle, menuOptions);

        // 3. Get user choice
        final choice = InputValidator.readChoice(menuOptions.length);
        
        // 4. Check for exit
        if (choice == 0) {
          isRunning = false;
          continue;
        }

        // 5. Handle choice (implemented by subclass)
        await handleChoice(choice);
        
        // 6. Pause
        UIHelper.pressEnterToContinue();
        
      } catch (e) {
        UIHelper.printError('An error occurred: $e');
        UIHelper.pressEnterToContinue();
      }
    }
  }

  /// Abstract method - subclasses must implement
  Future<void> handleChoice(int choice);
}
```

**Benefits**:
- ✅ Consistent UX across all menus
- ✅ Error handling built-in
- ✅ Reduces code duplication
- ✅ Easy to add new menus

**Usage Pattern**:

```dart
class PatientMenu extends BaseMenu {
  @override
  String get menuTitle => 'PATIENT MANAGEMENT';
  
  @override
  List<String> get menuOptions => [
    'Register New Patient',
    'View Patient Details',
    // ... more options
  ];
  
  @override
  Future<void> handleChoice(int choice) async {
    switch (choice) {
      case 1:
        await _registerPatient();
        break;
      case 2:
        await _viewPatientDetails();
        break;
      // ... more cases
    }
  }
}
```

</details>

---

## 📋 All Menus

### 1. 👥 Patient Menu

**Purpose**: Manage patient records and operations

**Location**: `lib/presentation/menus/patient_menu.dart`

<details>
<summary><b>📝 View Menu Options & Features</b></summary>

#### Menu Options

1. **Register New Patient**
   - Collect patient information
   - Validate input (name, DOB, blood type, etc.)
   - Auto-generate patient ID
   - Save to repository

2. **View Patient Details**
   - Enter patient ID
   - Display complete patient information
   - Show assigned doctors, nurses
   - Display current room/bed
   - Show upcoming meetings

3. **Admit Patient**
   - Select patient
   - Choose room and bed
   - Assign to available resources
   - Update patient status

4. **Discharge Patient**
   - Select patient
   - Confirm discharge
   - Clear room/bed assignments
   - Update records

5. **Assign Doctor to Patient**
   - Select patient
   - Choose doctor from list
   - Validate doctor availability
   - Create assignment

6. **Schedule Patient Meeting**
   - Select patient
   - Choose doctor
   - Pick date/time
   - Validate schedule conflicts
   - Create meeting

7. **Reschedule Patient Meeting**
   - Select patient with existing meeting
   - Enter new date/time
   - Validate availability
   - Update meeting

8. **View All Patients**
   - List all patients
   - Show ID, name, status
   - Display admission status

#### Key Features

```dart
class PatientMenu extends BaseMenu {
  final PatientRepository patientRepository;
  final DoctorRepository doctorRepository;
  final RoomRepository roomRepository;

  // Constructor with dependency injection
  PatientMenu({
    required this.patientRepository,
    required this.doctorRepository,
    required this.roomRepository,
  });

  Future<void> _registerPatient() async {
    // Collect input
    final name = InputValidator.readString('Enter patient name');
    final dob = InputValidator.readDate('Enter date of birth');
    final bloodType = InputValidator.readBloodType('Enter blood type');
    // ... more fields
    
    // Create entity
    final patient = Patient(
      patientID: 'AUTO', // Will be auto-generated
      name: name,
      dateOfBirth: dob.toIso8601String(),
      bloodType: bloodType,
      // ... more fields
    );
    
    // Save through repository
    await patientRepository.savePatient(patient);
    
    UIHelper.printSuccess('Patient registered successfully!');
  }
}
```

#### Input Validation

- ✅ Name: Non-empty string
- ✅ Date of Birth: Valid date format (YYYY-MM-DD)
- ✅ Blood Type: A+/A-/B+/B-/AB+/AB-/O+/O-
- ✅ Phone: Valid phone format
- ✅ Patient ID: P### format (auto-generated)
- ✅ Address: Non-empty string
- ✅ Emergency Contact: Valid phone format

</details>

---

### 2. 👨‍⚕️ Doctor Menu

**Purpose**: Manage doctor records and schedules

**Location**: `lib/presentation/menus/doctor_menu.dart`

<details>
<summary><b>📝 View Menu Options</b></summary>

#### Menu Options

1. **Add New Doctor**
   - Enter personal information
   - Select specialization
   - Define working hours
   - Set consultation fee
   - Auto-generate doctor ID (D###)

2. **View Doctor Details**
   - Enter doctor ID
   - Display full profile
   - Show specialization
   - Display working hours
   - List assigned patients

3. **View Doctor Schedule**
   - Select doctor
   - Choose date
   - Display working hours
   - Show appointments
   - Highlight available slots

4. **View Doctor's Patients**
   - Select doctor
   - List all assigned patients
   - Show patient IDs and names
   - Display patient count

5. **List All Doctors**
   - Display all doctors
   - Group by specialization
   - Show patient workload
   - Highlight availability

#### Working Hours Format

```dart
// Example working schedule structure
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

#### Specializations Available

- Cardiology, Neurology, Orthopedics
- Pediatrics, Dermatology, Psychiatry
- Radiology, Anesthesiology, Surgery
- Internal Medicine, Obstetrics
- Ophthalmology, ENT, Urology
- Emergency Medicine

</details>

---

### 3. 👩‍⚕️ Nurse Menu

**Purpose**: Manage nursing staff and assignments

**Location**: `lib/presentation/menus/nurse_menu.dart`

<details>
<summary><b>📝 View Menu Options</b></summary>

#### Menu Options

1. **Add New Nurse**
   - Personal information
   - Select shift (Morning/Afternoon/Night)
   - Choose specializations
   - Auto-generate nurse ID (N###)

2. **Assign Nurse to Patient**
   - Select nurse
   - Choose patient
   - Validate workload (max 5 patients)
   - Create assignment

3. **Assign Nurse to Room**
   - Select nurse
   - Choose room
   - Validate workload (max 4 rooms)
   - Create assignment

4. **Remove Nurse Assignment**
   - Select nurse
   - Choose assignment to remove
   - Update workload

5. **Transfer Nurse Between Rooms**
   - Select nurse
   - Choose source room
   - Choose destination room
   - Update assignments

6. **View Nurse Workload**
   - Select nurse
   - Display assigned patients
   - Display assigned rooms
   - Show workload percentage
   - Highlight if overloaded

7. **View Available Nurses**
   - Filter by shift
   - Show workload < 80%
   - Display availability

#### Nurse Shifts

```dart
enum NurseShift {
  MORNING,    // 06:00 - 14:00
  AFTERNOON,  // 14:00 - 22:00
  NIGHT,      // 22:00 - 06:00
}
```

#### Workload Calculation

```dart
Workload = (Patients / 5) * 70% + (Rooms / 4) * 30%

Available: < 80%
Full Load: 80-100%
Overloaded: > 100%
```

</details>

---

### 4. 📅 Appointment Menu

**Purpose**: Manage patient-doctor appointments

**Location**: `lib/presentation/menus/appointment_menu.dart`

<details>
<summary><b>📝 View Menu Options</b></summary>

#### Menu Options

1. **Schedule New Appointment**
   - Select patient
   - Choose doctor
   - Pick date and time
   - Set duration (15-240 minutes)
   - Enter reason
   - Validate conflicts
   - Auto-generate appointment ID

2. **View Appointment Details**
   - Enter appointment ID
   - Display full information
   - Show patient and doctor
   - Display status
   - Show notes

3. **View Appointments by Patient**
   - Enter patient ID
   - List all appointments
   - Filter by status
   - Sort by date

4. **View Appointments by Doctor**
   - Enter doctor ID
   - List all appointments
   - Show schedule conflicts
   - Display availability

5. **Reschedule Appointment**
   - Select appointment
   - Enter new date/time
   - Validate availability
   - Update appointment

6. **Cancel Appointment**
   - Select appointment
   - Enter cancellation reason
   - Update status to CANCELLED

#### Appointment Status Lifecycle

```
SCHEDULE (new) → IN_PROGRESS (ongoing) → COMPLETED (finished)
     ↓                    ↓
CANCELLED           CANCELLED
     ↓
 NO_SHOW (if patient doesn't show up)
```

#### Validation Rules

- ✅ Appointment must be in the future
- ✅ Duration: 15-240 minutes
- ✅ Doctor must be available at that time
- ✅ No conflicting appointments for doctor
- ✅ Within doctor's working hours
- ✅ Not during doctor's break time

</details>

---

### 5. 💊 Prescription Menu

**Purpose**: Manage medication prescriptions

**Location**: `lib/presentation/menus/prescription_menu.dart`

<details>
<summary><b>📝 View Menu Options</b></summary>

#### Menu Options

1. **Create New Prescription**
   - Select patient
   - Choose doctor
   - Add medications (one or multiple)
   - Enter dosage and frequency
   - Add instructions
   - Auto-generate prescription ID

2. **View Prescription Details**
   - Enter prescription ID
   - Display full prescription
   - Show all medications
   - Display instructions

3. **View Patient's Prescriptions**
   - Enter patient ID
   - List all prescriptions
   - Filter by status (active/completed)
   - Show medication details

4. **View Doctor's Prescriptions**
   - Enter doctor ID
   - List all prescriptions written
   - Group by patient
   - Show prescription count

5. **Check Drug Interactions**
   - Enter medication names
   - Check for known interactions
   - Display warnings
   - Suggest alternatives

6. **Refill Prescription**
   - Select existing prescription
   - Create new prescription with same meds
   - Update issue date
   - Generate new prescription ID

#### Medication Structure

```dart
class Medication {
  final String id;           // M001, M002, etc.
  final String name;         // Medication name
  final String type;         // Tablet, Syrup, Injection
  final double strength;     // Dosage strength
  final String unit;         // mg, ml, etc.
  final String manufacturer;
  final double price;
}
```

#### Prescription Example

```
Prescription ID: PR045
Patient: Sok Pisey (P001)
Doctor: Dr. Sopheak Chan (D001)
Date: 2025-11-03

Medications:
1. Amoxicillin 500mg
   - Dosage: 1 tablet
   - Frequency: 3 times daily
   - Duration: 7 days
   
2. Vitamin C 1000mg
   - Dosage: 1 tablet
   - Frequency: Once daily
   - Duration: 30 days

Instructions: Take with food. Complete full course.
```

</details>

---

### 6. 🏥 Room Menu

**Purpose**: Manage hospital rooms and beds

**Location**: `lib/presentation/menus/room_menu.dart`

<details>
<summary><b>📝 View Menu Options</b></summary>

#### Menu Options

1. **Search Available Rooms**
   - Filter by room type (General/Private/ICU/Emergency)
   - Filter by floor
   - Show available beds
   - Display room features

2. **Search Available Beds**
   - Filter by bed type (Standard/ICU/Pediatric)
   - Show room information
   - Display occupancy status

3. **View ICU Capacity**
   - Show total ICU beds
   - Display occupied beds
   - Show available capacity
   - List critical patients

4. **Reserve Bed for Patient**
   - Select patient
   - Choose room
   - Select specific bed
   - Update occupancy status

5. **Transfer Patient**
   - Select patient
   - Choose new room/bed
   - Validate availability
   - Update assignments
   - Clear old bed

6. **View Room Occupancy**
   - Display all rooms
   - Show occupancy rates
   - Highlight fully occupied
   - Show available rooms

#### Room Types

```dart
enum RoomType {
  GENERAL,     // Standard ward rooms
  PRIVATE,     // Private rooms
  ICU,         // Intensive Care Unit
  EMERGENCY,   // Emergency rooms
}
```

#### Bed Types

```dart
enum BedType {
  STANDARD,    // Regular hospital bed
  ICU,         // ICU bed with monitoring
  PEDIATRIC,   // Children's bed
}
```

#### Room Display Example

```
Room: R101 (General Ward)
Floor: 1
Capacity: 4 beds
Status: AVAILABLE

Beds:
  - B101-1: OCCUPIED (Patient P001 - Sok Pisey)
  - B101-2: OCCUPIED (Patient P005 - Chea Sokha)
  - B101-3: AVAILABLE
  - B101-4: AVAILABLE

Occupancy: 50% (2/4)
```

</details>

---

### 7. 🔍 Search Menu

**Purpose**: Advanced search across all entities

**Location**: `lib/presentation/menus/search_menu.dart`

<details>
<summary><b>📝 View Menu Options</b></summary>

#### Menu Options

1. **Search Patients**
   - By name (partial match)
   - By blood type
   - By assigned doctor
   - By room/admission status
   - By age range

2. **Search Doctors**
   - By name
   - By specialization
   - By department
   - By availability
   - By patient workload

3. **Search Appointments**
   - By patient
   - By doctor
   - By date range
   - By status
   - By upcoming/past

4. **Search Prescriptions**
   - By patient
   - By doctor
   - By medication
   - By date range
   - By active/inactive status

5. **Search Rooms**
   - By type
   - By availability
   - By floor
   - By occupancy rate

6. **Search Medical Records**
   - By patient
   - By date range
   - By keywords
   - By diagnosis

#### Advanced Search Example

```dart
// Search patients by multiple criteria
final results = await patientRepository.advancedSearch(
  name: 'Sok',
  bloodType: 'O+',
  isAdmitted: true,
  minAge: 18,
  maxAge: 65,
);

// Display results
UIHelper.printSearchResults(results);
```

</details>

---

### 8. 🚨 Emergency Menu

**Purpose**: Handle emergency admissions and triage

**Location**: `lib/presentation/menus/emergency_menu.dart`

<details>
<summary><b>📝 View Menu Options</b></summary>

#### Menu Options

1. **Admit Emergency Patient**
   - Capture minimal patient info (fast entry)
   - Auto-assign emergency room
   - Auto-assign available doctor
   - Find available ICU bed (if critical)
   - Auto-generate patient ID
   - Priority admission

2. **Find Emergency Bed**
   - Check ICU availability
   - Check emergency room availability
   - Show closest available bed
   - Display wait times

3. **View ICU Capacity**
   - Total ICU beds
   - Available ICU beds
   - Critical patients
   - Estimated availability time

4. **Notify Emergency Staff**
   - Alert available doctors
   - Alert nurses on duty
   - Display emergency team
   - Show response times

#### Emergency Levels

```dart
enum EmergencyLevel {
  CRITICAL,      // Life-threatening - immediate attention
  URGENT,        // Serious - attention within 30 min
  MODERATE,      // Can wait 1-2 hours
  NON_URGENT,    // Can wait several hours
}
```

#### Fast Admission Flow

```
1. Capture Essential Info Only (2 minutes)
   - Name
   - Age/DOB
   - Emergency contact
   - Emergency reason
   - Emergency level

2. Auto-Assign Resources (< 30 seconds)
   - Find available ICU/Emergency room
   - Assign first available doctor
   - Assign emergency nurse
   - Generate patient ID

3. Admit Patient Immediately
   - Update room status
   - Alert medical staff
   - Start medical record
```

</details>

---

## 🎮 Controllers

### Main Menu Controller

**Purpose**: Application entry point and dependency setup

**Location**: `lib/presentation/controllers/main_menu_controller.dart`

<details>
<summary><b>📝 View Complete Structure</b></summary>

```dart
class MainMenuController {
  // ========== Data Sources ==========
  late final PatientLocalDataSource _patientLocalDataSource;
  late final DoctorLocalDataSource _doctorLocalDataSource;
  late final RoomLocalDataSource _roomLocalDataSource;
  late final BedLocalDataSource _bedLocalDataSource;
  late final NurseLocalDataSource _nurseLocalDataSource;
  late final PrescriptionLocalDataSource _prescriptionLocalDataSource;
  late final AppointmentLocalDataSource _appointmentLocalDataSource;
  late final EquipmentLocalDataSource _equipmentLocalDataSource;
  late final MedicationLocalDataSource _medicationLocalDataSource;

  // ========== Repositories ==========
  late final PatientRepository _patientRepository;
  late final DoctorRepository _doctorRepository;
  late final RoomRepository _roomRepository;
  late final NurseRepository _nurseRepository;
  late final PrescriptionRepository _prescriptionRepository;
  late final AppointmentRepository _appointmentRepository;

  /// Constructor with optional dependency injection (for testing)
  MainMenuController({
    PatientRepository? patientRepository,
    DoctorRepository? doctorRepository,
    RoomRepository? roomRepository,
    NurseRepository? nurseRepository,
    PrescriptionRepository? prescriptionRepository,
    AppointmentRepository? appointmentRepository,
  }) {
    // Initialize data sources first
    _initializeDataSources();

    // Then initialize repositories with data sources
    _patientRepository = patientRepository ??
        PatientRepositoryImpl(
          patientDataSource: _patientLocalDataSource,
          doctorDataSource: _doctorLocalDataSource,
        );

    _doctorRepository = doctorRepository ??
        DoctorRepositoryImpl(
          doctorDataSource: _doctorLocalDataSource,
          patientDataSource: _patientLocalDataSource,
        );

    _roomRepository = roomRepository ??
        RoomRepositoryImpl(
          roomDataSource: _roomLocalDataSource,
          bedDataSource: _bedLocalDataSource,
          equipmentDataSource: _equipmentLocalDataSource,
          patientDataSource: _patientLocalDataSource,
        );

    // ... other repositories
  }

  void _initializeDataSources() {
    _patientLocalDataSource = PatientLocalDataSource();
    _doctorLocalDataSource = DoctorLocalDataSource();
    _roomLocalDataSource = RoomLocalDataSource();
    _bedLocalDataSource = BedLocalDataSource();
    _nurseLocalDataSource = NurseLocalDataSource();
    _prescriptionLocalDataSource = PrescriptionLocalDataSource();
    _appointmentLocalDataSource = AppointmentLocalDataSource();
    _equipmentLocalDataSource = EquipmentLocalDataSource();
    _medicationLocalDataSource = MedicationLocalDataSource();
  }

  /// Main application loop
  Future<void> run() async {
    bool isRunning = true;

    while (isRunning) {
      try {
        UIHelper.printApplicationHeader();
        UIHelper.printMenu('MAIN MENU', _menuOptions);

        final choice = InputValidator.readChoice(_menuOptions.length);

        switch (choice) {
          case 1:
            await PatientMenu(
              patientRepository: _patientRepository,
              doctorRepository: _doctorRepository,
              roomRepository: _roomRepository,
            ).show();
            break;
          case 2:
            await DoctorMenu(
              doctorRepository: _doctorRepository,
              patientRepository: _patientRepository,
            ).show();
            break;
          // ... other menu cases
          case 0:
            isRunning = false;
            UIHelper.printGoodbye();
            break;
        }
      } catch (e) {
        UIHelper.printError('An error occurred: $e');
        UIHelper.pressEnterToContinue();
      }
    }
  }
}
```

**Responsibilities**:
- ✅ Create all data sources
- ✅ Create all repositories with proper dependencies
- ✅ Display main menu
- ✅ Route to appropriate sub-menus
- ✅ Handle top-level errors
- ✅ Clean application exit

</details>

---

## 🛠️ Utilities

### 1. Input Validator

**Purpose**: Validate and sanitize user input

**Location**: `lib/presentation/utils/input_validator.dart`

<details>
<summary><b>📝 View All Validation Methods</b></summary>

```dart
class InputValidator {
  /// Read and validate string input
  static String readString(String prompt, {bool allowEmpty = false}) {
    while (true) {
      stdout.write('$prompt: ');
      final input = stdin.readLineSync()?.trim() ?? '';

      if (input.isEmpty && !allowEmpty) {
        print('❌ Input cannot be empty. Please try again.');
        continue;
      }

      return input;
    }
  }

  /// Read and validate integer input
  static int readInt(String prompt, {int? min, int? max}) {
    while (true) {
      stdout.write('$prompt: ');
      final input = stdin.readLineSync()?.trim() ?? '';

      final number = int.tryParse(input);
      if (number == null) {
        print('❌ Please enter a valid number.');
        continue;
      }

      if (min != null && number < min) {
        print('❌ Number must be at least $min.');
        continue;
      }

      if (max != null && number > max) {
        print('❌ Number must be at most $max.');
        continue;
      }

      return number;
    }
  }

  /// Read and validate date (YYYY-MM-DD format)
  static DateTime readDate(String prompt) {
    while (true) {
      stdout.write('$prompt (YYYY-MM-DD): ');
      final input = stdin.readLineSync()?.trim() ?? '';

      try {
        final date = DateTime.parse(input);
        return date;
      } catch (e) {
        print('❌ Invalid date format. Use YYYY-MM-DD.');
      }
    }
  }

  /// Read and validate menu choice
  static int readChoice(int maxChoice) {
    while (true) {
      stdout.write('\nEnter your choice (0-$maxChoice): ');
      final input = stdin.readLineSync()?.trim() ?? '';

      final choice = int.tryParse(input);
      if (choice == null || choice < 0 || choice > maxChoice) {
        print('❌ Please enter a number between 0 and $maxChoice.');
        continue;
      }

      return choice;
    }
  }

  /// Read yes/no boolean
  static bool readBoolean(String prompt) {
    while (true) {
      stdout.write('$prompt (y/n): ');
      final input = stdin.readLineSync()?.trim().toLowerCase() ?? '';

      if (input == 'y' || input == 'yes') return true;
      if (input == 'n' || input == 'no') return false;

      print('❌ Please enter y or n.');
    }
  }

  /// Read and validate ID with specific format
  static String readId(String prompt, String prefix) {
    while (true) {
      stdout.write('$prompt (format: ${prefix}XXX): ');
      final input = stdin.readLineSync()?.trim().toUpperCase() ?? '';

      if (!input.startsWith(prefix)) {
        print('❌ ID must start with $prefix.');
        continue;
      }

      if (input.length != prefix.length + 3) {
        print('❌ Invalid format. Use ${prefix}XXX where X is a number.');
        continue;
      }

      return input;
    }
  }

  /// Read and validate time (HH:MM format)
  static String readTime(String prompt) {
    while (true) {
      stdout.write('$prompt (HH:MM): ');
      final input = stdin.readLineSync()?.trim() ?? '';

      if (RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(input)) {
        return input;
      }

      print('❌ Invalid time format. Use HH:MM (24-hour format).');
    }
  }

  /// Read and validate email
  static String readEmail(String prompt) {
    while (true) {
      stdout.write('$prompt: ');
      final input = stdin.readLineSync()?.trim() ?? '';

      if (RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(input)) {
        return input;
      }

      print('❌ Invalid email format.');
    }
  }

  /// Read and validate phone number
  static String readPhone(String prompt) {
    while (true) {
      stdout.write('$prompt: ');
      final input = stdin.readLineSync()?.trim() ?? '';

      if (RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(input)) {
        return input;
      }

      print('❌ Invalid phone number format.');
    }
  }

  /// Read and validate blood type
  static String readBloodType(String prompt) {
    final validTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

    while (true) {
      stdout.write('$prompt ${validTypes.join('/')}: ');
      final input = stdin.readLineSync()?.trim().toUpperCase() ?? '';

      if (validTypes.contains(input)) {
        return input;
      }

      print('❌ Invalid blood type. Use: ${validTypes.join(", ")}');
    }
  }

  /// Read multiple lines of text
  static List<String> readMultipleLines(
    String prompt,
    {String endMarker = 'END'}
  ) {
    print('$prompt (type $endMarker on a new line when finished):');
    final lines = <String>[];

    while (true) {
      final input = stdin.readLineSync()?.trim() ?? '';
      if (input.toUpperCase() == endMarker) break;
      lines.add(input);
    }

    return lines;
  }
}
```

**Features**:
- ✅ Loop until valid input received
- ✅ Clear error messages
- ✅ Regex validation for complex formats
- ✅ Range validation for numbers
- ✅ Type-safe returns
- ✅ Consistent user experience

</details>

---

### 2. UI Helper

**Purpose**: Format and display console output

**Location**: `lib/presentation/utils/ui_helper.dart`

<details>
<summary><b>📝 View All Helper Methods</b></summary>

```dart
class UIHelper {
  /// Clear console screen (cross-platform)
  static void clearScreen() {
    if (Platform.isWindows) {
      print(Process.runSync("cls", [], runInShell: true).stdout);
    } else {
      print(Process.runSync("clear", [], runInShell: true).stdout);
    }
  }

  /// Print application header
  static void printApplicationHeader() {
    clearScreen();
    print('╔════════════════════════════════════════════╗');
    print('║   HOSPITAL MANAGEMENT SYSTEM               ║');
    print('║   Version 1.0.0                            ║');
    print('╚════════════════════════════════════════════╝');
    print('');
  }

  /// Print menu with options
  static void printMenu(String title, List<String> options) {
    print('');
    print('═══════════════════════════════════════════');
    print('  $title');
    print('═══════════════════════════════════════════');
    print('');

    for (int i = 0; i < options.length; i++) {
      print('  ${i + 1}. ${options[i]}');
    }
    print('  0. Back / Exit');
    print('');
    print('═══════════════════════════════════════════');
  }

  /// Print success message
  static void printSuccess(String message) {
    print('');
    print('✅ SUCCESS: $message');
    print('');
  }

  /// Print error message
  static void printError(String message) {
    print('');
    print('❌ ERROR: $message');
    print('');
  }

  /// Print warning message
  static void printWarning(String message) {
    print('');
    print('⚠️  WARNING: $message');
    print('');
  }

  /// Print info message
  static void printInfo(String message) {
    print('');
    print('ℹ️  INFO: $message');
    print('');
  }

  /// Pause and wait for enter key
  static void pressEnterToContinue() {
    print('');
    stdout.write('Press ENTER to continue...');
    stdin.readLineSync();
  }

  /// Print section header
  static void printSectionHeader(String title) {
    print('');
    print('─────────────────────────────────────────');
    print('  $title');
    print('─────────────────────────────────────────');
  }

  /// Print goodbye message
  static void printGoodbye() {
    clearScreen();
    print('');
    print('╔════════════════════════════════════════════╗');
    print('║   Thank you for using                      ║');
    print('║   HOSPITAL MANAGEMENT SYSTEM               ║');
    print('║                                            ║');
    print('║   Goodbye! 👋                              ║');
    print('╚════════════════════════════════════════════╝');
    print('');
  }

  /// Print table header
  static void printTableHeader(List<String> headers) {
    final headerRow = headers.map((h) => h.padRight(15)).join(' │ ');
    print('');
    print(headerRow);
    print('─' * (headers.length * 17));
  }

  /// Print table row
  static void printTableRow(List<String> cells) {
    final row = cells.map((c) => c.padRight(15)).join(' │ ');
    print(row);
  }

  /// Print divider line
  static void printDivider() {
    print('═══════════════════════════════════════════');
  }
}
```

**Features**:
- ✅ Cross-platform screen clearing
- ✅ Consistent formatting
- ✅ Box drawing characters
- ✅ Emoji indicators
- ✅ Table formatting
- ✅ Professional appearance

</details>

---

## 🔄 User Flow

### Complete User Journey Example

<details>
<summary><b>📝 View Complete Flow: Schedule Appointment</b></summary>

```
1. Application Start
   └─> MainMenuController.run()
       └─> Display MAIN MENU
       
2. User Selects "3. Appointment Management"
   └─> Create AppointmentMenu instance
       └─> Inject repositories
       └─> Call menu.show()
       
3. Appointment Menu Displays
   ┌────────────────────────────────────┐
   │  APPOINTMENT MANAGEMENT            │
   ├────────────────────────────────────┤
   │  1. Schedule New Appointment       │
   │  2. View Appointment Details       │
   │  3. View Appointments by Patient   │
   │  4. View Appointments by Doctor    │
   │  5. Reschedule Appointment         │
   │  6. Cancel Appointment             │
   │  0. Back                           │
   └────────────────────────────────────┘
   
4. User Selects "1. Schedule New Appointment"
   └─> AppointmentMenu._scheduleAppointment()
   
5. Collect Patient Information
   Enter patient ID (format: PXXX): P001
   └─> InputValidator.readId('Enter patient ID', 'P')
       └─> Validate format
       └─> Return: "P001"
   
6. Fetch and Display Patient
   └─> patientRepository.getPatientById('P001')
       └─> Display: "Sok Pisey (P001)"
   
7. Collect Doctor Information
   Enter doctor ID (format: DXXX): D005
   └─> InputValidator.readId('Enter doctor ID', 'D')
       └─> Validate format
       └─> Return: "D005"
   
8. Fetch and Display Doctor
   └─> doctorRepository.getDoctorById('D005')
       └─> Display: "Dr. Sopheak Chan - Cardiology"
   
9. Collect Appointment Date
   Enter appointment date (YYYY-MM-DD): 2025-11-15
   └─> InputValidator.readDate('Enter appointment date')
       └─> Validate format
       └─> Check future date
       └─> Return: DateTime(2025, 11, 15)
   
10. Collect Appointment Time
    Enter appointment time (HH:MM): 10:00
    └─> InputValidator.readTime('Enter appointment time')
        └─> Validate format (HH:MM)
        └─> Return: "10:00"
    
11. Combine Date and Time
    └─> DateTime(2025, 11, 15, 10, 0)
    
12. Collect Duration
    Enter duration in minutes (15-240): 30
    └─> InputValidator.readInt('Enter duration', min: 15, max: 240)
        └─> Validate range
        └─> Return: 30
    
13. Collect Reason
    Enter appointment reason: Regular checkup
    └─> InputValidator.readString('Enter appointment reason')
        └─> Return: "Regular checkup"
    
14. Create Appointment Entity
    └─> Appointment(
          id: 'AUTO',
          dateTime: DateTime(2025, 11, 15, 10, 0),
          duration: 30,
          patient: patient,
          doctor: doctor,
          status: AppointmentStatus.SCHEDULE,
          reason: 'Regular checkup',
        )
    
15. Save Appointment
    └─> appointmentRepository.saveAppointment(appointment)
        └─> Validate doctor availability
        └─> Check conflicts
        └─> Generate appointment ID: A127
        └─> Save to JSON file
    
16. Display Success
    ✅ SUCCESS: Appointment A127 scheduled successfully!
    
    Appointment Details:
    ─────────────────────────────────────
    ID: A127
    Patient: Sok Pisey (P001)
    Doctor: Dr. Sopheak Chan (D005)
    Date: November 15, 2025
    Time: 10:00 AM
    Duration: 30 minutes
    Reason: Regular checkup
    Status: SCHEDULED
    ─────────────────────────────────────
    
17. Pause
    Press ENTER to continue...
    └─> User presses Enter
    
18. Return to Appointment Menu
    └─> Loop back to step 3
    
19. User Selects "0. Back"
    └─> Exit AppointmentMenu
    └─> Return to MAIN MENU
```

</details>

---

## ✅ Best Practices

### 1. Always Validate Input

```dart
// ✅ GOOD - Validate before using
final patientId = InputValidator.readId('Enter patient ID', 'P');
final patient = await patientRepository.getPatientById(patientId);

// ❌ BAD - No validation
stdout.write('Enter patient ID: ');
final patientId = stdin.readLineSync()!;
final patient = await patientRepository.getPatientById(patientId); // May fail!
```

### 2. Use Dependency Injection

```dart
// ✅ GOOD - Inject dependencies
class PatientMenu extends BaseMenu {
  final PatientRepository patientRepository;
  
  PatientMenu({required this.patientRepository});
}

// ❌ BAD - Create dependencies inside
class PatientMenu extends BaseMenu {
  final patientRepository = PatientRepositoryImpl(); // Hard to test!
}
```

### 3. Handle Errors Gracefully

```dart
// ✅ GOOD - Catch and display errors
try {
  await patientRepository.savePatient(patient);
  UIHelper.printSuccess('Patient saved successfully!');
} catch (e) {
  UIHelper.printError('Failed to save patient: $e');
}

// ❌ BAD - Let errors crash the app
await patientRepository.savePatient(patient);
print('Saved'); // Never executes if error occurs!
```

### 4. Clear Screen for Better UX

```dart
// ✅ GOOD - Clear before displaying menu
UIHelper.clearScreen();
UIHelper.printMenu(menuTitle, menuOptions);

// ❌ BAD - Cluttered output
print('Menu Title');
for (var option in menuOptions) print(option);
```

### 5. Use Consistent Formatting

```dart
// ✅ GOOD - Use UIHelper methods
UIHelper.printSuccess('Operation completed');
UIHelper.printError('Operation failed');
UIHelper.printWarning('Please review');

// ❌ BAD - Inconsistent formatting
print('✅ Success');
print('ERROR: Failed');
print('Warning!');
```

### 6. Extend BaseMenu

```dart
// ✅ GOOD - Extend base class
class PatientMenu extends BaseMenu {
  @override
  String get menuTitle => 'PATIENT MANAGEMENT';
  
  @override
  List<String> get menuOptions => ['Register', 'View', ...];
  
  @override
  Future<void> handleChoice(int choice) async { ... }
}

// ❌ BAD - Duplicate menu logic
class PatientMenu {
  Future<void> show() async {
    // Duplicate entire menu loop logic...
  }
}
```

---

## 📚 Further Reading

- [Console I/O in Dart](https://dart.dev/tutorials/server/cmdline)
- [Command Pattern](https://refactoring.guru/design-patterns/command)
- [MVC Pattern](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller)
- [Input Validation Best Practices](https://owasp.org/www-project-proactive-controls/v3/en/c5-validate-inputs)

---

<div align="center">

**[⬆ Back to Top](#-presentation-layer---complete-guide)**

Made with ❤️ for Hospital Management System

</div>
