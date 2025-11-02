# Data Layer Documentation

## Overview

The data layer implements JSON file-based persistence for the Hospital Management System. It follows Clean Architecture principles, separating data access logic from business logic through well-defined interfaces and models.

## Architecture

```
lib/data/
├── datasources/
│   └── local/
│       └── json_data_source.dart     # Base class for JSON operations
├── models/                            # Data Transfer Objects (DTOs)
│   ├── patient_model.dart
│   ├── doctor_model.dart
│   ├── nurse_model.dart
│   ├── room_model.dart
│   ├── bed_model.dart
│   ├── equipment_model.dart
│   ├── medication_model.dart
│   ├── prescription_model.dart
│   ├── appointment_model.dart
│   └── administrative_model.dart
└── repositories/                      # Repository implementations
    ├── patient_repository_impl.dart
    ├── doctor_repository_impl.dart
    └── ... (other repositories)
```

## Core Components

### 1. JsonDataSource Base Class

The `JsonDataSource` class provides common CRUD operations for all entities using JSON file storage.

**Location**: `lib/data/datasources/local/json_data_source.dart`

**Key Features**:
- Generic type support for any entity model
- Automatic directory creation
- Safe file I/O with error handling
- Predicate-based querying

**Methods**:
```dart
// Read all records from JSON file
Future<List<T>> readAll()

// Write all records to JSON file
Future<void> writeAll(List<T> items)

// Find a single record by ID
Future<T?> findById(String id, String Function(T) idGetter)

// Add a new record
Future<void> add(T item, String Function(T) idGetter)

// Update an existing record
Future<void> update(String id, T item, String Function(T) idGetter)

// Delete a record by ID
Future<void> delete(String id, String Function(T) idGetter)

// Check if a record exists
Future<bool> exists(String id, String Function(T) idGetter)

// Find records matching a predicate
Future<List<T>> findWhere(bool Function(T) predicate)

// Clear all records
Future<void> clear()
```

**Usage Example**:
```dart
class PatientLocalDataSource extends JsonDataSource<PatientModel> {
  PatientLocalDataSource() : super(
    fileName: 'patients.json',
    fromJson: PatientModel.fromJson,
  );

  Future<PatientModel?> findByPatientID(String patientID) {
    return findById(patientID, (patient) => patient.patientID);
  }
}
```

### 2. Data Models (DTOs)

Data models act as intermediaries between domain entities and JSON storage. They handle:
- Serialization (entity → JSON)
- Deserialization (JSON → entity)
- Relationship management through ID references

**Key Principles**:

#### a. Entity-Model Conversion
```dart
// From domain entity to model (for saving)
factory PatientModel.fromEntity(Patient patient) {
  return PatientModel(
    patientID: patient.patientID,
    name: patient.name,
    // ... other fields
    doctorId: patient.assignedDoctor?.staffID, // Store ID, not object
  );
}

// From model to domain entity (for loading)
Patient toEntity({Doctor? assignedDoctor}) {
  return Patient(
    patientID: patientID,
    name: name,
    // ... other fields
    assignedDoctor: assignedDoctor, // Resolve ID to object
  );
}
```

#### b. Relationship Handling

**One-to-One/Many-to-One**: Store as single ID
```dart
final String? doctorId; // Reference to doctor
```

**One-to-Many/Many-to-Many**: Store as ID list
```dart
final List<String> medicationIds; // References to medications
```

#### c. Date/Time Serialization
Always use ISO 8601 format strings:
```dart
// Saving
hireDate: doctor.hireDate.toIso8601String()

// Loading
hireDate: DateTime.parse(hireDate)
```

#### d. Complex Collections
For schedule maps, serialize nested structures:
```dart
// Entity: Map<String, List<DateTime>>
// Model: Map<String, List<String>> (ISO 8601 strings)

final scheduleJson = <String, List<String>>{};
doctor.schedule.forEach((date, times) {
  scheduleJson[date] = times.map((dt) => dt.toIso8601String()).toList();
});
```

### 3. Meeting Schedule Persistence

The system persists next meeting information for patients:

**Patient Model Fields**:
```dart
final bool hasNextMeeting;
final String? nextMeetingDate;     // ISO 8601 string
final String? nextMeetingDoctorId; // Reference to doctor
```

**JSON Structure**:
```json
{
  "patientID": "P001",
  "name": "John Doe",
  "hasNextMeeting": true,
  "nextMeetingDate": "2024-02-15T10:00:00.000Z",
  "nextMeetingDoctorId": "D123",
  ...
}
```

## JSON File Structure

All JSON files are stored in the `data/` directory at the project root.

### File Naming Convention
- `patients.json` - Patient records
- `doctors.json` - Doctor records
- `nurses.json` - Nurse records
- `rooms.json` - Room records
- `beds.json` - Bed records
- `equipment.json` - Equipment records
- `medications.json` - Medication records
- `prescriptions.json` - Prescription records
- `appointments.json` - Appointment records
- `administrative.json` - Administrative staff records

### Data File Format

Each file contains a JSON array of objects:

```json
[
  {
    "id": "unique_identifier",
    "field1": "value1",
    "field2": 123,
    "dateField": "2024-01-15T08:30:00.000Z",
    "relatedEntityId": "reference_id"
  },
  ...
]
```

### Example: patients.json
```json
[
  {
    "patientID": "P001",
    "name": "Alice Johnson",
    "dateOfBirth": "1985-05-15",
    "gender": "Female",
    "address": "123 Main St",
    "tel": "555-0101",
    "email": "alice@example.com",
    "emergencyContact": "Bob Johnson: 555-0102",
    "bloodGroup": "O+",
    "assignedDoctorId": "D101",
    "assignedNurseId": "N201",
    "roomId": "R301",
    "bedId": "B301A",
    "admissionDate": "2024-01-10T14:30:00.000Z",
    "dischargeDate": null,
    "hasNextMeeting": true,
    "nextMeetingDate": "2024-02-15T10:00:00.000Z",
    "nextMeetingDoctorId": "D101"
  }
]
```

### Example: doctors.json
```json
[
  {
    "staffID": "D101",
    "name": "Dr. Sarah Smith",
    "dateOfBirth": "1975-08-20",
    "address": "456 Oak Ave",
    "tel": "555-0201",
    "hireDate": "2010-03-15T00:00:00.000Z",
    "salary": 120000.0,
    "schedule": {
      "Monday": [
        "2024-01-15T09:00:00.000Z",
        "2024-01-15T14:00:00.000Z"
      ],
      "Tuesday": [
        "2024-01-16T10:00:00.000Z"
      ]
    },
    "specialization": "Cardiology",
    "certifications": ["Board Certified Cardiologist", "ACLS"],
    "currentPatientIds": ["P001", "P002", "P003"]
  }
]
```

## Repository Implementation Pattern

Repository implementations bridge the gap between domain interfaces and data sources.

**Key Responsibilities**:
1. Convert between domain entities and data models
2. Coordinate data source operations
3. Resolve entity relationships
4. Implement domain-specific query methods

**Example Implementation**:

```dart
class PatientRepositoryImpl implements PatientRepository {
  final PatientLocalDataSource _dataSource;
  final DoctorLocalDataSource _doctorDataSource;
  final NurseLocalDataSource _nurseDataSource;
  final RoomLocalDataSource _roomDataSource;
  final BedLocalDataSource _bedDataSource;

  PatientRepositoryImpl({
    required PatientLocalDataSource dataSource,
    required DoctorLocalDataSource doctorDataSource,
    required NurseLocalDataSource nurseDataSource,
    required RoomLocalDataSource roomDataSource,
    required BedLocalDataSource bedDataSource,
  })  : _dataSource = dataSource,
        _doctorDataSource = doctorDataSource,
        _nurseDataSource = nurseDataSource,
        _roomDataSource = roomDataSource,
        _bedDataSource = bedDataSource;

  @override
  Future<Patient?> findById(String id) async {
    final model = await _dataSource.findByPatientID(id);
    if (model == null) return null;
    
    // Resolve relationships
    final doctor = model.assignedDoctorId != null
        ? await _doctorDataSource.findByStaffID(model.assignedDoctorId!)
        : null;
    final nurse = model.assignedNurseId != null
        ? await _nurseDataSource.findByStaffID(model.assignedNurseId!)
        : null;
    final room = model.roomId != null
        ? await _roomDataSource.findByRoomNumber(model.roomId!)
        : null;
    final bed = model.bedId != null
        ? await _bedDataSource.findByBedNumber(model.bedId!)
        : null;
    
    return model.toEntity(
      assignedDoctor: doctor?.toEntity(),
      assignedNurse: nurse?.toEntity(),
      room: room?.toEntity(),
      bed: bed?.toEntity(),
    );
  }

  @override
  Future<void> save(Patient patient) async {
    final model = PatientModel.fromEntity(patient);
    
    final exists = await _dataSource.exists(
      patient.patientID,
      (p) => p.patientID,
    );
    
    if (exists) {
      await _dataSource.update(
        patient.patientID,
        model,
        (p) => p.patientID,
      );
    } else {
      await _dataSource.add(model, (p) => p.patientID);
    }
  }

  @override
  Future<List<Patient>> findPatientsWithUpcomingMeetings() async {
    final models = await _dataSource.findWhere((patient) {
      if (!patient.hasNextMeeting || patient.nextMeetingDate == null) {
        return false;
      }
      
      final meetingDate = DateTime.parse(patient.nextMeetingDate!);
      return meetingDate.isAfter(DateTime.now());
    });
    
    // Convert models to entities with relationships
    final patients = <Patient>[];
    for (final model in models) {
      // Resolve relationships...
      final patient = model.toEntity(/* ... */);
      patients.add(patient);
    }
    
    return patients;
  }
}
```

## Error Handling

The data layer uses custom exceptions for error handling:

```dart
class DataSourceException implements Exception {
  final String message;
  final dynamic originalError;

  DataSourceException(this.message, [this.originalError]);

  @override
  String toString() => 'DataSourceException: $message';
}
```

**Common Error Scenarios**:
- File I/O errors (permission denied, disk full)
- JSON parsing errors (malformed data)
- Missing relationships (referenced entity not found)

## Best Practices

### 1. Always Resolve Relationships
```dart
// ❌ Bad: Leaving relationships unresolved
return model.toEntity();

// ✅ Good: Resolving all relationships
return model.toEntity(
  assignedDoctor: await _resolveDoctor(model.doctorId),
  assignedNurse: await _resolveNurse(model.nurseId),
);
```

### 2. Use Transactions (Logical)
For operations affecting multiple entities, ensure consistency:

```dart
Future<void> schedulePatientMeeting(
  String patientId,
  DateTime meetingDate,
  String doctorId,
) async {
  try {
    // 1. Update patient
    final patient = await findById(patientId);
    if (patient == null) throw Exception('Patient not found');
    
    patient.scheduleNextMeeting(meetingDate, doctor);
    await save(patient);
    
    // 2. Update doctor's schedule
    final doctor = await _doctorRepo.findById(doctorId);
    if (doctor == null) throw Exception('Doctor not found');
    
    doctor.addScheduleSlot(meetingDate);
    await _doctorRepo.save(doctor);
    
  } catch (e) {
    // Handle rollback if needed
    rethrow;
  }
}
```

### 3. Validate Before Saving
```dart
Future<void> save(Patient patient) async {
  // Validate relationships exist
  if (patient.assignedDoctor != null) {
    final doctorExists = await _doctorDataSource.exists(
      patient.assignedDoctor!.staffID,
      (d) => d.staffID,
    );
    if (!doctorExists) {
      throw DataSourceException('Referenced doctor does not exist');
    }
  }
  
  // Proceed with save
  // ...
}
```

### 4. Use Optimistic Concurrency
For concurrent operations, implement version checking:

```dart
class PatientModel {
  final int version;
  // ... other fields

  PatientModel copyWith({int? version, /* ... */}) {
    return PatientModel(
      version: version ?? this.version + 1,
      // ... other fields
    );
  }
}
```

## Performance Considerations

### 1. Lazy Loading
Don't load all relationships if not needed:

```dart
// For listing: Don't resolve relationships
Future<List<PatientSummary>> getAllPatientSummaries() async {
  final models = await _dataSource.readAll();
  return models.map((m) => PatientSummary(
    id: m.patientID,
    name: m.name,
    // ... minimal fields
  )).toList();
}

// For details: Resolve all relationships
Future<Patient?> getPatientDetails(String id) async {
  // Full resolution
  return findById(id); // Includes all relationships
}
```

### 2. Caching
Consider caching frequently accessed data:

```dart
class PatientRepositoryImpl {
  final Map<String, Patient> _cache = {};
  
  Future<Patient?> findById(String id) async {
    if (_cache.containsKey(id)) {
      return _cache[id];
    }
    
    final patient = await _loadPatient(id);
    if (patient != null) {
      _cache[id] = patient;
    }
    return patient;
  }
  
  void clearCache() => _cache.clear();
}
```

### 3. Batch Operations
For bulk updates, use batch processing:

```dart
Future<void> saveAll(List<Patient> patients) async {
  final models = patients.map(PatientModel.fromEntity).toList();
  
  // Read existing data
  final existing = await _dataSource.readAll();
  final existingMap = {for (var e in existing) e.patientID: e};
  
  // Merge updates
  for (final model in models) {
    existingMap[model.patientID] = model;
  }
  
  // Write once
  await _dataSource.writeAll(existingMap.values.toList());
}
```

## Testing the Data Layer

### 1. Mock Data Sources
```dart
class MockPatientDataSource extends JsonDataSource<PatientModel> {
  final List<PatientModel> mockData;
  
  MockPatientDataSource(this.mockData) 
      : super(fileName: 'test.json', fromJson: PatientModel.fromJson);
  
  @override
  Future<List<PatientModel>> readAll() async => mockData;
}
```

### 2. Test Repository Implementation
```dart
void main() {
  group('PatientRepositoryImpl', () {
    late PatientRepositoryImpl repository;
    late MockPatientDataSource dataSource;
    
    setUp(() {
      dataSource = MockPatientDataSource([]);
      repository = PatientRepositoryImpl(dataSource: dataSource);
    });
    
    test('saves patient with meeting schedule', () async {
      final doctor = Doctor(/* ... */);
      final patient = Patient(/* ... */);
      patient.scheduleNextMeeting(DateTime.now().add(Duration(days: 7)), doctor);
      
      await repository.save(patient);
      
      final saved = await repository.findById(patient.patientID);
      expect(saved?.hasNextMeeting, true);
      expect(saved?.nextMeetingDate, isNotNull);
    });
  });
}
```

## Migration and Data Evolution

When entity structures change:

1. **Add New Fields**: Provide defaults in `fromJson`
```dart
factory PatientModel.fromJson(Map<String, dynamic> json) {
  return PatientModel(
    // ... existing fields
    newField: json['newField'] as String? ?? 'default_value',
  );
}
```

2. **Remove Fields**: Keep in model temporarily for backward compatibility
```dart
@deprecated
final String? oldField; // Keep for migration, don't use in toEntity
```

3. **Rename Fields**: Support both during transition
```dart
factory PatientModel.fromJson(Map<String, dynamic> json) {
  return PatientModel(
    renamedField: json['renamedField'] ?? json['oldFieldName'],
  );
}
```

## Summary

The data layer provides:
- ✅ JSON file-based persistence
- ✅ Clean separation from domain logic
- ✅ Relationship management through ID references
- ✅ Type-safe serialization/deserialization
- ✅ Meeting schedule persistence
- ✅ Extensible architecture for future enhancements

All domain entities can be persisted and retrieved while maintaining data integrity and supporting complex relationships.
