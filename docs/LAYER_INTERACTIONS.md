# 🔄 Layer Interactions - Complete Guide

<div align="center">

**Understanding How Layers Communicate**

*Data Flow | Dependency Flow | Integration Patterns*

[![Architecture](https://img.shields.io/badge/Architecture-Clean-blue?style=for-the-badge)]()
[![Layers](https://img.shields.io/badge/Layers-3-success?style=for-the-badge)]()

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [The Dependency Rule](#-the-dependency-rule)
- [Data Flow Patterns](#-data-flow-patterns)
- [Real-World Examples](#-real-world-examples)
- [Layer Communication](#-layer-communication)
- [Best Practices](#-best-practices)

---

## 🌟 Overview

This guide explains how the three layers (Presentation, Domain, Data) interact while maintaining Clean Architecture principles.

### The Three Layers

```
┌─────────────────────────────────────────────────────────┐
│                  PRESENTATION LAYER                     │
│          (Menus, Controllers, UI Logic)                 │
│                                                         │
│  Depends on: Domain                                     │
│  Depended by: None                                      │
└────────────────────────┬────────────────────────────────┘
                         │ depends on (uses)
┌────────────────────────▼────────────────────────────────┐
│                    DOMAIN LAYER                         │
│         (Entities, Use Cases, Repositories)             │
│                                                         │
│  Depends on: Nothing!                                   │
│  Depended by: Presentation, Data                        │
└────────────────────────▲────────────────────────────────┘
                         │ implements
┌────────────────────────┴────────────────────────────────┐
│                     DATA LAYER                          │
│        (Models, Data Sources, Repo Impl)                │
│                                                         │
│  Depends on: Domain                                     │
│  Depended by: None (injected to Presentation)           │
└─────────────────────────────────────────────────────────┘
```

---

## 🎯 The Dependency Rule

> **Dependencies point inward. Inner layers know nothing about outer layers.**

### What This Means

```
✅ Presentation CAN import Domain
✅ Data CAN import Domain
✅ Domain is Pure (no imports from other layers)

❌ Domain CANNOT import Presentation
❌ Domain CANNOT import Data
❌ Data CANNOT import Presentation
```

### Why This Matters

1. **Domain Stability** - Business logic never changes due to UI changes
2. **Testability** - Domain can be tested without UI or database
3. **Flexibility** - Swap UI (console → web) without touching domain
4. **Maintainability** - Clear separation prevents spaghetti code

---

## 🔄 Data Flow Patterns

### Pattern 1: Save Operation (Presentation → Domain → Data)

```
USER ACTION: Register New Patient
         │
         ▼
┌─────────────────────────────────────────────────────┐
│  PRESENTATION: PatientMenu._registerPatient()      │
│                                                     │
│  1. Collect user input (name, DOB, etc.)           │
│  2. Validate input format                          │
│  3. Create Patient entity                          │
│  4. Call repository.savePatient(patient)           │
└──────────────────────┬──────────────────────────────┘
                       │ calls
                       ▼
┌─────────────────────────────────────────────────────┐
│  DOMAIN: PatientRepository.savePatient()            │
│          (interface - just contract)                │
│                                                     │
│  abstract Future<void> savePatient(Patient p);     │
└──────────────────────┬──────────────────────────────┘
                       │ implemented by
                       ▼
┌─────────────────────────────────────────────────────┐
│  DATA: PatientRepositoryImpl.savePatient()          │
│                                                     │
│  1. Check if ID is AUTO → generate ID               │
│  2. Convert Patient entity → PatientModel           │
│  3. Call data source to save                        │
│  4. Write to JSON file                              │
└──────────────────────┬──────────────────────────────┘
                       │ writes to
                       ▼
                 patients.json
```

**Code Example**:

```dart
// PRESENTATION LAYER
Future<void> _registerPatient() async {
  // Step 1: Collect input
  final name = InputValidator.readString('Enter patient name');
  final dob = InputValidator.readDate('Enter date of birth');
  
  // Step 2: Create entity (Domain object)
  final patient = Patient(
    patientID: 'AUTO',
    name: name,
    dateOfBirth: dob.toIso8601String(),
    // ...
  );
  
  // Step 3: Call repository (Domain interface)
  await patientRepository.savePatient(patient);
  
  // Step 4: Display result
  UIHelper.printSuccess('Patient registered!');
}

// DOMAIN LAYER (Interface)
abstract class PatientRepository {
  Future<void> savePatient(Patient patient);
}

// DATA LAYER (Implementation)
class PatientRepositoryImpl implements PatientRepository {
  @override
  Future<void> savePatient(Patient patient) async {
    // Generate ID if needed
    if (patient.patientID == 'AUTO') {
      final id = IdGenerator.generatePatientId(allPatients);
      patient = patient.copyWith(patientID: id);
    }
    
    // Convert Entity → Model
    final model = PatientModel.fromEntity(patient);
    
    // Save to data source
    await _dataSource.add(model);
  }
}
```

---

### Pattern 2: Load Operation (Data → Domain → Presentation)

```
USER ACTION: View Patient Details
         │
         ▼
┌─────────────────────────────────────────────────────┐
│  PRESENTATION: PatientMenu._viewPatientDetails()    │
│                                                     │
│  1. Get patient ID from user                        │
│  2. Call repository.getPatientById(id)              │
│  3. Display patient information                     │
└──────────────────────┬──────────────────────────────┘
                       │ calls
                       ▼
┌─────────────────────────────────────────────────────┐
│  DOMAIN: PatientRepository.getPatientById()         │
│          (interface - just contract)                │
│                                                     │
│  abstract Future<Patient> getPatientById(String);  │
└──────────────────────┬──────────────────────────────┘
                       │ implemented by
                       ▼
┌─────────────────────────────────────────────────────┐
│  DATA: PatientRepositoryImpl.getPatientById()       │
│                                                     │
│  1. Read from JSON file                             │
│  2. Find patient model by ID                        │
│  3. Fetch related entities (doctors, nurses)        │
│  4. Convert PatientModel → Patient entity           │
│  5. Return entity                                   │
└──────────────────────┬──────────────────────────────┘
                       │ reads from
                       ▼
                 patients.json
```

**Code Example**:

```dart
// PRESENTATION LAYER
Future<void> _viewPatientDetails() async {
  // Step 1: Get ID from user
  final patientId = InputValidator.readId('Enter patient ID', 'P');
  
  // Step 2: Load patient (Domain entity returned)
  final patient = await patientRepository.getPatientById(patientId);
  
  // Step 3: Display information
  UIHelper.printSectionHeader('PATIENT DETAILS');
  print('ID: ${patient.patientID}');
  print('Name: ${patient.name}');
  print('Blood Type: ${patient.bloodType}');
  print('Age: ${patient.age} years');
  
  print('\nAssigned Doctors:');
  for (var doctor in patient.assignedDoctors) {
    print('  - ${doctor.name} (${doctor.specialization})');
  }
}

// DATA LAYER (Implementation)
class PatientRepositoryImpl implements PatientRepository {
  @override
  Future<Patient> getPatientById(String id) async {
    // Step 1: Read from data source
    final model = await _dataSource.findByPatientID(id);
    
    if (model == null) {
      throw Exception('Patient not found');
    }
    
    // Step 2: Fetch related entities
    final doctorModels = await _doctorDataSource
        .findDoctorsByIds(model.assignedDoctorIds);
    final doctors = doctorModels.map((dm) => dm.toEntity()).toList();
    
    // Step 3: Convert Model → Entity
    return model.toEntity(assignedDoctors: doctors);
  }
}
```

---

### Pattern 3: Business Logic Operation (Use Case Pattern)

```
USER ACTION: Schedule Appointment
         │
         ▼
┌─────────────────────────────────────────────────────┐
│  PRESENTATION: AppointmentMenu._scheduleAppt()      │
│                                                     │
│  1. Collect input (patient, doctor, time)           │
│  2. Create AppointmentInput DTO                     │
│  3. Call use case.execute(input)                    │
│  4. Display result                                  │
└──────────────────────┬──────────────────────────────┘
                       │ calls
                       ▼
┌─────────────────────────────────────────────────────┐
│  DOMAIN: ScheduleAppointment (Use Case)             │
│                                                     │
│  1. Validate input (dates, conflicts, etc.)         │
│  2. Load Patient entity (via repository)            │
│  3. Load Doctor entity (via repository)             │
│  4. Check doctor availability                       │
│  5. Check for scheduling conflicts                  │
│  6. Create Appointment entity                       │
│  7. Save via repository                             │
│  8. Return result                                   │
└───────────┬──────────────────┬──────────────────────┘
            │                  │
            │ uses             │ uses
            ▼                  ▼
  PatientRepository    AppointmentRepository
            │                  │
            │ implemented by   │ implemented by
            ▼                  ▼
┌───────────────────────────────────────────────────────┐
│  DATA LAYER: Repository Implementations               │
│                                                       │
│  - Read/Write JSON files                              │
│  - Convert between entities and models                │
│  - Handle relationships                               │
└───────────────────────────────────────────────────────┘
```

**Code Example**:

```dart
// PRESENTATION LAYER
Future<void> _scheduleAppointment() async {
  // Collect input
  final patientId = InputValidator.readId('Patient ID', 'P');
  final doctorId = InputValidator.readId('Doctor ID', 'D');
  final dateTime = InputValidator.readDate('Date');
  final duration = InputValidator.readInt('Duration', min: 15, max: 240);
  
  // Create input DTO
  final input = AppointmentInput(
    patientId: patientId,
    doctorId: doctorId,
    dateTime: dateTime,
    duration: duration,
    reason: 'Regular checkup',
  );
  
  // Execute use case
  final appointment = await scheduleAppointmentUseCase(input);
  
  UIHelper.printSuccess('Appointment ${appointment.id} scheduled!');
}

// DOMAIN LAYER (Use Case)
class ScheduleAppointment extends UseCase<AppointmentInput, Appointment> {
  final PatientRepository _patientRepository;
  final DoctorRepository _doctorRepository;
  final AppointmentRepository _appointmentRepository;
  
  @override
  Future<bool> validate(AppointmentInput input) async {
    // Check patient exists
    if (!await _patientRepository.exists(input.patientId)) {
      throw EntityNotFoundException('Patient', input.patientId);
    }
    
    // Check doctor exists
    if (!await _doctorRepository.exists(input.doctorId)) {
      throw EntityNotFoundException('Doctor', input.doctorId);
    }
    
    // Check doctor availability
    final isAvailable = await _doctorRepository.isAvailableAt(
      input.doctorId,
      input.dateTime,
    );
    
    if (!isAvailable) {
      throw BusinessRuleViolationException('Doctor not available');
    }
    
    return true;
  }
  
  @override
  Future<Appointment> execute(AppointmentInput input) async {
    // Load entities
    final patient = await _patientRepository.getById(input.patientId);
    final doctor = await _doctorRepository.getById(input.doctorId);
    
    // Create appointment
    final appointment = Appointment(
      id: 'AUTO',
      dateTime: input.dateTime,
      duration: input.duration,
      patient: patient,
      doctor: doctor,
      status: AppointmentStatus.SCHEDULE,
      reason: input.reason,
    );
    
    // Save via repository
    await _appointmentRepository.save(appointment);
    
    return appointment;
  }
}
```

---

## 🌍 Real-World Examples

### Example 1: Complete Patient Registration Flow

```
Step-by-Step with All Layers:

1. USER enters data in console
   ↓
2. PRESENTATION (PatientMenu)
   - Validates input format
   - Creates Patient entity
   
3. DOMAIN (PatientRepository interface)
   - Defines contract: savePatient(Patient)
   
4. DATA (PatientRepositoryImpl)
   - Generates patient ID: P001 → P042
   - Converts Patient → PatientModel
   - Calls PatientLocalDataSource
   
5. DATA (PatientLocalDataSource)
   - Reads patients.json
   - Adds new patient model
   - Writes back to patients.json
   
6. Success propagates back up:
   DATA → DOMAIN → PRESENTATION
   
7. PRESENTATION displays:
   "✅ Patient P042 registered successfully!"
```

### Example 2: Loading Patient with Relationships

```
Challenge: Patient has relationships (doctors, nurses, room, bed)

1. USER requests patient details
   ↓
2. PRESENTATION calls repository.getPatientById('P001')
   ↓
3. DATA LAYER (PatientRepositoryImpl):
   a. Load PatientModel from JSON
   b. Extract relationship IDs:
      - assignedDoctorIds: ['D005', 'D012']
      - assignedNurseIds: ['N003']
      - currentRoomId: 'R101'
      - currentBedId: 'B101-1'
   
   c. Fetch related entities:
      - Call doctorDataSource.findByIds(['D005', 'D012'])
      - Call nurseDataSource.findByIds(['N003'])
      - Call roomDataSource.findById('R101')
      - Call bedDataSource.findById('B101-1')
   
   d. Convert each model to entity:
      - DoctorModel → Doctor entity
      - NurseModel → Nurse entity
      - RoomModel → Room entity
      - BedModel → Bed entity
   
   e. Assemble complete Patient entity:
      Patient(
        patientID: 'P001',
        name: 'Sok Pisey',
        assignedDoctors: [Doctor(...), Doctor(...)],
        assignedNurses: [Nurse(...)],
        currentRoom: Room(...),
        currentBed: Bed(...),
      )
   
   f. Return complete entity
   ↓
4. PRESENTATION displays all information
```

---

## 💬 Layer Communication

### Communication Rules

| From | To | Method | Example |
|------|-----|--------|---------|
| **Presentation** → **Domain** | Direct call | `await repository.savePatient(patient)` |
| **Presentation** → **Data** | Never! | Inject repository interface only |
| **Domain** → **Data** | Never! | Data implements domain interfaces |
| **Data** → **Domain** | Return entities | Convert models to entities |
| **Data** → **Presentation** | Never! | Data doesn't know about UI |

### Dependency Injection

```dart
// MAIN.DART (Application Entry Point)
void main() async {
  // 1. Create Data Sources
  final patientDataSource = PatientLocalDataSource();
  final doctorDataSource = DoctorLocalDataSource();
  
  // 2. Create Repository Implementations
  final patientRepository = PatientRepositoryImpl(
    patientDataSource: patientDataSource,
    doctorDataSource: doctorDataSource,
  );
  
  final doctorRepository = DoctorRepositoryImpl(
    doctorDataSource: doctorDataSource,
  );
  
  // 3. Create Menus with Injected Dependencies
  final patientMenu = PatientMenu(
    patientRepository: patientRepository,  // Domain interface!
    doctorRepository: doctorRepository,    // Domain interface!
  );
  
  // 4. Run application
  await mainMenuController.run();
}

// PATIENT MENU (Presentation Layer)
class PatientMenu extends BaseMenu {
  final PatientRepository patientRepository;  // Domain interface!
  final DoctorRepository doctorRepository;    // Domain interface!
  
  PatientMenu({
    required this.patientRepository,
    required this.doctorRepository,
  });
  
  // Menu uses interfaces, doesn't know about implementations!
}
```

### Interface Segregation

```dart
// Domain defines WHAT operations are needed
abstract class PatientRepository {
  Future<Patient> getById(String id);
  Future<void> save(Patient patient);
  Future<List<Patient>> searchByName(String name);
}

// Data implements HOW operations work
class PatientRepositoryImpl implements PatientRepository {
  @override
  Future<Patient> getById(String id) async {
    // Implementation with JSON files
  }
  
  @override
  Future<void> save(Patient patient) async {
    // Implementation with AUTO ID
  }
  
  @override
  Future<List<Patient>> searchByName(String name) async {
    // Implementation with filtering
  }
}
```

---

## ✅ Best Practices

### 1. Never Skip Layers

```dart
// ✅ GOOD - Go through all layers
Presentation → Domain (interface) → Data (implementation)

// ❌ BAD - Skip domain layer
Presentation → Data directly
```

### 2. Always Use Interfaces

```dart
// ✅ GOOD - Depend on interface
class PatientMenu {
  final PatientRepository repository;  // Interface!
}

// ❌ BAD - Depend on implementation
class PatientMenu {
  final PatientRepositoryImpl repository;  // Concrete class!
}
```

### 3. Entities Cross Boundaries

```dart
// ✅ GOOD - Entity goes up and down
Presentation creates Patient → passes to Domain → Data converts to Model

// ❌ BAD - Model in presentation
Presentation creates PatientModel → Domain  // Wrong layer!
```

### 4. Models Stay in Data Layer

```dart
// ✅ GOOD - Model only in data layer
Data: PatientModel (for JSON)
Domain: Patient entity
Presentation: Patient entity

// ❌ BAD - Model leaks to presentation
Presentation uses PatientModel  // Violates layering!
```

### 5. Use Cases for Complex Logic

```dart
// ✅ GOOD - Complex logic in use case
ScheduleAppointment use case validates all rules

// ❌ BAD - Complex logic in presentation
PatientMenu has all validation logic  // Wrong layer!
```

---

<div align="center">

**[⬆ Back to Top](#-layer-interactions---complete-guide)**

Made with ❤️ for Hospital Management System

</div>
