# 💾 Data Layer - Complete Guide

<div align="center">

**The Bridge Between Domain and Storage**

*JSON Persistence | Repository Implementation | Data Transformation*

[![Data Layer](https://img.shields.io/badge/Layer-Data-green?style=for-the-badge)]()
[![Models](https://img.shields.io/badge/Models-10-success?style=for-the-badge)]()
[![Repositories](https://img.shields.io/badge/Repositories-8-purple?style=for-the-badge)]()
[![Storage](https://img.shields.io/badge/Storage-JSON-orange?style=for-the-badge)]()

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Architecture](#-architecture)
- [Directory Structure](#-directory-structure)
- [Data Models (DTOs)](#-data-models-dtos)
- [Local Data Sources](#-local-data-sources)
- [Repository Implementations](#-repository-implementations)
- [AUTO ID Generation](#-auto-id-generation)
- [JSON File Structure](#-json-file-structure)
- [Data Flow](#-data-flow)
- [Best Practices](#-best-practices)

---

## 🌟 Overview

The **Data Layer** is responsible for implementing data persistence and retrieval. It acts as a bridge between the pure business logic (Domain Layer) and external data sources (JSON files).

### Key Responsibilities

```
┌─────────────────────────────────────────────────────────┐
│                     DATA LAYER                          │
│                                                         │
│  ✓ Implement Repository Interfaces                     │
│  ✓ Handle JSON Serialization/Deserialization           │
│  ✓ Manage File I/O Operations                          │
│  ✓ Convert Between Entities and Models                 │
│  ✓ Generate Unique IDs Automatically                   │
│  ✓ Handle Data Validation and Error Handling           │
│                                                         │
│  ┌──────────┐  ┌───────────┐  ┌──────────────┐       │
│  │  Models  │  │Data Source│  │  Repository  │       │
│  │  (DTOs)  │  │ (JSON I/O)│  │     Impl     │       │
│  └──────────┘  └───────────┘  └──────────────┘       │
└─────────────────────────────────────────────────────────┘
                       ▲
                       │ implements
                       ▼
            ┌──────────────────────┐
            │    DOMAIN LAYER      │
            │ Repository Interfaces│
            └──────────────────────┘
```

### 📊 Statistics

| Component | Count | Purpose |
|-----------|-------|---------|
| **Models (DTOs)** | 10 | Data Transfer Objects for JSON conversion |
| **Data Sources** | 9 | JSON file read/write operations |
| **Repository Impls** | 8 | Domain repository implementations |
| **JSON Files** | 9 | Persistent storage files |
| **ID Generator** | 1 | AUTO ID generation utility |

---

## 🏛️ Architecture

### Dependency Flow

```
Presentation Layer
      ↓ uses
Domain Layer (Repositories - Interface)
      ↑ implements
Data Layer (Repository Implementations)
      ↓ uses
Data Sources (JSON File I/O)
      ↓ reads/writes
JSON Files (data/jsons/)
```

### Layer Isolation

The Data Layer knows about the Domain Layer (it implements domain interfaces), but the Domain Layer knows **nothing** about the Data Layer. This allows us to:

✅ **Swap Storage** - Change from JSON → SQL → API without touching domain  
✅ **Test Easily** - Mock repositories for unit tests  
✅ **Maintain Flexibility** - Multiple data sources can coexist  
✅ **Follow Clean Architecture** - Dependency Rule respected  

---

## 📁 Directory Structure

```
lib/data/
│
├── models/                             # 📦 Data Transfer Objects (10)
│   ├── patient_model.dart              # Patient DTO with JSON conversion
│   ├── doctor_model.dart               # Doctor DTO with schedule serialization
│   ├── nurse_model.dart                # Nurse DTO with shift handling
│   ├── administrative_model.dart       # Administrative staff DTO
│   ├── appointment_model.dart          # Appointment DTO with status enum
│   ├── prescription_model.dart         # Prescription DTO with medication refs
│   ├── medication_model.dart           # Medication DTO (medication catalog)
│   ├── room_model.dart                 # Room DTO with bed tracking
│   ├── bed_model.dart                  # Bed DTO with occupancy status
│   └── equipment_model.dart            # Equipment DTO with status tracking
│
├── datasources/                        # 💾 JSON File Operations (9+1)
│   ├── patient_local_data_source.dart
│   ├── doctor_local_data_source.dart
│   ├── nurse_local_data_source.dart
│   ├── administrative_local_data_source.dart
│   ├── appointment_local_data_source.dart
│   ├── prescription_local_data_source.dart
│   ├── room_local_data_source.dart
│   ├── equipment_local_data_source.dart
│   ├── medication_local_data_source.dart
│   └── id_generator.dart               # 🔢 AUTO ID Generation Utility
│
└── repositories/                       # 🔗 Repository Implementations (8)
    ├── patient_repository_impl.dart    # PatientRepository implementation
    ├── doctor_repository_impl.dart     # DoctorRepository implementation
    ├── nurse_repository_impl.dart      # NurseRepository implementation
    ├── administrative_repository_impl.dart
    ├── appointment_repository_impl.dart
    ├── prescription_repository_impl.dart
    ├── room_repository_impl.dart       # Room & Bed repository
    └── equipment_repository_impl.dart

data/jsons/                             # 📄 Persistent JSON Storage
    ├── patients.json                   # Patient records
    ├── doctors.json                    # Doctor records
    ├── nurses.json                     # Nurse records
    ├── administrative.json             # Admin staff records
    ├── appointments.json               # Appointment bookings
    ├── prescriptions.json              # Prescription records
    ├── medications.json                # Medication catalog
    ├── rooms.json                      # Room inventory
    └── equipment.json                  # Equipment inventory
```

---

## 📦 Data Models (DTOs)

Models are **Data Transfer Objects** that handle conversion between Domain Entities and JSON format. They exist only in the Data Layer.

### Why Models? Why Not Use Entities Directly?

```
❌ WITHOUT MODELS (Bad Approach):
Domain Entity → JSON Directly
  - Domain knows about JSON (violates Clean Architecture)
  - Can't have different JSON formats
  - Hard to handle legacy data formats

✅ WITH MODELS (Our Approach):
Domain Entity → Model → JSON
  - Domain stays pure (no JSON knowledge)
  - Models handle format variations
  - Easy to support multiple API versions
  - Backward compatibility with old JSON formats
```

---

### 🏥 PatientModel (Example)

**Purpose**: Convert between Patient entity and JSON format

**Location**: `lib/data/models/patient_model.dart`

<details>
<summary><b>📝 View Complete Implementation</b></summary>

#### Class Structure

```dart
class PatientModel {
  // Primitive fields (direct mapping)
  final String patientID;
  final String name;
  final String dateOfBirth;
  final String address;
  final String tel;
  final String bloodType;
  final List<String> medicalRecords;
  final List<String> allergies;
  final String emergencyContact;
  
  // Relationships (stored as IDs in JSON)
  final List<String> assignedDoctorIds;   // Not Doctor objects!
  final List<String> assignedNurseIds;    // Not Nurse objects!
  final List<String> prescriptionIds;     // Not Prescription objects!
  final String? currentRoomId;             // Not Room object!
  final String? currentBedId;              // Not Bed object!
  
  // Meeting fields
  final bool hasNextMeeting;
  final String? nextMeetingDate;           // ISO 8601 string
  final String? nextMeetingDoctorId;       // Doctor ID reference
}
```

#### Key Methods

**1. Entity → Model (for saving)**

```dart
/// Convert domain entity to model for JSON serialization
factory PatientModel.fromEntity(
  Patient patient, {
  Room? currentRoom,
  Bed? currentBed,
  List<Prescription>? prescriptions,
}) {
  return PatientModel(
    patientID: patient.patientID,
    name: patient.name,
    dateOfBirth: patient.dateOfBirth,
    address: patient.address,
    tel: patient.tel,
    bloodType: patient.bloodType,
    medicalRecords: patient.medicalRecords.toList(),
    allergies: patient.allergies.toList(),
    emergencyContact: patient.emergencyContact,
    
    // Convert entity references to IDs
    assignedDoctorIds: patient.assignedDoctors.map((d) => d.staffID).toList(),
    assignedNurseIds: patient.assignedNurses.map((n) => n.staffID).toList(),
    prescriptionIds: prescriptions?.map((p) => p.id).toList() ??
        patient.prescriptions.map((p) => p.id).toList(),
    
    currentRoomId: currentRoom?.number ?? patient.currentRoom?.number,
    currentBedId: currentBed?.bedNumber ?? patient.currentBed?.bedNumber,
    
    hasNextMeeting: patient.hasNextMeeting,
    nextMeetingDate: patient.nextMeetingDate?.toIso8601String(),
    nextMeetingDoctorId: patient.nextMeetingDoctor?.staffID,
  );
}
```

**2. Model → Entity (for loading)**

```dart
/// Convert model to domain entity (requires loading related entities)
Patient toEntity({
  required List<Doctor> assignedDoctors,  // Must be fetched separately!
  List<Nurse>? assignedNurses,
  List<Prescription>? prescriptions,
  Room? currentRoom,
  Bed? currentBed,
}) {
  // Find the meeting doctor if scheduled
  Doctor? meetingDoctor;
  if (hasNextMeeting && nextMeetingDoctorId != null) {
    try {
      meetingDoctor = assignedDoctors.firstWhere(
        (d) => d.staffID == nextMeetingDoctorId,
      );
    } catch (e) {
      meetingDoctor = null; // Doctor not found
    }
  }

  return Patient(
    patientID: patientID,
    name: name,
    dateOfBirth: dateOfBirth,
    address: address,
    tel: tel,
    bloodType: bloodType,
    medicalRecords: medicalRecords,
    allergies: allergies,
    emergencyContact: emergencyContact,
    
    // Pass the full entity objects
    assignedDoctors: assignedDoctors,
    assignedNurses: assignedNurses ?? [],
    prescriptions: prescriptions ?? [],
    currentRoom: currentRoom,
    currentBed: currentBed,
    
    hasNextMeeting: hasNextMeeting,
    nextMeetingDate: nextMeetingDate != null 
        ? DateTime.parse(nextMeetingDate!) 
        : null,
    nextMeetingDoctor: meetingDoctor,
  );
}
```

**3. JSON → Model (loading from file)**

```dart
factory PatientModel.fromJson(Map<String, dynamic> json) {
  // Handle both old and new formats (backward compatibility!)
  List<String> doctorIds = [];
  if (json['assignedDoctorIds'] != null) {
    doctorIds = List<String>.from(json['assignedDoctorIds']);
  } else if (json['assignedDoctorId'] != null) {
    // Old format: single doctor
    doctorIds = [json['assignedDoctorId'] as String];
  }

  // Handle nurse IDs (similar backward compatibility)
  List<String> nurseIds = [];
  if (json['assignedNurseIds'] != null) {
    nurseIds = List<String>.from(json['assignedNurseIds']);
  } else if (json['assignedNurseId'] != null) {
    nurseIds = [json['assignedNurseId'] as String];
  }

  // Handle medical records field name variations
  List<String> records = [];
  if (json['medicalRecords'] != null) {
    records = List<String>.from(json['medicalRecords']);
  } else if (json['medicalHistory'] != null) {
    // Old field name
    records = List<String>.from(json['medicalHistory']);
  }

  // Handle room ID field variations
  String? roomId = json['currentRoomId'] as String?;
  if (roomId == null && json['assignedRoomId'] != null) {
    roomId = json['assignedRoomId'] as String;
  }

  // Handle bed ID field variations
  String? bedId = json['currentBedId'] as String?;
  if (bedId == null && json['assignedBedId'] != null) {
    bedId = json['assignedBedId'] as String;
  }

  return PatientModel(
    patientID: json['patientID'] as String,
    name: json['name'] as String,
    dateOfBirth: json['dateOfBirth'] as String,
    address: json['address'] as String,
    tel: json['tel'] as String,
    bloodType: json['bloodType'] as String? ?? 'Unknown',
    medicalRecords: records,
    allergies: List<String>.from(json['allergies'] ?? []),
    emergencyContact: json['emergencyContact'] as String,
    assignedDoctorIds: doctorIds,
    assignedNurseIds: nurseIds,
    prescriptionIds: List<String>.from(json['prescriptionIds'] ?? []),
    currentRoomId: roomId,
    currentBedId: bedId,
    hasNextMeeting: json['hasNextMeeting'] as bool? ?? false,
    nextMeetingDate: json['nextMeetingDate'] as String?,
    nextMeetingDoctorId: json['nextMeetingDoctorId'] as String?,
  );
}
```

**4. Model → JSON (saving to file)**

```dart
Map<String, dynamic> toJson() {
  return {
    'patientID': patientID,
    'name': name,
    'dateOfBirth': dateOfBirth,
    'address': address,
    'tel': tel,
    'bloodType': bloodType,
    'medicalRecords': medicalRecords,
    'allergies': allergies,
    'emergencyContact': emergencyContact,
    'assignedDoctorIds': assignedDoctorIds,      // Array of IDs
    'assignedNurseIds': assignedNurseIds,        // Array of IDs
    'prescriptionIds': prescriptionIds,          // Array of IDs
    'currentRoomId': currentRoomId,              // Single ID
    'currentBedId': currentBedId,                // Single ID
    'hasNextMeeting': hasNextMeeting,
    'nextMeetingDate': nextMeetingDate,
    'nextMeetingDoctorId': nextMeetingDoctorId,
  };
}
```

**5. CopyWith (immutable updates)**

```dart
PatientModel copyWith({
  String? patientID,
  String? name,
  // ... all fields ...
}) {
  return PatientModel(
    patientID: patientID ?? this.patientID,
    name: name ?? this.name,
    // ... all fields with fallback to current value ...
  );
}
```

</details>

### Model Design Principles

✅ **ID References** - Store relationships as IDs, not full objects  
✅ **Backward Compatibility** - Handle multiple JSON format versions  
✅ **Null Safety** - Handle missing/null fields gracefully  
✅ **Type Conversion** - Convert between Dart types and JSON types  
✅ **Validation** - Basic validation in fromJson (e.g., default values)  
✅ **Immutability** - Models are immutable like entities  

---

## 💾 Local Data Sources

Data Sources handle **direct file I/O operations** with JSON files. They are the lowest level of the data layer.

### Responsibilities

```
Data Source Responsibilities:
  ✓ Read entire JSON file into memory
  ✓ Write entire data structure back to file
  ✓ Find specific records by ID
  ✓ Filter records by criteria
  ✓ Add new records
  ✓ Update existing records
  ✓ Delete records
  ✓ Convert between Model and JSON Map
```

### Base Pattern (Shared Across All Data Sources)

<details>
<summary><b>📝 View Common Data Source Pattern</b></summary>

```dart
class PatientLocalDataSource {
  final String filePath = 'data/jsons/patients.json';

  /// Read all patients from JSON file
  Future<List<PatientModel>> readAll() async {
    try {
      final file = File(filePath);
      
      if (!await file.exists()) {
        // Create empty file if doesn't exist
        await file.create(recursive: true);
        await file.writeAsString('[]');
        return [];
      }

      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);
      
      return jsonList
          .map((json) => PatientModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to read patients: $e');
    }
  }

  /// Find patient by ID
  Future<PatientModel?> findByPatientID(String patientId) async {
    final patients = await readAll();
    try {
      return patients.firstWhere((p) => p.patientID == patientId);
    } catch (e) {
      return null; // Not found
    }
  }

  /// Check if patient exists
  Future<bool> patientExists(String patientId) async {
    final patient = await findByPatientID(patientId);
    return patient != null;
  }

  /// Find patients by name (partial match, case-insensitive)
  Future<List<PatientModel>> findPatientsByName(String name) async {
    final patients = await readAll();
    final lowerName = name.toLowerCase();
    
    return patients
        .where((p) => p.name.toLowerCase().contains(lowerName))
        .toList();
  }

  /// Find patients by blood type
  Future<List<PatientModel>> findPatientsByBloodType(String bloodType) async {
    final patients = await readAll();
    return patients
        .where((p) => p.bloodType == bloodType)
        .toList();
  }

  /// Add new patient
  Future<void> add(
    PatientModel patient,
    String Function(PatientModel) getId,
    Map<String, dynamic> Function(PatientModel) toJson,
  ) async {
    final patients = await readAll();
    patients.add(patient);
    await _writeAll(patients);
  }

  /// Update existing patient
  Future<void> update(
    String patientId,
    PatientModel updatedPatient,
    String Function(PatientModel) getId,
    Map<String, dynamic> Function(PatientModel) toJson,
  ) async {
    final patients = await readAll();
    final index = patients.indexWhere((p) => p.patientID == patientId);
    
    if (index == -1) {
      throw Exception('Patient $patientId not found for update');
    }
    
    patients[index] = updatedPatient;
    await _writeAll(patients);
  }

  /// Delete patient
  Future<void> delete(
    String patientId,
    String Function(PatientModel) getId,
    Map<String, dynamic> Function(PatientModel) toJson,
  ) async {
    final patients = await readAll();
    patients.removeWhere((p) => p.patientID == patientId);
    await _writeAll(patients);
  }

  /// Write all patients to file (private helper)
  Future<void> _writeAll(List<PatientModel> patients) async {
    final file = File(filePath);
    final jsonList = patients.map((p) => p.toJson()).toList();
    final jsonString = json.encode(jsonList);
    await file.writeAsString(jsonString);
  }
}
```

</details>

### Data Source Features

| Feature | Description |
|---------|-------------|
| **File Creation** | Automatically creates JSON file if missing |
| **Error Handling** | Wraps file operations in try-catch |
| **Lazy Loading** | Reads file only when needed |
| **Full Rewrites** | Writes entire file on updates (simple but works) |
| **Query Methods** | Find by ID, name, status, etc. |
| **Type Safety** | Returns strongly-typed models |

---

## 🔗 Repository Implementations

Repository Implementations connect the domain interface to the data source.

### Architecture Pattern

```
┌─────────────────────────────────────────────────────────┐
│  Domain Layer: PatientRepository (interface)            │
│                                                         │
│  Future<Patient> getPatientById(String id);            │
│  Future<void> savePatient(Patient patient);            │
└─────────────────────┬───────────────────────────────────┘
                      │ implements
┌─────────────────────▼───────────────────────────────────┐
│  Data Layer: PatientRepositoryImpl                      │
│                                                         │
│  - Uses PatientLocalDataSource                          │
│  - Uses DoctorLocalDataSource (for relationships)       │
│  - Converts Models ↔ Entities                           │
│  - Handles AUTO ID generation                           │
│  - Fetches related entities                             │
└─────────────────────────────────────────────────────────┘
```

### PatientRepositoryImpl (Example)

<details>
<summary><b>📋 View Implementation Details</b></summary>

#### Dependencies

```dart
class PatientRepositoryImpl implements PatientRepository {
  final PatientLocalDataSource _patientDataSource;
  final DoctorLocalDataSource _doctorDataSource;
  // Could inject more data sources for relationships

  PatientRepositoryImpl({
    required PatientLocalDataSource patientDataSource,
    required DoctorLocalDataSource doctorDataSource,
  })  : _patientDataSource = patientDataSource,
        _doctorDataSource = doctorDataSource;
}
```

#### CRUD Operations

**GET BY ID**

```dart
@override
Future<Patient> getPatientById(String patientId) async {
  // 1. Fetch patient model from data source
  final model = await _patientDataSource.findByPatientID(patientId);
  
  if (model == null) {
    throw Exception('Patient with ID $patientId not found');
  }

  // 2. Fetch related entities (doctors)
  final assignedDoctorModels = await _doctorDataSource
      .findDoctorsByIds(model.assignedDoctorIds);
  
  final assignedDoctors = assignedDoctorModels
      .map((dm) => dm.toEntity())
      .toList();

  // 3. Convert model to entity with relationships
  return model.toEntity(assignedDoctors: assignedDoctors);
}
```

**GET ALL**

```dart
@override
Future<List<Patient>> getAllPatients() async {
  final models = await _patientDataSource.readAll();
  final List<Patient> patients = [];

  for (final model in models) {
    // Fetch doctors for each patient
    final assignedDoctors = await _convertDoctorModels(
      model.assignedDoctorIds
    );
    
    patients.add(
      model.toEntity(assignedDoctors: assignedDoctors)
    );
  }

  return patients;
}

// Helper method
Future<List<Doctor>> _convertDoctorModels(List<String> doctorIds) async {
  if (doctorIds.isEmpty) return [];
  
  final doctorModels = await _doctorDataSource.findDoctorsByIds(doctorIds);
  return doctorModels.map((dm) => dm.toEntity()).toList();
}
```

**SAVE (with AUTO ID)**

```dart
@override
Future<void> savePatient(Patient patient) async {
  String patientId = patient.patientID;

  // AUTO ID GENERATION
  if (patientId.isEmpty || patientId == 'AUTO' || patientId == 'P000') {
    // Read all existing patients
    final allPatients = await _patientDataSource.readAll();
    final allPatientsJson = allPatients.map((p) => p.toJson()).toList();

    // Generate next available ID (P001, P002, P003, ...)
    patientId = IdGenerator.generatePatientId(allPatientsJson);

    // Create new patient entity with generated ID
    patient = Patient(
      patientID: patientId,
      name: patient.name,
      dateOfBirth: patient.dateOfBirth,
      address: patient.address,
      tel: patient.tel,
      bloodType: patient.bloodType,
      medicalRecords: patient.medicalRecords.toList(),
      allergies: patient.allergies.toList(),
      emergencyContact: patient.emergencyContact,
      assignedDoctors: patient.assignedDoctors.toList(),
      assignedNurses: patient.assignedNurses.toList(),
      prescriptions: patient.prescriptions.toList(),
      currentRoom: patient.currentRoom,
      currentBed: patient.currentBed,
    );
  }

  // Convert entity to model
  final model = PatientModel.fromEntity(patient);

  // Check for conflicts
  final exists = await _patientDataSource.patientExists(patientId);
  if (exists) {
    throw Exception(
      'Patient with ID $patientId already exists. Use updatePatient() instead.'
    );
  }

  // Save to data source
  await _patientDataSource.add(
    model,
    (p) => p.patientID,
    (p) => p.toJson(),
  );
}
```

**UPDATE**

```dart
@override
Future<void> updatePatient(Patient patient) async {
  final model = PatientModel.fromEntity(patient);

  // Check existence
  final exists = await _patientDataSource.patientExists(patient.patientID);
  if (!exists) {
    throw Exception('Patient with ID ${patient.patientID} not found');
  }

  // Update in data source
  await _patientDataSource.update(
    patient.patientID,
    model,
    (p) => p.patientID,
    (p) => p.toJson(),
  );
}
```

**DELETE**

```dart
@override
Future<void> deletePatient(String patientId) async {
  await _patientDataSource.delete(
    patientId,
    (p) => p.patientID,
    (p) => p.toJson(),
  );
}
```

#### Query Operations

**SEARCH BY NAME**

```dart
@override
Future<List<Patient>> searchPatientsByName(String name) async {
  final models = await _patientDataSource.findPatientsByName(name);
  final List<Patient> patients = [];

  for (final model in models) {
    final assignedDoctors = await _convertDoctorModels(
      model.assignedDoctorIds
    );
    patients.add(model.toEntity(assignedDoctors: assignedDoctors));
  }

  return patients;
}
```

**FILTER BY BLOOD TYPE**

```dart
@override
Future<List<Patient>> getPatientsByBloodType(String bloodType) async {
  final models = await _patientDataSource.findPatientsByBloodType(bloodType);
  final List<Patient> patients = [];

  for (final model in models) {
    final assignedDoctors = await _convertDoctorModels(
      model.assignedDoctorIds
    );
    patients.add(model.toEntity(assignedDoctors: assignedDoctors));
  }

  return patients;
}
```

</details>

### Repository Implementation Patterns

✅ **Dependency Injection** - Data sources injected via constructor  
✅ **Entity Hydration** - Fetch related entities and compose full objects  
✅ **Model Conversion** - Convert between entities and models  
✅ **ID Generation** - Handle AUTO ID before saving  
✅ **Error Propagation** - Let exceptions bubble up to use cases  
✅ **Single Responsibility** - Each repo handles one entity type  

---

## 🔢 AUTO ID Generation

The ID Generator provides **automatic unique ID generation** for all entities.

### How It Works

```
┌─────────────────────────────────────────────────────────┐
│  AUTO ID Generation Process                             │
│                                                         │
│  1. User creates entity with ID = "AUTO"                │
│  2. Repository detects AUTO ID                          │
│  3. Repository reads ALL existing records               │
│  4. IdGenerator finds max numeric ID                    │
│  5. IdGenerator increments: max + 1                     │
│  6. IdGenerator formats with prefix and padding         │
│  7. Repository creates new entity with generated ID     │
│  8. Repository saves to data source                     │
│                                                         │
│  Example:                                               │
│    Existing: P001, P002, P050                           │
│    Generated: P051                                      │
└─────────────────────────────────────────────────────────┘
```

### IdGenerator Class

**Location**: `lib/data/datasources/id_generator.dart`

<details>
<summary><b>📋 View Complete Implementation</b></summary>

```dart
class IdGenerator {
  /// Generate next ID by finding max and incrementing
  ///
  /// [records] - List of JSON objects
  /// [idField] - Name of ID field (e.g., 'patientID')
  /// [prefix] - ID prefix (e.g., 'P')
  /// [digits] - Number of digits (usually 3)
  ///
  /// Returns formatted ID (e.g., 'P051')
  static String generateNextId(
    List<Map<String, dynamic>> records,
    String idField,
    String prefix,
    int digits,
  ) {
    if (records.isEmpty) {
      // Start from 1 if no records
      return '$prefix${'1'.padLeft(digits, '0')}';
    }

    // Find maximum numeric ID
    int maxId = 0;
    for (var record in records) {
      try {
        final id = record[idField] as String?;
        if (id == null || id.isEmpty) continue;

        // Remove prefix to get number
        final numericPart = id.replaceAll(prefix, '');
        final num = int.tryParse(numericPart) ?? 0;

        if (num > maxId) {
          maxId = num;
        }
      } catch (e) {
        continue; // Skip invalid records
      }
    }

    // Increment and format with leading zeros
    final nextNum = maxId + 1;
    return '$prefix${nextNum.toString().padLeft(digits, '0')}';
  }

  /// Entity-specific ID generators
  
  static String generatePatientId(List<Map<String, dynamic>> patients) {
    return generateNextId(patients, 'patientID', 'P', 3);
    // Format: P001, P002, P003, ..., P999
  }

  static String generateDoctorId(List<Map<String, dynamic>> doctors) {
    return generateNextId(doctors, 'staffID', 'D', 3);
    // Format: D001, D002, D003, ..., D999
  }

  static String generateNurseId(List<Map<String, dynamic>> nurses) {
    return generateNextId(nurses, 'staffID', 'N', 3);
    // Format: N001, N002, N003, ..., N999
  }

  static String generateAppointmentId(List<Map<String, dynamic>> appointments) {
    return generateNextId(appointments, 'id', 'A', 3);
    // Format: A001, A002, A003, ..., A999
  }

  static String generatePrescriptionId(List<Map<String, dynamic>> prescriptions) {
    return generateNextId(prescriptions, 'id', 'PR', 3);
    // Format: PR001, PR002, PR003, ..., PR999
  }

  static String generateRoomId(List<Map<String, dynamic>> rooms) {
    return generateNextId(rooms, 'roomId', 'R', 3);
    // Format: R001, R002, R003, ..., R999
  }

  static String generateEquipmentId(List<Map<String, dynamic>> equipment) {
    return generateNextId(equipment, 'equipmentId', 'EQ', 3);
    // Format: EQ001, EQ002, EQ003, ..., EQ999
  }

  static String generateMedicationId(List<Map<String, dynamic>> medications) {
    return generateNextId(medications, 'id', 'M', 3);
    // Format: M001, M002, M003, ..., M999
  }

  static String generateAdministrativeId(List<Map<String, dynamic>> admins) {
    return generateNextId(admins, 'staffID', 'AD', 3);
    // Format: AD001, AD002, AD003, ..., AD999
  }

  /// Validate ID format
  static bool isValidIdFormat(String id, String prefix, int digits) {
    if (!id.startsWith(prefix)) return false;

    final numericPart = id.replaceAll(prefix, '');
    if (numericPart.length != digits) return false;

    return int.tryParse(numericPart) != null;
  }
}
```

</details>

### ID Format Standards

| Entity | Prefix | Format | Range | Example |
|--------|--------|--------|-------|---------|
| **Patient** | `P` | P### | P001-P999 | P042 |
| **Doctor** | `D` | D### | D001-D999 | D015 |
| **Nurse** | `N` | N### | N001-N999 | N008 |
| **Admin** | `AD` | AD### | AD001-AD999 | AD003 |
| **Appointment** | `A` | A### | A001-A999 | A127 |
| **Prescription** | `PR` | PR### | PR001-PR999 | PR045 |
| **Room** | `R` | R### | R001-R999 | R101 |
| **Equipment** | `EQ` | EQ### | EQ001-EQ999 | EQ023 |
| **Medication** | `M` | M### | M001-M999 | M067 |

### Usage Example

```dart
// In repository implementation
if (patientId == 'AUTO') {
  final allPatients = await _patientDataSource.readAll();
  final allPatientsJson = allPatients.map((p) => p.toJson()).toList();
  
  patientId = IdGenerator.generatePatientId(allPatientsJson);
  // Result: P001 (or next available)
}
```

---

## 📄 JSON File Structure

All data is stored in JSON files under `data/jsons/` directory.

### File Naming Convention

```
data/jsons/
  ├── patients.json           # Patient records
  ├── doctors.json            # Doctor records
  ├── nurses.json             # Nurse records
  ├── administrative.json     # Admin staff records
  ├── appointments.json       # Appointment bookings
  ├── prescriptions.json      # Prescription records
  ├── medications.json        # Medication catalog
  ├── rooms.json              # Room inventory
  └── equipment.json          # Equipment tracking
```

### Example JSON Structure

<details>
<summary><b>patients.json Example</b></summary>

```json
[
  {
    "patientID": "P001",
    "name": "Sok Pisey",
    "dateOfBirth": "1985-03-15",
    "address": "Phnom Penh, Cambodia",
    "tel": "012345678",
    "bloodType": "O+",
    "medicalRecords": [
      "2024-01-15: Regular checkup - Normal",
      "2024-06-10: Blood pressure monitoring - 120/80"
    ],
    "allergies": ["Penicillin", "Peanuts"],
    "emergencyContact": "012999888",
    "assignedDoctorIds": ["D005", "D012"],
    "assignedNurseIds": ["N003"],
    "prescriptionIds": ["PR045", "PR067"],
    "currentRoomId": "R101",
    "currentBedId": "B101-1",
    "hasNextMeeting": true,
    "nextMeetingDate": "2025-02-15T09:00:00.000Z",
    "nextMeetingDoctorId": "D005"
  },
  {
    "patientID": "P002",
    "name": "Chea Sokha",
    "dateOfBirth": "1990-07-22",
    "address": "Siem Reap, Cambodia",
    "tel": "012876543",
    "bloodType": "A+",
    "medicalRecords": [],
    "allergies": [],
    "emergencyContact": "012888777",
    "assignedDoctorIds": ["D003"],
    "assignedNurseIds": [],
    "prescriptionIds": [],
    "currentRoomId": null,
    "currentBedId": null,
    "hasNextMeeting": false,
    "nextMeetingDate": null,
    "nextMeetingDoctorId": null
  }
]
```

</details>

<details>
<summary><b>doctors.json Example</b></summary>

```json
[
  {
    "staffID": "D001",
    "name": "Dr. Sopheak Chan",
    "dateOfBirth": "1975-05-10",
    "address": "Phnom Penh, Cambodia",
    "tel": "012111222",
    "department": "Cardiology",
    "hireDate": "2010-03-15",
    "licenseNumber": "MED-KH-12345",
    "specialization": "Cardiology",
    "workingHours": {
      "Monday": {
        "start": "08:00",
        "end": "17:00",
        "break_start": "12:00",
        "break_end": "13:00"
      },
      "Tuesday": {
        "start": "08:00",
        "end": "17:00",
        "break_start": "12:00",
        "break_end": "13:00"
      }
    },
    "patientIds": ["P001", "P005", "P012"],
    "consultationFee": 50.0,
    "yearsOfExperience": 15
  }
]
```

</details>

### JSON Features

✅ **Human Readable** - Easy to inspect and debug  
✅ **Version Control Friendly** - Text-based diffs  
✅ **No Setup Required** - No database installation  
✅ **Portable** - Works on any platform  
✅ **Editable** - Can manually fix data if needed  

---

## 🔄 Data Flow

### Complete Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                     │
│                    (User Interaction)                       │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                       USE CASE                              │
│              (Business Logic Orchestration)                 │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                  REPOSITORY INTERFACE                       │
│             (Domain Layer - Contract Only)                  │
│                                                             │
│   Future<Patient> getPatientById(String id);               │
│   Future<void> savePatient(Patient patient);               │
└────────────────────────┬────────────────────────────────────┘
                         │ implements
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              REPOSITORY IMPLEMENTATION                      │
│                  (Data Layer - Logic)                       │
│                                                             │
│  1. Receive Entity from use case                           │
│  2. Convert Entity → Model (if saving)                     │
│  3. Handle AUTO ID generation                              │
│  4. Call Data Source methods                               │
│  5. Fetch related entities (for relationships)             │
│  6. Convert Model → Entity (if loading)                    │
│  7. Return Entity to use case                              │
└────────────────────────┬────────────────────────────────────┘
                         │ uses
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    LOCAL DATA SOURCE                        │
│                (Data Layer - File I/O)                      │
│                                                             │
│  1. Read JSON file from disk                               │
│  2. Parse JSON → List<Map>                                 │
│  3. Convert Map → Model (using Model.fromJson)             │
│  4. Perform queries/filters in memory                      │
│  5. Convert Model → Map (using Model.toJson)               │
│  6. Serialize to JSON string                               │
│  7. Write to file                                          │
└────────────────────────┬────────────────────────────────────┘
                         │ reads/writes
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                      JSON FILES                             │
│                 (Persistent Storage)                        │
│                                                             │
│   data/jsons/patients.json                                 │
│   data/jsons/doctors.json                                  │
│   data/jsons/appointments.json                             │
│   ... etc ...                                              │
└─────────────────────────────────────────────────────────────┘
```

### Example: Save Patient Flow

```
1. User Input (Presentation)
   ↓
   Patient(name="Sok Pisey", patientID="AUTO", ...)

2. Use Case (Domain)
   ↓
   await patientRepository.savePatient(patient)

3. Repository Implementation (Data)
   ↓
   - Detect AUTO ID
   - Generate ID: P001 → P042 (next available)
   - Create new Patient entity with P042
   - Convert Patient → PatientModel
   ↓
   PatientModel(patientID="P042", name="Sok Pisey", ...)

4. Data Source (Data)
   ↓
   - Read existing patients.json
   - Add new PatientModel to list
   - Convert all models to JSON maps
   - Write entire list back to file
   ↓
   patients.json updated with P042

5. Return Success (Data → Domain → Presentation)
```

---

## ✅ Best Practices

### 1. Always Use Models for JSON

```dart
// ✅ GOOD - Use model for JSON conversion
final model = PatientModel.fromEntity(patient);
final json = model.toJson();

// ❌ BAD - Entity knows about JSON
final json = patient.toJson(); // Violates Clean Architecture!
```

### 2. Handle Relationships with IDs

```dart
// ✅ GOOD - Store IDs in JSON
{
  "assignedDoctorIds": ["D001", "D005"],
  "currentRoomId": "R101"
}

// ❌ BAD - Try to store full objects
{
  "assignedDoctors": [
    {"staffID": "D001", "name": "Dr. Chan", ...}, // Nested objects = duplication
    {"staffID": "D005", "name": "Dr. Sok", ...}
  ]
}
```

### 3. Validate Before Saving

```dart
// ✅ GOOD - Validate in repository
if (patient.patientID.isEmpty || patient.patientID == 'AUTO') {
  patientId = IdGenerator.generatePatientId(allPatientsJson);
}

// Check for conflicts
if (await _patientDataSource.patientExists(patientId)) {
  throw Exception('Patient already exists');
}
```

### 4. Fetch Related Entities

```dart
// ✅ GOOD - Fetch doctors when loading patient
final doctorModels = await _doctorDataSource
    .findDoctorsByIds(model.assignedDoctorIds);
final doctors = doctorModels.map((dm) => dm.toEntity()).toList();
return model.toEntity(assignedDoctors: doctors);

// ❌ BAD - Return entity without relationships
return model.toEntity(assignedDoctors: []); // Missing data!
```

### 5. Handle Backward Compatibility

```dart
// ✅ GOOD - Support old and new field names
if (json['assignedDoctorIds'] != null) {
  doctorIds = List<String>.from(json['assignedDoctorIds']);
} else if (json['assignedDoctorId'] != null) {
  // Old format: single doctor
  doctorIds = [json['assignedDoctorId'] as String];
}
```

### 6. Provide Default Values

```dart
// ✅ GOOD - Default values for missing fields
bloodType: json['bloodType'] as String? ?? 'Unknown',
allergies: List<String>.from(json['allergies'] ?? []),
hasNextMeeting: json['hasNextMeeting'] as bool? ?? false,
```

### 7. Use Dependency Injection

```dart
// ✅ GOOD - Inject dependencies
class PatientRepositoryImpl implements PatientRepository {
  final PatientLocalDataSource _patientDataSource;
  final DoctorLocalDataSource _doctorDataSource;

  PatientRepositoryImpl({
    required PatientLocalDataSource patientDataSource,
    required DoctorLocalDataSource doctorDataSource,
  }) : ...
}

// ❌ BAD - Create dependencies inside
class PatientRepositoryImpl {
  final _patientDataSource = PatientLocalDataSource(); // Hard to test!
}
```

---

## 📚 Further Reading

- [Repository Pattern](https://martinfowler.com/eaaCatalog/repository.html)
- [Data Mapper Pattern](https://martinfowler.com/eaaCatalog/dataMapper.html)
- [DTO Pattern](https://martinfowler.com/eaaCatalog/dataTransferObject.html)
- [JSON Serialization in Dart](https://dart.dev/guides/json)

---

<div align="center">

**[⬆ Back to Top](#-data-layer---complete-guide)**

Made with ❤️ for Hospital Management System

</div>
